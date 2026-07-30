<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Inventory\Models\InventoryBatch;
use App\Domain\Inventory\Models\InventoryItem;
use App\Domain\Inventory\Models\StockMovement;
use App\Domain\Inventory\Support\InventoryExportService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\InventoryExportRequest;
use App\Http\Requests\Api\V1\InventoryItemArchiveRequest;
use App\Http\Requests\Api\V1\InventoryItemStoreRequest;
use App\Http\Requests\Api\V1\InventoryItemUpdateRequest;
use App\Http\Requests\Api\V1\InventoryReceiptRequest;
use App\Http\Resources\Api\V1\InventoryItemResource;
use App\Models\Farm;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class InventoryController extends Controller
{
    private const KINDS = ['medicine', 'semen', 'feed'];

    public function __construct(
        private readonly IdempotencyService $idempotency,
        private readonly AuditService $audit,
        private readonly InventoryExportService $exports,
    ) {}

    public function dashboard(Request $request): JsonResponse
    {
        $payload = collect(self::KINDS)->mapWithKeys(
            fn (string $kind) => [$kind => $this->summary($request, $kind)],
        );

        return ApiResponse::success($request, $payload);
    }

    public function index(Request $request, string $kind): JsonResponse
    {
        $kind = $this->kind($kind);
        $query = $this->baseQuery($request, $kind);
        if ($search = trim((string) $request->query('search', ''))) {
            $query->where(function ($query) use ($search): void {
                $query->where('name', 'like', '%'.$search.'%')
                    ->orWhere('item_code', 'like', '%'.$search.'%')
                    ->orWhere('barcode', 'like', '%'.$search.'%')
                    ->orWhere('brand', 'like', '%'.$search.'%');
            });
        }
        if ($category = trim((string) $request->query('category', ''))) {
            $query->where('category', $category);
        }
        if ($supplier = trim((string) $request->query('supplier', ''))) {
            $query->whereHas('batches', fn ($batch) => $batch->where('supplier', $supplier));
        }
        $items = $query->orderBy('name')->limit(200)->get();
        if ($request->boolean('low_stock')) {
            $items = $items->filter(
                fn (InventoryItem $item) => $this->stock($item) <= (float) $item->minimum_stock,
            )->values();
        }

        return ApiResponse::success($request, [
            'summary' => $this->summary($request, $kind),
            'items' => InventoryItemResource::collection($items)->resolve($request),
            'filters' => [
                'categories' => $items->pluck('category')->unique()->sort()->values(),
                'suppliers' => $items->flatMap->batches->pluck('supplier')->filter()->unique()->sort()->values(),
            ],
        ]);
    }

    public function store(
        InventoryItemStoreRequest $request,
        string $kind,
    ): JsonResponse {
        $kind = $this->kind($kind);
        $this->assertActiveFarm($request, $request->validated('farm_id'));

        return $this->idempotency->execute($request, function () use ($request, $kind): JsonResponse {
            $data = $request->validated();
            $item = DB::transaction(function () use ($request, $kind, $data): InventoryItem {
                $userId = $request->user()->id;
                $item = InventoryItem::create([
                    'id' => $data['id'] ?? (string) Str::uuid7(),
                    'organization_id' => $request->attributes->get('organization_id'),
                    'farm_id' => $data['farm_id'],
                    'kind' => $kind,
                    'item_code' => $data['item_code'] ?? $this->generatedCode($kind),
                    'barcode' => $data['barcode'] ?? null,
                    'name' => trim($data['name']),
                    'category' => trim($data['category']),
                    'brand' => $data['brand'] ?? null,
                    'unit' => trim($data['unit']),
                    'minimum_stock' => $data['minimum_stock'],
                    'maximum_stock' => $data['maximum_stock'] ?? null,
                    'notes' => $data['notes'] ?? null,
                    'is_active' => true,
                    'version' => 1,
                    'created_by' => $userId,
                    'updated_by' => $userId,
                ]);
                $batch = InventoryBatch::create([
                    'organization_id' => $item->organization_id,
                    'farm_id' => $item->farm_id,
                    'inventory_item_id' => $item->id,
                    'batch_number' => $data['batch_number'],
                    'supplier' => $data['supplier'] ?? null,
                    'purchase_date' => $data['purchase_date'] ?? null,
                    'expiry_date' => $data['expiry_date'] ?? null,
                    'unit_cost' => $data['unit_cost'],
                    'current_quantity' => $data['opening_quantity'],
                ]);
                StockMovement::create([
                    'organization_id' => $item->organization_id,
                    'farm_id' => $item->farm_id,
                    'inventory_item_id' => $item->id,
                    'inventory_batch_id' => $batch->id,
                    'movement_type' => 'opening_stock',
                    'quantity_change' => $data['opening_quantity'],
                    'unit_cost' => $data['unit_cost'],
                    'occurred_at' => now(),
                    'reason' => 'Opening stock recorded with item creation.',
                    'created_by' => $userId,
                ]);
                $this->audit->record(
                    $request,
                    'inventory.item_created',
                    'inventory_item',
                    $item->id,
                    null,
                    ['kind' => $kind, 'farm_id' => $item->farm_id, 'opening_quantity' => $data['opening_quantity']],
                );

                return $item->load('batches');
            });

            return ApiResponse::success(
                $request,
                (new InventoryItemResource($item))->resolve($request),
                201,
            );
        });
    }

    public function update(
        InventoryItemUpdateRequest $request,
        string $kind,
        string $item,
    ): JsonResponse {
        $model = $this->item($request, $this->kind($kind), $item);
        $data = $request->validated();
        $result = DB::transaction(function () use ($request, $model, $data): ?array {
            $lockedItem = InventoryItem::query()->lockForUpdate()->findOrFail($model->id);
            if ($lockedItem->version !== (int) $data['version']) {
                return null;
            }
            $old = $lockedItem->only([
                'name',
                'category',
                'barcode',
                'brand',
                'unit',
                'minimum_stock',
                'maximum_stock',
                'notes',
            ]);
            $lockedItem->fill([
                ...collect($data)->except('version')->all(),
                'version' => $lockedItem->version + 1,
                'updated_by' => $request->user()->id,
            ])->save();

            return [$lockedItem, $old];
        });
        if ($result === null) {
            return ApiResponse::error($request, 'STALE_VERSION', 'The inventory item was changed by another user.', 412);
        }
        [$model, $old] = $result;
        $this->audit->record(
            $request,
            'inventory.item_updated',
            'inventory_item',
            $model->id,
            $old,
            $model->only(array_keys($old)),
        );

        return ApiResponse::success(
            $request,
            (new InventoryItemResource($model->fresh('batches')))->resolve($request),
        );
    }

    public function archive(
        InventoryItemArchiveRequest $request,
        string $kind,
        string $item,
    ): JsonResponse {
        $model = $this->item($request, $this->kind($kind), $item);
        $result = DB::transaction(function () use ($request, $model): string {
            $lockedItem = InventoryItem::query()->lockForUpdate()->findOrFail($model->id);
            if ($lockedItem->version !== (int) $request->validated('version')) {
                return 'stale';
            }
            if ($lockedItem->batches()->where('current_quantity', '<>', 0)->exists()) {
                return 'has_stock';
            }

            $old = $lockedItem->only(['is_active', 'version']);
            $lockedItem->forceFill([
                'is_active' => false,
                'version' => $lockedItem->version + 1,
                'updated_by' => $request->user()->id,
            ])->save();
            $lockedItem->delete();
            $this->audit->record(
                $request,
                'inventory.item_archived',
                'inventory_item',
                $lockedItem->id,
                $old,
                ['is_active' => false, 'version' => $lockedItem->version],
            );

            return 'archived';
        });

        if ($result === 'stale') {
            return ApiResponse::error(
                $request,
                'STALE_VERSION',
                'The inventory item was changed by another user.',
                412,
            );
        }
        if ($result === 'has_stock') {
            return ApiResponse::error(
                $request,
                'INVENTORY_ITEM_HAS_STOCK',
                'This item still has stock. Record stock usage or an approved adjustment before archiving it.',
                409,
            );
        }

        return ApiResponse::success($request, [
            'id' => $model->id,
            'is_archived' => true,
        ]);
    }

    public function receipt(
        InventoryReceiptRequest $request,
        string $kind,
        string $item,
    ): JsonResponse {
        $model = $this->item($request, $this->kind($kind), $item);

        return $this->idempotency->execute($request, function () use ($request, $model): JsonResponse {
            $data = $request->validated();
            $movement = DB::transaction(function () use ($request, $model, $data): StockMovement {
                $lockedItem = InventoryItem::query()->lockForUpdate()->findOrFail($model->id);
                $batch = InventoryBatch::query()
                    ->where('inventory_item_id', $lockedItem->id)
                    ->where('batch_number', $data['batch_number'])
                    ->lockForUpdate()
                    ->first();
                if (! $batch) {
                    $batch = InventoryBatch::create([
                        'organization_id' => $lockedItem->organization_id,
                        'farm_id' => $lockedItem->farm_id,
                        'inventory_item_id' => $lockedItem->id,
                        'batch_number' => $data['batch_number'],
                        'supplier' => $data['supplier'] ?? null,
                        'purchase_date' => $data['purchase_date'] ?? null,
                        'expiry_date' => $data['expiry_date'] ?? null,
                        'unit_cost' => $data['unit_cost'],
                        'current_quantity' => 0,
                    ]);
                }
                $batch->forceFill([
                    'supplier' => $data['supplier'] ?? $batch->supplier,
                    'purchase_date' => $data['purchase_date'] ?? $batch->purchase_date,
                    'expiry_date' => $data['expiry_date'] ?? $batch->expiry_date,
                    'unit_cost' => $data['unit_cost'],
                    'current_quantity' => (float) $batch->current_quantity + (float) $data['quantity'],
                    'version' => $batch->version + 1,
                ])->save();
                $lockedItem->forceFill([
                    'version' => $lockedItem->version + 1,
                    'updated_by' => $request->user()->id,
                ])->save();
                $movement = StockMovement::create([
                    'organization_id' => $lockedItem->organization_id,
                    'farm_id' => $lockedItem->farm_id,
                    'inventory_item_id' => $lockedItem->id,
                    'inventory_batch_id' => $batch->id,
                    'movement_type' => 'purchase_receipt',
                    'quantity_change' => $data['quantity'],
                    'unit_cost' => $data['unit_cost'],
                    'occurred_at' => now(),
                    'reason' => $data['reason'] ?? 'Stock receipt',
                    'created_by' => $request->user()->id,
                ]);
                $this->audit->record(
                    $request,
                    'inventory.stock_received',
                    'stock_movement',
                    $movement->id,
                    null,
                    ['item_id' => $lockedItem->id, 'batch_id' => $batch->id, 'quantity' => $data['quantity']],
                );

                return $movement;
            });

            return ApiResponse::success($request, $this->movementPayload($movement->load('batch')), 201);
        });
    }

    public function movements(Request $request, string $kind, string $item): JsonResponse
    {
        $model = $this->item($request, $this->kind($kind), $item);
        $movements = $model->movements()
            ->with('batch')
            ->latest('occurred_at')
            ->limit(200)
            ->get()
            ->map(fn (StockMovement $movement) => $this->movementPayload($movement));

        return ApiResponse::success($request, $movements);
    }

    public function receiptExport(InventoryExportRequest $request, string $kind): Response
    {
        [$farm, $items, $movements, $from, $to] = $this->exportData($request, $kind);
        $contents = $this->exports->pdf($farm, $kind, $items, $movements, $from, $to);

        $this->recordExportAudit($request, 'inventory.receipt_exported', $kind, $items);

        return $this->download(
            $contents,
            "dairycare-$kind-receipt-".now($farm->timezone)->format('Ymd-His').'.pdf',
            'application/pdf',
        );
    }

    public function spreadsheetExport(InventoryExportRequest $request, string $kind): Response
    {
        [$farm, $items, $movements, $from, $to] = $this->exportData($request, $kind);
        $contents = $this->exports->xlsx($farm, $kind, $items, $movements, $from, $to);

        $this->recordExportAudit($request, 'inventory.spreadsheet_exported', $kind, $items);

        return $this->download(
            $contents,
            "dairycare-$kind-inventory-".now($farm->timezone)->format('Ymd-His').'.xlsx',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
    }

    private function baseQuery(Request $request, string $kind)
    {
        return InventoryItem::query()
            ->with('batches')
            ->where('organization_id', $request->attributes->get('organization_id'))
            ->where('farm_id', $request->attributes->get('api_session')->farm_id)
            ->where('kind', $kind)
            ->where('is_active', true);
    }

    private function summary(Request $request, string $kind): array
    {
        $items = $this->baseQuery($request, $kind)->get();
        $batches = $items->flatMap->batches->where('current_quantity', '>', 0);
        $today = today();

        return [
            'item_count' => $items->count(),
            'total_stock' => number_format($items->sum(fn (InventoryItem $item) => $this->stock($item)), 3, '.', ''),
            'total_value' => number_format($batches->sum(fn ($batch) => (float) $batch->current_quantity * (float) $batch->unit_cost), 4, '.', ''),
            'low_stock_items' => $items->filter(fn (InventoryItem $item) => $this->stock($item) <= (float) $item->minimum_stock)->count(),
            'expiring_soon_batches' => $batches->filter(fn ($batch) => $batch->expiry_date?->between($today, $today->copy()->addDays(30)) ?? false)->count(),
            'expired_batches' => $batches->filter(fn ($batch) => $batch->expiry_date?->lt($today) ?? false)->count(),
        ];
    }

    private function stock(InventoryItem $item): float
    {
        return $item->batches->sum(fn ($batch) => (float) $batch->current_quantity);
    }

    private function item(Request $request, string $kind, string $id): InventoryItem
    {
        return InventoryItem::with('batches')
            ->where('organization_id', $request->attributes->get('organization_id'))
            ->where('farm_id', $request->attributes->get('api_session')->farm_id)
            ->where('kind', $kind)
            ->findOrFail($id);
    }

    private function kind(string $kind): string
    {
        abort_unless(in_array($kind, self::KINDS, true), 404);

        return $kind;
    }

    private function assertActiveFarm(Request $request, string $farmId): void
    {
        abort_unless(
            $request->attributes->get('api_session')->farm_id === $farmId
            && $request->attributes->get('membership')->canAccessFarm($farmId),
            404,
        );
    }

    private function generatedCode(string $kind): string
    {
        return strtoupper(substr($kind, 0, 3)).'-'.Str::upper(Str::random(8));
    }

    private function movementPayload(StockMovement $movement): array
    {
        return [
            'id' => $movement->id,
            'item_id' => $movement->inventory_item_id,
            'batch_id' => $movement->inventory_batch_id,
            'batch_number' => $movement->batch?->batch_number,
            'movement_type' => $movement->movement_type,
            'quantity_change' => $movement->quantity_change,
            'unit_cost' => $movement->unit_cost,
            'occurred_at' => $movement->occurred_at?->toISOString(),
            'reason' => $movement->reason,
            'created_by' => $movement->created_by,
        ];
    }

    private function exportData(InventoryExportRequest $request, string $kind): array
    {
        $kind = $this->kind($kind);
        $data = $request->validated();
        $farm = Farm::query()
            ->where('organization_id', $request->attributes->get('organization_id'))
            ->findOrFail($request->attributes->get('api_session')->farm_id);
        $itemIds = $data['item_ids'] ?? [];
        $query = $this->baseQuery($request, $kind);
        if ($itemIds !== []) {
            $query->whereIn('id', $itemIds);
        }
        $items = $query->orderBy('name')->get();
        if ($itemIds !== [] && $items->count() !== count($itemIds)) {
            abort(404);
        }

        $from = isset($data['from_date'])
            ? CarbonImmutable::parse($data['from_date'], $farm->timezone)->startOfDay()->utc()
            : null;
        $to = isset($data['to_date'])
            ? CarbonImmutable::parse($data['to_date'], $farm->timezone)->endOfDay()->utc()
            : null;
        $movements = StockMovement::query()
            ->with(['item', 'batch'])
            ->where('organization_id', $farm->organization_id)
            ->where('farm_id', $farm->id)
            ->whereIn('inventory_item_id', $items->pluck('id'))
            ->when($from, fn ($query) => $query->where('occurred_at', '>=', $from))
            ->when($to, fn ($query) => $query->where('occurred_at', '<=', $to))
            ->orderBy('occurred_at')
            ->orderBy('id')
            ->get();

        return [$farm, $items, $movements, $from, $to];
    }

    private function recordExportAudit(
        InventoryExportRequest $request,
        string $action,
        string $kind,
        $items,
    ): void {
        $this->audit->record(
            $request,
            $action,
            'inventory_export',
            null,
            null,
            [
                'kind' => $kind,
                'farm_id' => $request->attributes->get('api_session')->farm_id,
                'item_count' => $items->count(),
                'item_ids' => $items->pluck('id')->values()->all(),
                'from_date' => $request->validated('from_date'),
                'to_date' => $request->validated('to_date'),
            ],
        );
    }

    private function download(string $contents, string $filename, string $contentType): Response
    {
        return response($contents, 200, [
            'Cache-Control' => 'private, no-store, max-age=0',
            'Content-Disposition' => 'attachment; filename="'.$filename.'"',
            'Content-Type' => $contentType,
            'Pragma' => 'no-cache',
            'X-Content-Type-Options' => 'nosniff',
        ]);
    }
}

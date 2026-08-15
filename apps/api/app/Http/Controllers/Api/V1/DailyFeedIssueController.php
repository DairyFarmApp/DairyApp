<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Feed\Models\DailyFeedIssue;
use App\Domain\Inventory\Models\InventoryBatch;
use App\Domain\Inventory\Models\InventoryItem;
use App\Domain\Inventory\Models\StockMovement;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\DailyFeedIssueRequest;
use App\Http\Resources\Api\V1\DailyFeedIssueResource;
use App\Models\Farm;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class DailyFeedIssueController extends Controller
{
    public function __construct(
        private readonly AuditService $audit,
        private readonly IdempotencyService $idempotency
    ) {}

    public function index(Request $request): JsonResponse
    {
        $farmModel = $this->activeFarm($request);
        $items = DailyFeedIssue::query()
            ->where('organization_id', $farmModel->organization_id)
            ->where('farm_id', $farmModel->id)
            ->orderByDesc('date')
            ->cursorPaginate(min((int) $request->input('page.size', 50), 100));

        return ApiResponse::success($request, DailyFeedIssueResource::collection($items)->resolve($request), 200, [
            'pagination' => [
                'next_cursor' => $items->nextCursor()?->encode(),
                'has_more' => $items->hasMorePages(),
                'page_size' => $items->perPage(),
            ],
        ]);
    }

    public function store(DailyFeedIssueRequest $request): JsonResponse
    {
        $farmModel = $this->activeFarm($request);

        return $this->idempotency->execute($request, function () use ($request, $farmModel): JsonResponse {
            $data = $request->validated();

            $issue = null;
            $posted = DB::transaction(function () use (&$issue, $data, $farmModel, $request) {
                $item = InventoryItem::query()->where('organization_id', $farmModel->organization_id)->where('farm_id', $farmModel->id)->where('kind', 'feed')->lockForUpdate()->findOrFail($data['inventory_item_id']);
                $batches = InventoryBatch::query()->where('inventory_item_id', $item->id)->where('current_quantity', '>', 0)->where(fn ($q) => $q->whereNull('expiry_date')->orWhereDate('expiry_date', '>=', $data['date']))->orderByRaw('CASE WHEN expiry_date IS NULL THEN 1 ELSE 0 END')->orderBy('expiry_date')->lockForUpdate()->get();
                $issued = (float) $data['issued_quantity'];
                if ($batches->sum(fn ($b) => (float) $b->current_quantity) + .000001 < $issued) {
                    return false;
                }
                $issue = DailyFeedIssue::create([
                    'id' => $data['id'] ?? (string) Str::uuid7(),
                    'organization_id' => $farmModel->organization_id,
                    'farm_id' => $farmModel->id,
                    'shed_id' => $data['shed_id'] ?? null,
                    'animal_group_id' => $data['animal_group_id'] ?? null,
                    'date' => $data['date'],
                    'inventory_item_id' => $data['inventory_item_id'],
                    'planned_quantity' => $data['planned_quantity'],
                    'issued_quantity' => $data['issued_quantity'],
                    'consumed_quantity' => $data['consumed_quantity'],
                    'wasted_quantity' => $data['wasted_quantity'],
                    'returned_quantity' => $data['returned_quantity'],
                    'inventory_posted' => true, 'inventory_net_quantity' => (float) $data['consumed_quantity'] + (float) $data['wasted_quantity'],
                    'employee_id' => $data['employee_id'] ?? null,
                    'notes' => $data['notes'] ?? null,
                    'created_by' => $request->user()->id,
                    'updated_by' => $request->user()->id,
                    'version' => 1,
                ]);

                $remaining = $issued;
                $allocations = [];
                foreach ($batches as $batch) {
                    if ($remaining <= 0) {
                        break;
                    }$used = min($remaining, (float) $batch->current_quantity);
                    $batch->forceFill(['current_quantity' => (float) $batch->current_quantity - $used, 'version' => $batch->version + 1])->save();
                    $allocations[] = [$batch, $used];
                    StockMovement::create(['organization_id' => $item->organization_id, 'farm_id' => $item->farm_id, 'inventory_item_id' => $item->id, 'inventory_batch_id' => $batch->id, 'movement_type' => 'issue', 'quantity_change' => -$used, 'unit_cost' => $batch->unit_cost, 'occurred_at' => $data['date'].' 12:00:00', 'reason' => 'Daily feed issued', 'reference_type' => 'daily_feed_issue', 'reference_id' => $issue->id, 'created_by' => $request->user()->id]);
                    $remaining -= $used;
                }
                $returned = (float) $data['returned_quantity'];
                foreach (array_reverse($allocations) as [$batch,$used]) {
                    if ($returned <= 0) {
                        break;
                    }$qty = min($returned, $used);
                    $batch->forceFill(['current_quantity' => (float) $batch->current_quantity + $qty, 'version' => $batch->version + 1])->save();
                    StockMovement::create(['organization_id' => $item->organization_id, 'farm_id' => $item->farm_id, 'inventory_item_id' => $item->id, 'inventory_batch_id' => $batch->id, 'movement_type' => 'return', 'quantity_change' => $qty, 'unit_cost' => $batch->unit_cost, 'occurred_at' => $data['date'].' 18:00:00', 'reason' => 'Unused daily feed returned', 'reference_type' => 'daily_feed_issue', 'reference_id' => $issue->id, 'created_by' => $request->user()->id]);
                    $returned -= $qty;
                }
                $item->forceFill(['version' => $item->version + 1, 'updated_by' => $request->user()->id])->save();

                $this->audit->record($request, 'daily_feed_issue.created', 'daily_feed_issue', $issue->id, null, $issue->toArray());

                return true;
            });

            if (! $posted) {
                return ApiResponse::error($request, 'INSUFFICIENT_OR_EXPIRED_FEED', 'Not enough non-expired feed stock is available.', 422);
            }

            return ApiResponse::success($request, (new DailyFeedIssueResource($issue))->resolve($request), 201);
        });
    }

    private function activeFarm(Request $request): Farm
    {
        $farmId = $request->attributes->get('api_session')->farm_id;
        $farm = Farm::query()
            ->where('organization_id', $request->attributes->get('organization_id'))
            ->findOrFail($farmId);
        abort_unless($request->attributes->get('membership')->canAccessFarm($farm->id), 404);

        return $farm;
    }
}

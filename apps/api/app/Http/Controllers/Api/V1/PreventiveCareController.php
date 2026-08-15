<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalHealth\Models\AnimalPreventiveCareRecord;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\Inventory\Models\InventoryBatch;
use App\Domain\Inventory\Models\InventoryItem;
use App\Domain\Inventory\Models\StockMovement;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\PreventiveCareStoreRequest;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PreventiveCareController extends Controller
{
    public function __construct(private readonly IdempotencyService $idempotency, private readonly AuditService $audit) {}

    public function index(Request $request, string $animal): JsonResponse
    {
        $model = $this->animal($request, $animal);
        $items = AnimalPreventiveCareRecord::query()->where('organization_id', $model->organization_id)->where('farm_id', $model->current_farm_id)->where('animal_id', $model->id)->latest('administered_at')->get();

        return ApiResponse::success($request, $items->map(fn ($r) => $this->payload($r))->all());
    }

    public function due(Request $request): JsonResponse
    {
        $farm = $request->attributes->get('api_session')->farm_id;
        $items = AnimalPreventiveCareRecord::query()->where('organization_id', $request->attributes->get('organization_id'))->where('farm_id', $farm)->whereNotNull('next_due_date')->whereDate('next_due_date', '<=', today()->addDays(30))->latest('next_due_date')->get()->unique(fn ($r) => $r->animal_id.'-'.$r->type);

        return ApiResponse::success($request, $items->map(fn ($r) => $this->payload($r))->values()->all());
    }

    public function store(PreventiveCareStoreRequest $request): JsonResponse
    {
        return $this->idempotency->execute($request, function () use ($request): JsonResponse {
            $d = $request->validated();
            $org = $request->attributes->get('organization_id');
            $farm = $request->attributes->get('api_session')->farm_id;
            $animals = Animal::query()->where('organization_id', $org)->where('current_farm_id', $farm)->where('operational_status', 'active')->whereIn('id', $d['animal_ids'])->get();
            if ($animals->count() !== count($d['animal_ids'])) {
                return ApiResponse::error($request, 'INVALID_PREVENTIVE_ANIMAL', 'Every selected animal must be active and in the current farm.', 422);
            }
            $item = InventoryItem::query()->where('organization_id', $org)->where('farm_id', $farm)->where('kind', 'medicine')->findOrFail($d['inventory_item_id']);
            if ($d['type'] === 'vaccination' && strcasecmp($item->category, 'Vaccine') !== 0) {
                return ApiResponse::error($request, 'VACCINE_REQUIRED', 'Select a medicine item in the Vaccine category.', 422);
            }
            $each = (float) $d['inventory_quantity_used_per_animal'];
            $total = $each * $animals->count();
            $campaign = $animals->count() > 1 ? (string) Str::uuid7() : null;
            $result = DB::transaction(function () use ($request, $d, $org, $farm, $animals, $item, $each, $total, $campaign) {
                $batches = InventoryBatch::query()->where('inventory_item_id', $item->id)->where('current_quantity', '>', 0)->where(fn ($q) => $q->whereNull('expiry_date')->orWhereDate('expiry_date', '>=', today()))->orderByRaw('CASE WHEN expiry_date IS NULL THEN 1 ELSE 0 END')->orderBy('expiry_date')->lockForUpdate()->get();
                if ($batches->sum(fn ($b) => (float) $b->current_quantity) + .000001 < $total) {
                    return null;
                }
                $batch = $batches->first(fn ($b) => (float) $b->current_quantity + 0.000001 >= $total);
                if (! $batch) {
                    return false;
                }
                $records = [];
                foreach ($animals as $animal) {
                    $number = 'PC-'.str_pad((string) (AnimalPreventiveCareRecord::query()->where('organization_id', $org)->lockForUpdate()->count() + 1), 6, '0', STR_PAD_LEFT);
                    $records[] = AnimalPreventiveCareRecord::query()->create([...$d, 'organization_id' => $org, 'farm_id' => $farm, 'animal_id' => $animal->id, 'inventory_batch_id' => $batch->id, 'campaign_id' => $campaign, 'record_number' => $number, 'inventory_quantity_used' => $each, 'cost_pkr' => $d['cost_pkr_per_animal'], 'created_by' => $request->user()->id]);
                }
                $batch->forceFill(['current_quantity' => (float) $batch->current_quantity - $total, 'version' => $batch->version + 1])->save();
                StockMovement::query()->create(['organization_id' => $org, 'farm_id' => $farm, 'inventory_item_id' => $item->id, 'inventory_batch_id' => $batch->id, 'movement_type' => 'consumption', 'quantity_change' => -$total, 'unit_cost' => $batch->unit_cost, 'occurred_at' => $d['administered_at'], 'reason' => ucfirst($d['type']).' campaign '.$campaign, 'created_by' => $request->user()->id]);
                $item->forceFill(['version' => $item->version + 1, 'updated_by' => $request->user()->id])->save();
                $this->audit->record($request, 'animal_preventive_care.recorded', 'preventive_campaign', $campaign ?? $records[0]->id, null, ['type' => $d['type'], 'animal_ids' => $d['animal_ids'], 'quantity_used' => $total]);

                return $records;
            });
            if ($result === null) {
                return ApiResponse::error($request, 'INSUFFICIENT_OR_EXPIRED_STOCK', 'Not enough non-expired stock is available.', 422);
            }
            if ($result === false) {
                return ApiResponse::error($request, 'SINGLE_BATCH_REQUIRED', 'One non-expired batch must contain enough stock for this campaign so every animal has the same traceable batch.', 422);
            }

            return ApiResponse::success($request, collect($result)->map(fn ($r) => $this->payload($r))->all(), 201);
        });
    }

    private function animal(Request $request, string $id): Animal
    {
        return Animal::query()->where('organization_id', $request->attributes->get('organization_id'))->where('current_farm_id', $request->attributes->get('api_session')->farm_id)->findOrFail($id);
    }

    private function payload(AnimalPreventiveCareRecord $r): array
    {
        return ['id' => $r->id, 'animal_id' => $r->animal_id, 'record_number' => $r->record_number, 'type' => $r->type, 'inventory_item_id' => $r->inventory_item_id, 'batch_id' => $r->inventory_batch_id, 'disease_covered' => $r->disease_covered, 'dose' => $r->dose, 'dose_unit' => $r->dose_unit, 'administered_at' => $r->administered_at?->toIso8601String(), 'next_due_date' => $r->next_due_date?->format('Y-m-d'), 'veterinarian_name' => $r->veterinarian_name, 'administered_by_name' => $r->administered_by_name, 'cost_pkr' => $r->cost_pkr, 'reaction' => $r->reaction, 'notes' => $r->notes, 'due_status' => $r->next_due_date === null ? 'none' : ($r->next_due_date->isPast() ? 'overdue' : ($r->next_due_date->lte(today()->addDays(30)) ? 'upcoming' : 'scheduled'))];
    }
}

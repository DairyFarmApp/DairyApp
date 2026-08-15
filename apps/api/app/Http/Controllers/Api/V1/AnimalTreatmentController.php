<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalHealth\Models\AnimalHealthCase;
use App\Domain\AnimalHealth\Models\AnimalTreatment;
use App\Domain\AnimalHealth\Models\AnimalWithdrawalRestriction;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\Inventory\Models\InventoryBatch;
use App\Domain\Inventory\Models\InventoryItem;
use App\Domain\Inventory\Models\StockMovement;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\AnimalTreatmentStoreRequest;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AnimalTreatmentController extends Controller
{
    public function __construct(private readonly IdempotencyService $idempotency, private readonly AuditService $audit) {}

    public function index(Request $request, string $animal): JsonResponse
    {
        $model = $this->animal($request, $animal);
        $items = AnimalTreatment::query()->with('withdrawals')->where('organization_id', $model->organization_id)->where('farm_id', $model->current_farm_id)->where('animal_id', $model->id)->latest('administered_at')->get();

        return ApiResponse::success($request, $items->map(fn ($t) => $this->payload($t))->all());
    }

    public function store(AnimalTreatmentStoreRequest $request, string $animal): JsonResponse
    {
        $model = $this->animal($request, $animal);
        abort_if($model->operational_status !== 'active', 422, 'Only active animals can receive treatment.');

        return $this->idempotency->execute($request, function () use ($request, $model): JsonResponse {
            $d = $request->validated();
            $case = AnimalHealthCase::query()->where('organization_id', $model->organization_id)->where('farm_id', $model->current_farm_id)->where('animal_id', $model->id)->findOrFail($d['health_case_id']);
            $item = InventoryItem::query()->where('organization_id', $model->organization_id)->where('farm_id', $model->current_farm_id)->where('kind', 'medicine')->findOrFail($d['inventory_item_id']);
            if (! $item->generic_name || ! $item->concentration) {
                return ApiResponse::error($request, 'MEDICINE_DETAILS_REQUIRED', 'Add the generic name and concentration from the verified product label first.', 422);
            }$qty = (float) $d['inventory_quantity_used'];
            $result = DB::transaction(function () use ($request, $model, $case, $item, $d, $qty) {
                $batches = InventoryBatch::query()->where('inventory_item_id', $item->id)->where('current_quantity', '>', 0)->where(fn ($q) => $q->whereNull('expiry_date')->orWhereDate('expiry_date', '>=', today()))->orderByRaw('CASE WHEN expiry_date IS NULL THEN 1 ELSE 0 END')->orderBy('expiry_date')->lockForUpdate()->get();
                if ($batches->sum(fn ($b) => (float) $b->current_quantity) + 0.000001 < $qty) {
                    return null;
                }$number = 'TR-'.str_pad((string) (AnimalTreatment::query()->where('organization_id', $model->organization_id)->lockForUpdate()->count() + 1), 6, '0', STR_PAD_LEFT);
                $t = AnimalTreatment::query()->create([...$d, 'organization_id' => $model->organization_id, 'farm_id' => $model->current_farm_id, 'animal_id' => $model->id, 'treatment_number' => $number, 'administered_by' => $request->user()->id]);
                $remaining = $qty;
                foreach ($batches as $batch) {
                    if ($remaining <= 0) {
                        break;
                    }$used = min($remaining, (float) $batch->current_quantity);
                    $batch->forceFill(['current_quantity' => (float) $batch->current_quantity - $used, 'version' => $batch->version + 1])->save();
                    StockMovement::query()->create(['organization_id' => $model->organization_id, 'farm_id' => $model->current_farm_id, 'inventory_item_id' => $item->id, 'inventory_batch_id' => $batch->id, 'movement_type' => 'consumption', 'quantity_change' => -$used, 'unit_cost' => $batch->unit_cost, 'occurred_at' => $d['administered_at'], 'reason' => "Treatment $number for animal {$model->animal_number}", 'created_by' => $request->user()->id]);
                    $remaining -= $used;
                }$item->forceFill(['version' => $item->version + 1, 'updated_by' => $request->user()->id])->save();
                $start = $t->administered_at;
                if ($item->milk_withdrawal_hours > 0) {
                    AnimalWithdrawalRestriction::query()->create(['organization_id' => $model->organization_id, 'farm_id' => $model->current_farm_id, 'animal_id' => $model->id, 'treatment_id' => $t->id, 'type' => 'milk', 'starts_at' => $start, 'ends_at' => $start->copy()->addHours($item->milk_withdrawal_hours), 'status' => 'active', 'reason' => "{$item->name} label withdrawal period", 'created_by' => $request->user()->id]);
                }if ($item->meat_withdrawal_days > 0) {
                    AnimalWithdrawalRestriction::query()->create(['organization_id' => $model->organization_id, 'farm_id' => $model->current_farm_id, 'animal_id' => $model->id, 'treatment_id' => $t->id, 'type' => 'meat', 'starts_at' => $start, 'ends_at' => $start->copy()->addDays($item->meat_withdrawal_days), 'status' => 'active', 'reason' => "{$item->name} label withdrawal period", 'created_by' => $request->user()->id]);
                }$case->forceFill(['status' => 'monitoring', 'version' => $case->version + 1])->save();
                $this->audit->record($request, 'animal_treatment.recorded', 'animal_treatment', $t->id, null, ['animal_id' => $model->id, 'medicine_id' => $item->id, 'quantity_used' => $qty]);

                return $t->load('withdrawals');
            });
            if (! $result) {
                return ApiResponse::error($request, 'INSUFFICIENT_OR_EXPIRED_MEDICINE', 'Not enough non-expired medicine stock is available.', 422);
            }

            return ApiResponse::success($request, $this->payload($result), 201);
        });
    }

    private function animal(Request $request, string $id): Animal
    {
        return Animal::query()->where('organization_id', $request->attributes->get('organization_id'))->where('current_farm_id', $request->attributes->get('api_session')->farm_id)->findOrFail($id);
    }

    private function payload(AnimalTreatment $t): array
    {
        return ['id' => $t->id, 'treatment_number' => $t->treatment_number, 'health_case_id' => $t->health_case_id, 'inventory_item_id' => $t->inventory_item_id, 'administered_at' => $t->administered_at?->toIso8601String(), 'animal_weight_kg' => $t->animal_weight_kg, 'dose' => $t->dose, 'dose_unit' => $t->dose_unit, 'route' => $t->route, 'frequency' => $t->frequency, 'duration_days' => $t->duration_days, 'inventory_quantity_used' => $t->inventory_quantity_used, 'veterinarian_name' => $t->veterinarian_name, 'veterinarian_instructions' => $t->veterinarian_instructions, 'withdrawals' => $t->withdrawals->map(fn ($w) => ['type' => $w->type, 'starts_at' => $w->starts_at?->toIso8601String(), 'ends_at' => $w->ends_at?->toIso8601String(), 'status' => $w->status, 'reason' => $w->reason])->values()];
    }
}

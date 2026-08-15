<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalHealth\Models\AnimalBreedingService;
use App\Domain\AnimalHealth\Models\AnimalCalvingEvent;
use App\Domain\AnimalHealth\Models\AnimalHeatRecord;
use App\Domain\AnimalHealth\Models\AnimalPregnancyCheck;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Support\AnimalNumberGenerator;
use App\Domain\Inventory\Models\InventoryBatch;
use App\Domain\Inventory\Models\InventoryItem;
use App\Domain\Inventory\Models\StockMovement;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\BreedingEventRequest;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class BreedingController extends Controller
{
    public function __construct(private readonly IdempotencyService $idempotency, private readonly AuditService $audit, private readonly AnimalNumberGenerator $numbers) {}

    public function index(Request $r, string $animal): JsonResponse
    {
        $a = $this->animal($r, $animal);

        return ApiResponse::success($r, ['heat' => AnimalHeatRecord::where('animal_id', $a->id)->latest('detected_at')->get(), 'services' => AnimalBreedingService::where('animal_id', $a->id)->latest('bred_at')->get(), 'pregnancy_checks' => AnimalPregnancyCheck::where('animal_id', $a->id)->latest('checked_on')->get(), 'calvings' => AnimalCalvingEvent::where('mother_animal_id', $a->id)->latest('calved_at')->get()]);
    }

    public function due(Request $r): JsonResponse
    {
        $o = $r->attributes->get('organization_id');
        $f = $r->attributes->get('api_session')->farm_id;

        return ApiResponse::success($r, ['pregnancy_checks' => AnimalBreedingService::where('organization_id', $o)->where('farm_id', $f)->whereDate('pregnancy_check_due_date', '<=', today()->addDays(14))->whereDoesntHave('pregnancyChecks')->get(), 'calvings' => AnimalPregnancyCheck::where('organization_id', $o)->where('farm_id', $f)->where('result', 'pregnant')->whereDate('expected_calving_date', '<=', today()->addDays(30))->get()]);
    }

    public function store(BreedingEventRequest $r, string $animal, string $event): JsonResponse
    {
        $a = $this->animal($r, $animal);
        abort_if($a->sex !== 'female' || $a->operational_status !== 'active', 422, 'Breeding records require an active female animal.');

        return $this->idempotency->execute($r, function () use ($r, $a, $event) {
            $x = DB::transaction(fn () => match ($event) {
                'heat' => $this->heat($r, $a, $r->validated()),'service' => $this->service($r, $a, $r->validated()),'pregnancy-check' => $this->pregnancy($r, $a, $r->validated()),'calving' => $this->calving($r, $a, $r->validated())
            });

            return is_array($x) && isset($x['error']) ? ApiResponse::error($r, $x['error'], $x['message'], 422) : ApiResponse::success($r, $x, 201);
        });
    }

    private function heat(Request $r, Animal $a, array $d)
    {
        return AnimalHeatRecord::create([...$d, 'organization_id' => $a->organization_id, 'farm_id' => $a->current_farm_id, 'animal_id' => $a->id, 'created_by' => $r->user()->id]);
    }

    private function service(Request $r, Animal $a, array $d)
    {
        $batch = null;
        if ($d['method'] === 'artificial') {
            $i = InventoryItem::where('organization_id', $a->organization_id)->where('farm_id', $a->current_farm_id)->where('kind', 'semen')->findOrFail($d['semen_item_id']);
            $batch = InventoryBatch::where('inventory_item_id', $i->id)->where('current_quantity', '>=', 1)->where(fn ($q) => $q->whereNull('expiry_date')->orWhereDate('expiry_date', '>=', today()))->orderBy('expiry_date')->lockForUpdate()->first();
            if (! $batch) {
                return ['error' => 'NO_VALID_SEMEN', 'message' => 'No non-expired semen straw is available.'];
            }$batch->decrement('current_quantity');
            StockMovement::create(['organization_id' => $a->organization_id, 'farm_id' => $a->current_farm_id, 'inventory_item_id' => $i->id, 'inventory_batch_id' => $batch->id, 'movement_type' => 'consumption', 'quantity_change' => -1, 'unit_cost' => $batch->unit_cost, 'occurred_at' => $d['bred_at'], 'reason' => 'Artificial insemination', 'created_by' => $r->user()->id]);
        } elseif (! Animal::where('organization_id', $a->organization_id)->where('sex', 'male')->where('operational_status', 'active')->find($d['bull_animal_id'])) {
            return ['error' => 'INVALID_BULL', 'message' => 'Select an active male animal.'];
        }$n = 'BS-'.str_pad((string) (AnimalBreedingService::where('organization_id', $a->organization_id)->lockForUpdate()->count() + 1), 6, '0', STR_PAD_LEFT);

        return AnimalBreedingService::create([...$d, 'organization_id' => $a->organization_id, 'farm_id' => $a->current_farm_id, 'animal_id' => $a->id, 'service_number' => $n, 'semen_batch_id' => $batch?->id, 'pregnancy_check_due_date' => Carbon::parse($d['bred_at'])->addDays(35), 'created_by' => $r->user()->id]);
    }

    private function pregnancy(Request $r, Animal $a, array $d)
    {
        $s = AnimalBreedingService::where('animal_id', $a->id)->find($d['breeding_service_id']);
        if (! $s) {
            return ['error' => 'INVALID_SERVICE', 'message' => 'Service does not belong to animal.'];
        }

return AnimalPregnancyCheck::create([...$d, 'organization_id' => $a->organization_id, 'farm_id' => $a->current_farm_id, 'animal_id' => $a->id, 'expected_calving_date' => $d['result'] === 'pregnant' ? $s->bred_at->copy()->addDays(283) : null, 'created_by' => $r->user()->id]);
    }

    private function calving(Request $r, Animal $a, array $d)
    {
        $p = AnimalPregnancyCheck::where('animal_id', $a->id)->where('result', 'pregnant')->find($d['pregnancy_check_id']);
        if (! $p) {
            return ['error' => 'INVALID_PREGNANCY', 'message' => 'Confirmed pregnancy required.'];
        }if (AnimalCalvingEvent::where('pregnancy_check_id', $p->id)->exists()) {
            return ['error' => 'CALVING_ALREADY_RECORDED', 'message' => 'Calving already recorded.'];
        }$ids = [];
        foreach ($d['calves'] as $c) {
            $calf = Animal::create(['organization_id' => $a->organization_id, 'animal_number' => $this->numbers->next($a->organization_id), 'ear_tag_number' => $c['ear_tag_number'] ?? null, 'species_id' => $a->species_id, 'breed_id' => $c['breed_id'], 'sex' => $c['sex'], 'life_stage' => 'calf', 'date_of_birth' => Carbon::parse($d['calved_at'])->toDateString(), 'current_farm_id' => $a->current_farm_id, 'current_shed_id' => $a->current_shed_id, 'current_animal_group_id' => $a->current_animal_group_id, 'mother_animal_id' => $a->id, 'origin' => 'born_on_farm', 'operational_status' => 'active', 'photo_requirement_exempt' => false, 'notes' => 'Birth condition: '.$c['condition'].'; birth weight: '.$c['birth_weight_kg'].' kg', 'created_by' => $r->user()->id, 'updated_by' => $r->user()->id]);
            $ids[] = $calf->id;
        }

return AnimalCalvingEvent::create([...$d, 'organization_id' => $a->organization_id, 'farm_id' => $a->current_farm_id, 'mother_animal_id' => $a->id, 'calf_animal_ids' => $ids, 'post_calving_check_due' => Carbon::parse($d['calved_at'])->addDays(7), 'created_by' => $r->user()->id]);
    }

    private function animal(Request $r,string $id): Animal
    {
        return Animal::where('organization_id',$r->attributes->get('organization_id'))->where('current_farm_id',$r->attributes->get('api_session')->farm_id)->findOrFail($id);
    }
}

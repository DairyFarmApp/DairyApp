<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalHealth\Models\CalfCareProfile;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\CalfCareRequest;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CalfCareController extends Controller
{
    public function __construct(private readonly IdempotencyService $idempotency, private readonly AuditService $audit) {}

    public function show(Request $r, string $animal): JsonResponse
    {
        $a = $this->calf($r, $animal);
        $p = CalfCareProfile::where('animal_id', $a->id)->first();

        return ApiResponse::success($r, $p ? $this->payload($a, $p) : null);
    }

    public function due(Request $r): JsonResponse
    {
        $o = $r->attributes->get('organization_id');
        $f = $r->attributes->get('api_session')->farm_id;
        $items = CalfCareProfile::where('organization_id', $o)->where('farm_id', $f)->whereNull('actual_weaning_date')->whereDate('weaning_target_date', '<=', today()->addDays(14))->get();

        return ApiResponse::success($r, $items->map(fn ($p) => $this->payload(Animal::find($p->animal_id), $p))->all());
    }

    public function store(CalfCareRequest $r, string $animal): JsonResponse
    {
        $a = $this->calf($r, $animal);

        return $this->idempotency->execute($r, function () use ($r, $a) {
            $d = $r->validated();
            $old = CalfCareProfile::where('animal_id', $a->id)->first();
            $p = DB::transaction(function () use ($r, $a, $d, $old) {
                $p = CalfCareProfile::updateOrCreate(['animal_id' => $a->id], [...$d, 'organization_id' => $a->organization_id, 'farm_id' => $a->current_farm_id, 'created_by' => $old?->created_by ?? $r->user()->id, 'updated_by' => $r->user()->id, 'version' => ($old?->version ?? 0) + 1]);
                $this->audit->record($r, $old ? 'calf_care.updated' : 'calf_care.created', 'calf_care_profile', $p->id, $old?->toArray(), $p->toArray());

                return $p;
            });

            return ApiResponse::success($r, $this->payload($a, $p), $old ? 200 : 201);
        });
    }

    private function calf(Request $r, string $id): Animal
    {
        $a = Animal::where('organization_id', $r->attributes->get('organization_id'))->where('current_farm_id', $r->attributes->get('api_session')->farm_id)->findOrFail($id);
        abort_if($a->life_stage !== 'calf', 422, 'Calf care is available only for animals in the calf life stage.');

        return $a;
    }

    private function payload(Animal $a, CalfCareProfile $p): array
    {
        $latest = $a->weights()->where('is_superseded', false)->latest('observed_at')->first();
        $days = max(1, $p->birth_at->diffInDays(now()));
        $gain = $latest ? round(((float) $latest->normalized_kg - (float) $p->birth_weight_kg) / $days, 3) : null;

        return [...$p->toArray(), 'animal_number' => $a->animal_number, 'colostrum_compliant' => $p->colostrum_given && $p->colostrum_at && $p->colostrum_at->lte($p->birth_at->copy()->addHours(4)), 'weaning_status' => $p->actual_weaning_date ? 'weaned' : ($p->weaning_target_date->isPast() ? 'overdue' : ($p->weaning_target_date->lte(today()->addDays(14)) ? 'upcoming' : 'scheduled')), 'current_weight_kg' => $latest?->normalized_kg, 'average_daily_gain_kg' => $gain, 'growth_status' => $gain === null ? 'insufficient_data' : ($gain + 0.001 < (float) $p->target_daily_gain_kg ? 'below_target' : 'on_target')];
    }
}

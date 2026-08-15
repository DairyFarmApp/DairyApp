<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\MilkProduction\Models\MilkEntry;
use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\MilkEntryResource;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnimalMilkEntryController extends Controller
{
    public function index(Request $request, string $animal): JsonResponse
    {
        $organizationId = (string) $request->attributes->get('organization_id');
        $farmId = $request->attributes->get('api_session')?->farm_id;
        abort_unless(is_string($farmId) && $farmId !== '', 409, 'An active farm is required.');

        $animalRecord = Animal::query()
            ->where('organization_id', $organizationId)
            ->where('current_farm_id', $farmId)
            ->findOrFail($animal);

        $entries = MilkEntry::query()
            ->with(['slot.shed', 'animal', 'recorder'])
            ->where('milk_entries.organization_id', $organizationId)
            ->where('milk_entries.farm_id', $farmId)
            ->where('milk_entries.animal_id', $animalRecord->id)
            ->where('milk_entries.is_current', true)
            ->join('milk_production_slots', 'milk_production_slots.id', '=', 'milk_entries.milk_production_slot_id')
            ->select('milk_entries.*')
            ->orderByDesc('milk_production_slots.production_date')
            ->orderByRaw("CASE milk_production_slots.session WHEN 'evening' THEN 3 WHEN 'afternoon' THEN 2 ELSE 1 END DESC")
            ->orderByDesc('milk_entries.created_at')
            ->paginate(15);

        return ApiResponse::success(
            $request,
            MilkEntryResource::collection($entries->items())->resolve($request),
            200,
            [
                'current_page' => $entries->currentPage(),
                'last_page' => $entries->lastPage(),
                'page_size' => $entries->perPage(),
                'total' => $entries->total(),
            ]
        );
    }
}

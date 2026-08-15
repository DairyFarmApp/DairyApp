<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalFeedConsumption;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\AnimalFeedConsumptionStoreRequest;
use App\Http\Resources\Api\V1\AnimalFeedConsumptionResource;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnimalFeedConsumptionController extends Controller
{
    public function index(Request $request, string $animal): JsonResponse
    {
        $organizationId = $request->attributes->get('organization_id');

        $farmId = $this->activeFarmId($request);
        $animalRecord = Animal::query()
            ->where('organization_id', $organizationId)
            ->where('current_farm_id', $farmId)
            ->findOrFail($animal);

        $consumptions = AnimalFeedConsumption::query()
            ->with(['item', 'recorder'])
            ->where('organization_id', $organizationId)
            ->where('farm_id', $farmId)
            ->where('animal_id', $animalRecord->id)
            ->orderByDesc('date')
            ->orderByDesc('created_at')
            ->paginate(15);

        return ApiResponse::success(
            $request,
            AnimalFeedConsumptionResource::collection($consumptions->items())->resolve($request),
            200,
            [
                'current_page' => $consumptions->currentPage(),
                'last_page' => $consumptions->lastPage(),
                'page_size' => $consumptions->perPage(),
                'total' => $consumptions->total(),
            ]
        );
    }

    public function store(AnimalFeedConsumptionStoreRequest $request, string $animal): JsonResponse
    {
        $organizationId = $request->attributes->get('organization_id');
        $farmId = $this->activeFarmId($request);
        $animalRecord = Animal::query()
            ->where('organization_id', $organizationId)
            ->where('current_farm_id', $farmId)
            ->findOrFail($animal);
        if ($animalRecord->operational_status !== 'active') {
            return ApiResponse::error($request, 'ANIMAL_NOT_ACTIVE', 'Only active animals can receive feed entries.', 422);
        }
        if (! $animalRecord->hasRequiredPhotos()) {
            return ApiResponse::error($request, 'ANIMAL_PHOTOS_REQUIRED', 'Upload at least four animal photos before recording feed.', 422);
        }

        $consumption = AnimalFeedConsumption::query()->create([
            'organization_id' => $organizationId,
            'farm_id' => $farmId,
            'animal_id' => $animalRecord->id,
            'inventory_item_id' => $request->validated('inventory_item_id'),
            'date' => $request->validated('date'),
            'session' => $request->validated('session'),
            'quantity' => $request->validated('quantity'),
            'unit' => $request->validated('unit'),
            'notes' => $request->validated('notes'),
            'recorded_by' => $request->user()->id,
        ]);

        $consumption->load(['item', 'recorder']);

        return ApiResponse::success(
            $request,
            (new AnimalFeedConsumptionResource($consumption))->resolve($request),
            201
        );
    }

    private function activeFarmId(Request $request): string
    {
        $farmId = $request->attributes->get('api_session')?->farm_id;
        abort_unless(is_string($farmId) && $farmId !== '', 409, 'An active farm is required.');

        return $farmId;
    }
}

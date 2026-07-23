<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalMovements\Models\AnimalMovement;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Domain\AnimalRegistry\Models\AnimalSpecies;
use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\AnimalBreedResource;
use App\Http\Resources\Api\V1\AnimalGroupResource;
use App\Http\Resources\Api\V1\AnimalMovementResource;
use App\Http\Resources\Api\V1\AnimalResource;
use App\Http\Resources\Api\V1\AnimalSpeciesResource;
use App\Http\Resources\Api\V1\FarmResource;
use App\Http\Resources\Api\V1\OrganizationResource;
use App\Http\Resources\Api\V1\ShedResource;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\Shed;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class SyncController extends Controller
{
    public function bootstrap(Request $request): JsonResponse
    {
        return $this->changesSince($request, null);
    }

    public function changes(Request $request): JsonResponse
    {
        $cursor = $request->query('cursor');
        try {
            $since = $cursor ? $this->decodeCursor((string) $cursor) : null;
        } catch (\Throwable) {
            return ApiResponse::error($request, 'INVALID_CURSOR', 'The synchronization cursor is invalid.', 400);
        }

        return $this->changesSince($request, $since);
    }

    private function changesSince(Request $request, ?Carbon $since): JsonResponse
    {
        $organizationId = $request->attributes->get('organization_id');
        $membership = $request->attributes->get('membership');
        $now = now();
        $accessibleFarmIds = $membership->all_farms
            ? Farm::withTrashed()->where('organization_id', $organizationId)->pluck('id')
            : $membership->farms()->withTrashed()->pluck('farms.id');
        $farms = Farm::withTrashed()->where('organization_id', $organizationId)->when($since, fn ($query) => $query->where('updated_at', '>=', $since))->when(! $membership->all_farms, fn ($query) => $query->whereIn('id', $membership->farms()->withTrashed()->pluck('farms.id')))->get();
        $sheds = Shed::withTrashed()->where('organization_id', $organizationId)->when($since, fn ($query) => $query->where('updated_at', '>=', $since))->when(! $membership->all_farms, fn ($query) => $query->whereIn('farm_id', $accessibleFarmIds))->get();
        $organizations = Organization::withTrashed()->whereKey($organizationId)->when($since, fn ($query) => $query->where('updated_at', '>=', $since))->get();
        $species = $membership->can('animals.view')
            ? AnimalSpecies::query()->when($since, fn ($query) => $query->where('updated_at', '>=', $since))->get()
            : collect();
        $breeds = $membership->can('animal_breeds.view')
            ? AnimalBreed::withTrashed()
                ->with('species')
                ->where('organization_id', $organizationId)
                ->when($since, fn ($query) => $query->where('updated_at', '>=', $since))
                ->get()
            : collect();
        $groups = $membership->can('animal_groups.view')
            ? AnimalGroup::withTrashed()
                ->with(['farm', 'defaultShed'])
                ->where('organization_id', $organizationId)
                ->whereIn('farm_id', $accessibleFarmIds)
                ->when($since, fn ($query) => $query->where('updated_at', '>=', $since))
                ->get()
            : collect();
        $animals = $membership->can('animals.view')
            ? Animal::withTrashed()
                ->with(['species', 'breed', 'currentFarm', 'currentShed', 'currentGroup', 'mother', 'father'])
                ->where('organization_id', $organizationId)
                ->whereIn('current_farm_id', $accessibleFarmIds)
                ->when($since, fn ($query) => $query->where('updated_at', '>=', $since))
                ->get()
            : collect();
        $movements = $membership->can('animal_movements.view')
            ? AnimalMovement::query()
                ->with([
                    'animal',
                    'sourceFarm',
                    'sourceShed',
                    'sourceGroup',
                    'destinationFarm',
                    'destinationShed',
                    'destinationGroup',
                    'requester',
                    'decisionMaker',
                ])
                ->where('organization_id', $organizationId)
                ->whereIn('source_farm_id', $accessibleFarmIds)
                ->whereIn('destination_farm_id', $accessibleFarmIds)
                ->when($since, fn ($query) => $query->where('updated_at', '>=', $since))
                ->get()
            : collect();

        return ApiResponse::success($request, [
            'organizations' => OrganizationResource::collection($organizations)->resolve($request),
            'farms' => FarmResource::collection($farms)->resolve($request),
            'sheds' => ShedResource::collection($sheds)->resolve($request),
            'animal_species' => AnimalSpeciesResource::collection($species)->resolve($request),
            'animal_breeds' => AnimalBreedResource::collection($breeds)->resolve($request),
            'animal_groups' => AnimalGroupResource::collection($groups)->resolve($request),
            'animals' => AnimalResource::collection($animals)->resolve($request),
            'animal_movements' => AnimalMovementResource::collection($movements)->resolve($request),
            'animal_movements_authorized' => $membership->can('animal_movements.view'),
            'authorized_farm_ids' => $accessibleFarmIds->values(),
            'next_cursor' => $this->encodeCursor($now->copy()->subSeconds(2)),
        ]);
    }

    private function decodeCursor(string $cursor): Carbon
    {
        $decoded = base64_decode($cursor, true);
        if (! is_string($decoded)) {
            throw new \InvalidArgumentException('Invalid base64 cursor.');
        }
        $payload = json_decode($decoded, true, flags: JSON_THROW_ON_ERROR);
        if (! is_array($payload) || ($payload['version'] ?? null) !== 1 || ! is_string($payload['since'] ?? null)) {
            throw new \InvalidArgumentException('Invalid cursor payload.');
        }

        return Carbon::parse($payload['since']);
    }

    private function encodeCursor(Carbon $since): string
    {
        return base64_encode(json_encode(['version' => 1, 'since' => $since->toISOString()], JSON_THROW_ON_ERROR));
    }
}

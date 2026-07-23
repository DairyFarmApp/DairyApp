<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Actions\ArchiveAnimalBreed;
use App\Domain\AnimalRegistry\Actions\CreateAnimalBreed;
use App\Domain\AnimalRegistry\Actions\UpdateAnimalBreed;
use App\Domain\AnimalRegistry\Queries\AnimalReferenceListQuery;
use App\Domain\AnimalRegistry\Queries\AnimalRegistryScope;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\AnimalBreedStoreRequest;
use App\Http\Requests\Api\V1\AnimalBreedUpdateRequest;
use App\Http\Requests\Api\V1\VersionedMutationRequest;
use App\Http\Resources\Api\V1\AnimalBreedResource;
use App\Support\ApiResponse;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class AnimalBreedController extends Controller
{
    public function __construct(
        private readonly AnimalRegistryScope $scope,
        private readonly AnimalReferenceListQuery $list,
        private readonly IdempotencyService $idempotency,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $items = $this->list->breeds($request);

        return ApiResponse::success($request, AnimalBreedResource::collection($items)->resolve($request), 200, ['pagination' => $this->pagination($items)]);
    }

    public function store(AnimalBreedStoreRequest $request, CreateAnimalBreed $action): JsonResponse
    {
        return $this->idempotency->execute($request, function () use ($request, $action): JsonResponse {
            $breed = $action->execute($request, $request->validated());

            return ApiResponse::success($request, (new AnimalBreedResource($breed))->resolve($request), 201);
        });
    }

    public function show(Request $request, string $breed): JsonResponse
    {
        $model = $this->scope->breed($request->attributes->get('organization_id'), $breed)->load('species');
        Gate::authorize('view', [$model, $request->attributes->get('membership')]);

        return ApiResponse::success($request, (new AnimalBreedResource($model))->resolve($request));
    }

    public function update(AnimalBreedUpdateRequest $request, string $breed, UpdateAnimalBreed $action): JsonResponse
    {
        $model = $this->scope->breed($request->attributes->get('organization_id'), $breed);
        Gate::authorize('update', [$model, $request->attributes->get('membership')]);
        $updated = $action->execute($request, $model, $request->validated());

        return ApiResponse::success($request, (new AnimalBreedResource($updated))->resolve($request));
    }

    public function destroy(VersionedMutationRequest $request, string $breed, ArchiveAnimalBreed $action): JsonResponse
    {
        $model = $this->scope->breed($request->attributes->get('organization_id'), $breed);
        Gate::authorize('archive', [$model, $request->attributes->get('membership')]);
        $archived = $action->execute($request, $model, (int) $request->validated('version'))->load('species');

        return ApiResponse::success($request, (new AnimalBreedResource($archived))->resolve($request));
    }

    private function pagination(mixed $items): array
    {
        return [
            'current_page' => $items->currentPage(),
            'last_page' => $items->lastPage(),
            'page_size' => $items->perPage(),
            'total' => $items->total(),
        ];
    }
}

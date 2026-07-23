<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Actions\ArchiveAnimal;
use App\Domain\AnimalRegistry\Actions\CreateAnimal;
use App\Domain\AnimalRegistry\Actions\RestoreAnimal;
use App\Domain\AnimalRegistry\Actions\UpdateAnimal;
use App\Domain\AnimalRegistry\Queries\AnimalListQuery;
use App\Domain\AnimalRegistry\Queries\AnimalRegistryScope;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\AnimalIndexRequest;
use App\Http\Requests\Api\V1\AnimalStoreRequest;
use App\Http\Requests\Api\V1\AnimalUpdateRequest;
use App\Http\Requests\Api\V1\VersionedMutationRequest;
use App\Http\Resources\Api\V1\AnimalResource;
use App\Support\ApiResponse;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class AnimalController extends Controller
{
    public function __construct(
        private readonly AnimalRegistryScope $scope,
        private readonly AnimalListQuery $list,
        private readonly IdempotencyService $idempotency,
    ) {}

    public function index(AnimalIndexRequest $request): JsonResponse
    {
        $items = $this->list->execute($request);

        return ApiResponse::success($request, AnimalResource::collection($items)->resolve($request), 200, ['pagination' => [
            'current_page' => $items->currentPage(),
            'last_page' => $items->lastPage(),
            'page_size' => $items->perPage(),
            'total' => $items->total(),
        ]]);
    }

    public function store(AnimalStoreRequest $request, CreateAnimal $action): JsonResponse
    {
        return $this->idempotency->execute($request, function () use ($request, $action): JsonResponse {
            $animal = $action->execute($request, $request->validated());

            return ApiResponse::success($request, (new AnimalResource($animal))->resolve($request), 201);
        });
    }

    public function show(Request $request, string $animal): JsonResponse
    {
        $model = $this->animal($request, $animal);
        Gate::authorize('view', [$model, $request->attributes->get('membership')]);

        return ApiResponse::success($request, (new AnimalResource($model))->resolve($request));
    }

    public function update(AnimalUpdateRequest $request, string $animal, UpdateAnimal $action): JsonResponse
    {
        $model = $this->animal($request, $animal);
        Gate::authorize('update', [$model, $request->attributes->get('membership')]);
        $updated = $action->execute($request, $model, $request->validated());

        return ApiResponse::success($request, (new AnimalResource($updated))->resolve($request));
    }

    public function destroy(VersionedMutationRequest $request, string $animal, ArchiveAnimal $action): JsonResponse
    {
        $model = $this->animal($request, $animal);
        Gate::authorize('archive', [$model, $request->attributes->get('membership')]);
        $archived = $action->execute($request, $model, (int) $request->validated('version'))
            ->load($this->scope->animalRelations());

        return ApiResponse::success($request, (new AnimalResource($archived))->resolve($request));
    }

    public function restore(VersionedMutationRequest $request, string $animal, RestoreAnimal $action): JsonResponse
    {
        $model = $this->animal($request, $animal);
        Gate::authorize('restore', [$model, $request->attributes->get('membership')]);
        $restored = $action->execute($request, $model, (int) $request->validated('version'))
            ->load($this->scope->animalRelations());

        return ApiResponse::success($request, (new AnimalResource($restored))->resolve($request));
    }

    private function animal(Request $request, string $id): mixed
    {
        return $this->scope->animal(
            $request->attributes->get('organization_id'),
            $request->attributes->get('membership'),
            $id,
        );
    }
}

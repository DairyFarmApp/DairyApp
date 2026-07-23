<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Actions\ArchiveAnimalGroup;
use App\Domain\AnimalRegistry\Actions\CreateAnimalGroup;
use App\Domain\AnimalRegistry\Actions\UpdateAnimalGroup;
use App\Domain\AnimalRegistry\Queries\AnimalReferenceListQuery;
use App\Domain\AnimalRegistry\Queries\AnimalRegistryScope;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\AnimalGroupStoreRequest;
use App\Http\Requests\Api\V1\AnimalGroupUpdateRequest;
use App\Http\Requests\Api\V1\VersionedMutationRequest;
use App\Http\Resources\Api\V1\AnimalGroupResource;
use App\Support\ApiResponse;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class AnimalGroupController extends Controller
{
    public function __construct(
        private readonly AnimalRegistryScope $scope,
        private readonly AnimalReferenceListQuery $list,
        private readonly IdempotencyService $idempotency,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $items = $this->list->groups($request);

        return ApiResponse::success($request, AnimalGroupResource::collection($items)->resolve($request), 200, ['pagination' => $this->pagination($items)]);
    }

    public function store(AnimalGroupStoreRequest $request, CreateAnimalGroup $action): JsonResponse
    {
        return $this->idempotency->execute($request, function () use ($request, $action): JsonResponse {
            $group = $action->execute($request, $request->validated());

            return ApiResponse::success($request, (new AnimalGroupResource($group))->resolve($request), 201);
        });
    }

    public function show(Request $request, string $group): JsonResponse
    {
        $model = $this->scope->group(
            $request->attributes->get('organization_id'),
            $request->attributes->get('membership'),
            $group,
        )->load(['farm', 'defaultShed']);
        Gate::authorize('view', [$model, $request->attributes->get('membership')]);

        return ApiResponse::success($request, (new AnimalGroupResource($model))->resolve($request));
    }

    public function update(AnimalGroupUpdateRequest $request, string $group, UpdateAnimalGroup $action): JsonResponse
    {
        $model = $this->scope->group(
            $request->attributes->get('organization_id'),
            $request->attributes->get('membership'),
            $group,
        );
        Gate::authorize('update', [$model, $request->attributes->get('membership')]);
        $updated = $action->execute($request, $model, $request->validated());

        return ApiResponse::success($request, (new AnimalGroupResource($updated))->resolve($request));
    }

    public function destroy(VersionedMutationRequest $request, string $group, ArchiveAnimalGroup $action): JsonResponse
    {
        $model = $this->scope->group(
            $request->attributes->get('organization_id'),
            $request->attributes->get('membership'),
            $group,
        );
        Gate::authorize('archive', [$model, $request->attributes->get('membership')]);
        $archived = $action->execute($request, $model, (int) $request->validated('version'))->load(['farm', 'defaultShed']);

        return ApiResponse::success($request, (new AnimalGroupResource($archived))->resolve($request));
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

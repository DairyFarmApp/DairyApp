<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalMovements\Actions\ApproveAnimalMovement;
use App\Domain\AnimalMovements\Actions\CancelAnimalMovement;
use App\Domain\AnimalMovements\Actions\RejectAnimalMovement;
use App\Domain\AnimalMovements\Actions\RequestAnimalMovement;
use App\Domain\AnimalMovements\Queries\AnimalMovementListQuery;
use App\Domain\AnimalMovements\Queries\AnimalMovementScope;
use App\Domain\AnimalRegistry\Queries\AnimalRegistryScope;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\AnimalMovementIndexRequest;
use App\Http\Requests\Api\V1\AnimalMovementReasonRequest;
use App\Http\Requests\Api\V1\AnimalMovementStoreRequest;
use App\Http\Requests\Api\V1\AnimalMovementVersionRequest;
use App\Http\Resources\Api\V1\AnimalMovementResource;
use App\Support\ApiResponse;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class AnimalMovementController extends Controller
{
    public function __construct(
        private readonly AnimalRegistryScope $animals,
        private readonly AnimalMovementScope $movements,
        private readonly AnimalMovementListQuery $list,
        private readonly IdempotencyService $idempotency,
    ) {}

    public function index(AnimalMovementIndexRequest $request, string $animal): JsonResponse
    {
        $animalModel = $this->animal($request, $animal);
        Gate::authorize('view', [$animalModel, $request->attributes->get('membership')]);
        $items = $this->list->execute($request, $animalModel->id);

        return ApiResponse::success(
            $request,
            AnimalMovementResource::collection($items)->resolve($request),
            200,
            ['pagination' => [
                'current_page' => $items->currentPage(),
                'last_page' => $items->lastPage(),
                'page_size' => $items->perPage(),
                'total' => $items->total(),
            ]],
        );
    }

    public function store(
        AnimalMovementStoreRequest $request,
        string $animal,
        RequestAnimalMovement $action,
    ): JsonResponse {
        $animalModel = $this->animal($request, $animal);
        Gate::authorize('move', [$animalModel, $request->attributes->get('membership')]);

        return $this->idempotency->execute($request, function () use ($request, $action, $animalModel): JsonResponse {
            $movement = $action->execute($request, $animalModel, $request->validated());

            return ApiResponse::success(
                $request,
                (new AnimalMovementResource($movement))->resolve($request),
                201,
            );
        });
    }

    public function show(Request $request, string $movement): JsonResponse
    {
        $model = $this->movement($request, $movement);
        Gate::authorize('view', [$model, $request->attributes->get('membership')]);

        return ApiResponse::success(
            $request,
            (new AnimalMovementResource($model))->resolve($request),
        );
    }

    public function approve(
        AnimalMovementVersionRequest $request,
        string $movement,
        ApproveAnimalMovement $action,
    ): JsonResponse {
        $model = $this->movement($request, $movement);
        Gate::authorize('approve', [$model, $request->attributes->get('membership')]);

        return $this->idempotency->execute($request, function () use ($request, $model, $action): JsonResponse {
            $updated = $action->execute($request, $model, (int) $request->validated('version'));

            return ApiResponse::success(
                $request,
                (new AnimalMovementResource($updated))->resolve($request),
            );
        });
    }

    public function reject(
        AnimalMovementReasonRequest $request,
        string $movement,
        RejectAnimalMovement $action,
    ): JsonResponse {
        $model = $this->movement($request, $movement);
        Gate::authorize('reject', [$model, $request->attributes->get('membership')]);

        return $this->idempotency->execute($request, function () use ($request, $model, $action): JsonResponse {
            $updated = $action->execute(
                $request,
                $model,
                (int) $request->validated('version'),
                $request->validated('reason'),
            );

            return ApiResponse::success(
                $request,
                (new AnimalMovementResource($updated))->resolve($request),
            );
        });
    }

    public function cancel(
        AnimalMovementReasonRequest $request,
        string $movement,
        CancelAnimalMovement $action,
    ): JsonResponse {
        $model = $this->movement($request, $movement);
        Gate::authorize('cancel', [$model, $request->attributes->get('membership')]);

        return $this->idempotency->execute($request, function () use ($request, $model, $action): JsonResponse {
            $updated = $action->execute(
                $request,
                $model,
                (int) $request->validated('version'),
                $request->validated('reason'),
            );

            return ApiResponse::success(
                $request,
                (new AnimalMovementResource($updated))->resolve($request),
            );
        });
    }

    private function animal(Request $request, string $id): mixed
    {
        return $this->animals->animal(
            $request->attributes->get('organization_id'),
            $request->attributes->get('membership'),
            $id,
        );
    }

    private function movement(Request $request, string $id): mixed
    {
        return $this->movements->movement(
            $request->attributes->get('organization_id'),
            $request->attributes->get('membership'),
            $id,
        );
    }
}

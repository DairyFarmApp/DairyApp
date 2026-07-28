<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Queries\AnimalRegistryScope;
use App\Domain\AnimalWeights\Actions\CorrectAnimalWeight;
use App\Domain\AnimalWeights\Actions\RecordAnimalWeight;
use App\Domain\AnimalWeights\Queries\AnimalWeightListQuery;
use App\Domain\AnimalWeights\Queries\AnimalWeightScope;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\AnimalWeightCorrectionRequest;
use App\Http\Requests\Api\V1\AnimalWeightIndexRequest;
use App\Http\Requests\Api\V1\AnimalWeightStoreRequest;
use App\Http\Resources\Api\V1\AnimalWeightResource;
use App\Support\ApiResponse;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class AnimalWeightController extends Controller
{
    public function __construct(
        private readonly AnimalRegistryScope $animals,
        private readonly AnimalWeightScope $weights,
        private readonly AnimalWeightListQuery $list,
        private readonly IdempotencyService $idempotency,
    ) {}

    public function index(AnimalWeightIndexRequest $request, string $animal): JsonResponse
    {
        $animalModel = $this->animal($request, $animal);
        Gate::authorize('viewWeightHistory', [$animalModel, $request->attributes->get('membership')]);
        $items = $this->list->execute($request, $animalModel->id);

        return ApiResponse::success(
            $request,
            AnimalWeightResource::collection($items)->resolve($request),
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
        AnimalWeightStoreRequest $request,
        string $animal,
        RecordAnimalWeight $action,
    ): JsonResponse {
        $animalModel = $this->animal($request, $animal);
        Gate::authorize('recordWeight', [$animalModel, $request->attributes->get('membership')]);

        return $this->idempotency->execute($request, function () use ($request, $animalModel, $action): JsonResponse {
            $weight = $action->execute($request, $animalModel, $request->validated());

            return ApiResponse::success(
                $request,
                (new AnimalWeightResource($weight))->resolve($request),
                201,
            );
        });
    }

    public function show(Request $request, string $weight): JsonResponse
    {
        $model = $this->weight($request, $weight);
        Gate::authorize('view', [$model, $request->attributes->get('membership')]);

        return ApiResponse::success(
            $request,
            (new AnimalWeightResource($model))->resolve($request),
        );
    }

    public function correct(
        AnimalWeightCorrectionRequest $request,
        string $weight,
        CorrectAnimalWeight $action,
    ): JsonResponse {
        $model = $this->weight($request, $weight);
        Gate::authorize('correct', [$model, $request->attributes->get('membership')]);

        return $this->idempotency->execute($request, function () use ($request, $model, $action): JsonResponse {
            $replacement = $action->execute($request, $model, $request->validated());

            return ApiResponse::success(
                $request,
                (new AnimalWeightResource($replacement))->resolve($request),
                201,
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

    private function weight(Request $request, string $id): mixed
    {
        return $this->weights->weight(
            $request->attributes->get('organization_id'),
            $request->attributes->get('membership'),
            $id,
        );
    }
}

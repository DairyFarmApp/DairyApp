<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Queries\AnimalRegistryScope;
use App\Domain\AnimalStatuses\Actions\ChangeAnimalStatus;
use App\Domain\AnimalStatuses\Queries\AnimalStatusChangeListQuery;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\AnimalStatusChangeRequest;
use App\Http\Requests\Api\V1\AnimalStatusHistoryIndexRequest;
use App\Http\Resources\Api\V1\AnimalStatusChangeResource;
use App\Support\ApiResponse;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class AnimalStatusController extends Controller
{
    public function __construct(
        private readonly AnimalRegistryScope $animals,
        private readonly AnimalStatusChangeListQuery $list,
        private readonly IdempotencyService $idempotency,
    ) {}

    public function index(AnimalStatusHistoryIndexRequest $request, string $animal): JsonResponse
    {
        $animalModel = $this->animal($request, $animal);
        Gate::authorize('viewStatusHistory', [$animalModel, $request->attributes->get('membership')]);
        $items = $this->list->execute($request, $animalModel->id);

        return ApiResponse::success(
            $request,
            AnimalStatusChangeResource::collection($items)->resolve($request),
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
        AnimalStatusChangeRequest $request,
        string $animal,
        ChangeAnimalStatus $action,
    ): JsonResponse {
        $animalModel = $this->animal($request, $animal);
        Gate::authorize('changeStatus', [$animalModel, $request->attributes->get('membership')]);

        return $this->idempotency->execute($request, function () use ($request, $animalModel, $action): JsonResponse {
            $change = $action->execute($request, $animalModel, $request->validated());

            return ApiResponse::success(
                $request,
                (new AnimalStatusChangeResource($change))->resolve($request),
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
}

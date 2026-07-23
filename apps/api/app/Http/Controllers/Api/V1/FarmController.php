<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\FarmRequest;
use App\Http\Resources\Api\V1\FarmResource;
use App\Models\Farm;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class FarmController extends Controller
{
    public function __construct(private readonly AuditService $audit, private readonly IdempotencyService $idempotency) {}

    public function index(Request $request): JsonResponse
    {
        $membership = $request->attributes->get('membership');
        $query = Farm::query()->where('organization_id', $request->attributes->get('organization_id'));
        if (! $membership->all_farms) {
            $query->whereIn('id', $membership->farms()->pluck('farms.id'));
        }
        $items = $query->orderBy('name')->cursorPaginate(min((int) $request->input('page.size', 50), 100));

        return ApiResponse::success($request, FarmResource::collection($items)->resolve($request), 200, ['pagination' => ['next_cursor' => $items->nextCursor()?->encode(), 'has_more' => $items->hasMorePages(), 'page_size' => $items->perPage()]]);
    }

    public function store(FarmRequest $request): JsonResponse
    {
        return $this->idempotency->execute($request, function () use ($request): JsonResponse {
            $data = $request->validated();
            $farm = Farm::create(['id' => $data['id'] ?? (string) Str::uuid7(), 'organization_id' => $request->attributes->get('organization_id'), 'name' => $data['name'], 'code' => $data['code'] ?? strtoupper(Str::slug($data['name'], '-')), 'timezone' => $data['timezone'], 'version' => 1]);
            $membership = $request->attributes->get('membership');
            if (! $membership->all_farms) {
                $membership->farms()->syncWithoutDetaching([
                    $farm->id => ['organization_id' => $request->attributes->get('organization_id')],
                ]);
            }
            $this->audit->record($request, 'farm.created', 'farm', $farm->id, null, $farm->toArray());

            return ApiResponse::success($request, (new FarmResource($farm))->resolve($request), 201);
        });
    }

    public function show(Request $request, string $farm): JsonResponse
    {
        $model = $this->farm($request, $farm);

        return ApiResponse::success($request, (new FarmResource($model))->resolve($request));
    }

    public function update(FarmRequest $request, string $farm): JsonResponse
    {
        $model = $this->farm($request, $farm);
        $data = $request->validated();
        $old = $model->toArray();
        DB::transaction(function () use ($model, $data, $request, $old): void {
            $model->fill($data);
            $model->version++;
            $model->save();
            $this->audit->record($request, 'farm.updated', 'farm', $model->id, $old, $model->toArray());
        });

        return ApiResponse::success($request, (new FarmResource($model))->resolve($request));
    }

    public function destroy(Request $request, string $farm): JsonResponse
    {
        $model = $this->farm($request, $farm);
        DB::transaction(function () use ($model, $request): void {
            $model->delete();
            $this->audit->record($request, 'farm.archived', 'farm', $model->id, $model->toArray(), ['archived' => true]);
        });

        return ApiResponse::success($request, ['archived' => true]);
    }

    private function farm(Request $request, string $id): Farm
    {
        $farm = Farm::query()->where('organization_id', $request->attributes->get('organization_id'))->findOrFail($id);
        abort_unless($request->attributes->get('membership')->canAccessFarm($farm->id), 404);

        return $farm;
    }
}

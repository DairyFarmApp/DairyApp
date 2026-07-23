<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\ShedRequest;
use App\Http\Resources\Api\V1\ShedResource;
use App\Models\Farm;
use App\Models\Shed;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ShedController extends Controller
{
    public function __construct(private readonly AuditService $audit, private readonly IdempotencyService $idempotency) {}

    public function index(Request $request, string $farm): JsonResponse
    {
        $farmModel = $this->farm($request, $farm);
        $items = Shed::query()->where('organization_id', $farmModel->organization_id)->where('farm_id', $farmModel->id)->orderBy('name')->cursorPaginate(min((int) $request->input('page.size', 50), 100));

        return ApiResponse::success($request, ShedResource::collection($items)->resolve($request), 200, ['pagination' => ['next_cursor' => $items->nextCursor()?->encode(), 'has_more' => $items->hasMorePages(), 'page_size' => $items->perPage()]]);
    }

    public function store(ShedRequest $request, string $farm): JsonResponse
    {
        $farmModel = $this->farm($request, $farm);

        return $this->idempotency->execute($request, function () use ($request, $farmModel): JsonResponse {
            $data = $request->validated();
            $shed = Shed::create(['id' => $data['id'] ?? (string) Str::uuid7(), 'organization_id' => $farmModel->organization_id, 'farm_id' => $farmModel->id, 'name' => $data['name'], 'code' => $data['code'] ?? strtoupper(Str::slug($data['name'], '-')), 'version' => 1]);
            $this->audit->record($request, 'shed.created', 'shed', $shed->id, null, $shed->toArray());

            return ApiResponse::success($request, (new ShedResource($shed))->resolve($request), 201);
        });
    }

    public function show(Request $request, string $shed): JsonResponse
    {
        $model = $this->shed($request, $shed);

        return ApiResponse::success($request, (new ShedResource($model))->resolve($request));
    }

    public function update(ShedRequest $request, string $shed): JsonResponse
    {
        $model = $this->shed($request, $shed);
        $data = $request->validated();
        $old = $model->toArray();
        DB::transaction(function () use ($model, $data, $request, $old): void {
            $model->fill($data);
            $model->version++;
            $model->save();
            $this->audit->record($request, 'shed.updated', 'shed', $model->id, $old, $model->toArray());
        });

        return ApiResponse::success($request, (new ShedResource($model))->resolve($request));
    }

    public function destroy(Request $request, string $shed): JsonResponse
    {
        $model = $this->shed($request, $shed);
        DB::transaction(function () use ($model, $request): void {
            $model->delete();
            $this->audit->record($request, 'shed.archived', 'shed', $model->id, $model->toArray(), ['archived' => true]);
        });

        return ApiResponse::success($request, ['archived' => true]);
    }

    private function farm(Request $request, string $id): Farm
    {
        $farm = Farm::query()->where('organization_id', $request->attributes->get('organization_id'))->findOrFail($id);
        abort_unless($request->attributes->get('membership')->canAccessFarm($farm->id), 404);

        return $farm;
    }

    private function shed(Request $request, string $id): Shed
    {
        $shed = Shed::query()->where('organization_id', $request->attributes->get('organization_id'))->findOrFail($id);
        abort_unless($request->attributes->get('membership')->canAccessFarm($shed->farm_id), 404);

        return $shed;
    }
}

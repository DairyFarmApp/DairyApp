<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\OrganizationResource;
use App\Models\Organization;
use App\Support\ApiResponse;
use App\Support\AuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrganizationController extends Controller
{
    public function __construct(private readonly AuditService $audit) {}

    public function index(Request $request): JsonResponse
    {
        $items = Organization::query()->whereHas('memberships', fn ($query) => $query->where('user_id', $request->user()->id)->where('status', 'active'))->orderBy('name')->get();

        return ApiResponse::success($request, OrganizationResource::collection($items)->resolve($request));
    }

    public function show(Request $request, string $organization): JsonResponse
    {
        abort_unless($organization === $request->attributes->get('organization_id'), 404);
        $model = Organization::query()->findOrFail($organization);

        return ApiResponse::success($request, (new OrganizationResource($model))->resolve($request));
    }

    public function update(Request $request, string $organization): JsonResponse
    {
        abort_unless($organization === $request->attributes->get('organization_id'), 404);
        $validated = $request->validate(['name' => ['sometimes', 'string', 'max:160'], 'timezone' => ['sometimes', 'timezone'], 'locale' => ['sometimes', 'string', 'max:10']]);
        $model = Organization::query()->findOrFail($organization);
        $old = $model->only(array_keys($validated));
        DB::transaction(function () use ($model, $validated, $request, $old): void {
            $model->fill($validated);
            $model->version++;
            $model->save();
            $this->audit->record($request, 'organization.updated', 'organization', $model->id, $old, $model->only(array_keys($validated)));
        });

        return ApiResponse::success($request, (new OrganizationResource($model))->resolve($request));
    }
}

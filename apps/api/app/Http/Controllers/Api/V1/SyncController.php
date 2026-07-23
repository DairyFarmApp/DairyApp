<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
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

        return ApiResponse::success($request, ['organizations' => OrganizationResource::collection($organizations)->resolve($request), 'farms' => FarmResource::collection($farms)->resolve($request), 'sheds' => ShedResource::collection($sheds)->resolve($request), 'authorized_farm_ids' => $accessibleFarmIds->values(), 'next_cursor' => $this->encodeCursor($now->copy()->subSeconds(2))]);
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

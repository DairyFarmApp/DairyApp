<?php

namespace App\Support;

use App\Models\ApiSession;
use App\Models\Farm;
use App\Models\OrganizationMembership;

final class SessionPayload
{
    public function make(ApiSession $session, array $tokens = []): array
    {
        $memberships = OrganizationMembership::query()->with('organization')->where('user_id', $session->user_id)->where('status', 'active')->get();
        $active = $memberships->firstWhere('organization_id', $session->organization_id);
        $farms = collect();
        if ($active) {
            $farms = Farm::query()->where('organization_id', $active->organization_id)
                ->when(! $active->all_farms, fn ($query) => $query->whereIn('id', $active->farms()->pluck('farms.id')))
                ->orderBy('name')->get();
        }

        return [
            ...$tokens,
            'user' => [
                'id' => $session->user->id,
                'name' => $session->user->name,
                'email' => $session->user->email,
                'phone_number' => $session->user->phone_number,
                'has_profile_photo' => $session->user->profile_photo_path !== null,
            ],
            'organizations' => $memberships->map(fn ($membership) => ['id' => $membership->organization->id, 'name' => $membership->organization->name])->values(),
            'farms' => $farms->map(fn ($farm) => ['id' => $farm->id, 'organization_id' => $farm->organization_id, 'name' => $farm->name])->values(),
            'permissions' => $active?->permissions() ?? [],
            'active_organization_id' => $session->organization_id,
            'active_farm_id' => $session->farm_id,
            'active_membership_type' => $active?->membership_type,
        ];
    }
}

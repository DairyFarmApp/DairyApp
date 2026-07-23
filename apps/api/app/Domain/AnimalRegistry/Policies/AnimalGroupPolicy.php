<?php

namespace App\Domain\AnimalRegistry\Policies;

use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Models\OrganizationMembership;
use App\Models\User;

class AnimalGroupPolicy
{
    public function view(User $user, AnimalGroup $group, OrganizationMembership $membership): bool
    {
        return $this->belongsTo($user, $membership, $group)
            && $membership->can('animal_groups.view')
            && $membership->canAccessFarm($group->farm_id);
    }

    public function update(User $user, AnimalGroup $group, OrganizationMembership $membership): bool
    {
        return $this->belongsTo($user, $membership, $group)
            && $membership->can('animal_groups.manage')
            && $membership->canAccessFarm($group->farm_id);
    }

    public function archive(User $user, AnimalGroup $group, OrganizationMembership $membership): bool
    {
        return $this->update($user, $group, $membership);
    }

    private function belongsTo(User $user, OrganizationMembership $membership, AnimalGroup $group): bool
    {
        return $membership->user_id === $user->id && $membership->organization_id === $group->organization_id;
    }
}

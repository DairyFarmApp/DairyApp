<?php

namespace App\Domain\AnimalRegistry\Policies;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Models\OrganizationMembership;
use App\Models\User;

class AnimalPolicy
{
    public function view(User $user, Animal $animal, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $animal)
            && $membership->can('animals.view');
    }

    public function update(User $user, Animal $animal, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $animal)
            && $membership->can('animals.update');
    }

    public function archive(User $user, Animal $animal, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $animal)
            && $membership->can('animals.archive');
    }

    public function restore(User $user, Animal $animal, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $animal)
            && $membership->can('animals.restore');
    }

    private function inScope(User $user, OrganizationMembership $membership, Animal $animal): bool
    {
        return $membership->user_id === $user->id
            && $membership->organization_id === $animal->organization_id
            && $membership->canAccessFarm($animal->current_farm_id);
    }
}

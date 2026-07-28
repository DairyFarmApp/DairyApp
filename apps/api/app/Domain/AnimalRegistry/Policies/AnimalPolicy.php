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

    public function move(User $user, Animal $animal, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $animal)
            && $membership->can('animals.move');
    }

    public function recordWeight(User $user, Animal $animal, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $animal)
            && $membership->can('animals.record_weight');
    }

    public function viewWeightHistory(User $user, Animal $animal, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $animal)
            && $membership->can('animals.view_weight_history');
    }

    public function changeStatus(User $user, Animal $animal, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $animal)
            && $membership->can('animals.change_status');
    }

    public function viewStatusHistory(User $user, Animal $animal, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $animal)
            && $membership->can('animals.view_status_history');
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

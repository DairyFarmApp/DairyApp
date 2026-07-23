<?php

namespace App\Domain\AnimalMovements\Policies;

use App\Domain\AnimalMovements\Models\AnimalMovement;
use App\Models\OrganizationMembership;
use App\Models\User;

class AnimalMovementPolicy
{
    public function view(User $user, AnimalMovement $movement, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $movement)
            && $membership->can('animal_movements.view');
    }

    public function approve(User $user, AnimalMovement $movement, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $movement)
            && $membership->can('animal_movements.approve');
    }

    public function reject(User $user, AnimalMovement $movement, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $movement)
            && $membership->can('animal_movements.reject');
    }

    public function cancel(User $user, AnimalMovement $movement, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $movement)
            && $membership->can('animal_movements.cancel');
    }

    private function inScope(
        User $user,
        OrganizationMembership $membership,
        AnimalMovement $movement,
    ): bool {
        return $membership->user_id === $user->id
            && $membership->organization_id === $movement->organization_id
            && $membership->canAccessFarm($movement->source_farm_id)
            && $membership->canAccessFarm($movement->destination_farm_id);
    }
}

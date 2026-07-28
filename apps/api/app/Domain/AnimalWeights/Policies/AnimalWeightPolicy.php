<?php

namespace App\Domain\AnimalWeights\Policies;

use App\Domain\AnimalWeights\Models\AnimalWeight;
use App\Models\OrganizationMembership;
use App\Models\User;

class AnimalWeightPolicy
{
    public function view(User $user, AnimalWeight $weight, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $weight)
            && $membership->can('animals.view_weight_history');
    }

    public function correct(User $user, AnimalWeight $weight, OrganizationMembership $membership): bool
    {
        return $this->inScope($user, $membership, $weight)
            && $membership->can('animals.correct_weight');
    }

    private function inScope(
        User $user,
        OrganizationMembership $membership,
        AnimalWeight $weight,
    ): bool {
        return $membership->user_id === $user->id
            && $membership->organization_id === $weight->organization_id
            && $membership->canAccessFarm($weight->farm_id)
            && $membership->canAccessFarm($weight->animal->current_farm_id);
    }
}

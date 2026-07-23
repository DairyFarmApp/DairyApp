<?php

namespace App\Domain\AnimalRegistry\Policies;

use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Models\OrganizationMembership;
use App\Models\User;

class AnimalBreedPolicy
{
    public function view(User $user, AnimalBreed $breed, OrganizationMembership $membership): bool
    {
        return $this->belongsTo($user, $membership, $breed->organization_id)
            && $membership->can('animal_breeds.view');
    }

    public function update(User $user, AnimalBreed $breed, OrganizationMembership $membership): bool
    {
        return $this->belongsTo($user, $membership, $breed->organization_id)
            && $membership->can('animal_breeds.manage');
    }

    public function archive(User $user, AnimalBreed $breed, OrganizationMembership $membership): bool
    {
        return $this->update($user, $breed, $membership);
    }

    private function belongsTo(User $user, OrganizationMembership $membership, string $organizationId): bool
    {
        return $membership->user_id === $user->id && $membership->organization_id === $organizationId;
    }
}

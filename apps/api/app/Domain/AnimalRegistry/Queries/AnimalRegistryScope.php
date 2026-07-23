<?php

namespace App\Domain\AnimalRegistry\Queries;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Models\OrganizationMembership;
use Illuminate\Database\Eloquent\Builder;

final class AnimalRegistryScope
{
    public function breed(string $organizationId, string $id): AnimalBreed
    {
        return AnimalBreed::withTrashed()
            ->where('organization_id', $organizationId)
            ->findOrFail($id);
    }

    public function group(string $organizationId, OrganizationMembership $membership, string $id): AnimalGroup
    {
        $group = AnimalGroup::withTrashed()
            ->where('organization_id', $organizationId)
            ->findOrFail($id);
        abort_unless($membership->canAccessFarm($group->farm_id), 404);

        return $group;
    }

    public function animal(string $organizationId, OrganizationMembership $membership, string $id): Animal
    {
        $animal = Animal::withTrashed()
            ->with($this->animalRelations())
            ->where('organization_id', $organizationId)
            ->findOrFail($id);
        abort_unless($membership->canAccessFarm($animal->current_farm_id), 404);

        return $animal;
    }

    public function breeds(string $organizationId): Builder
    {
        return AnimalBreed::query()
            ->with('species')
            ->where('organization_id', $organizationId);
    }

    public function groups(string $organizationId, OrganizationMembership $membership): Builder
    {
        return AnimalGroup::query()
            ->with(['farm', 'defaultShed'])
            ->where('organization_id', $organizationId)
            ->when(! $membership->all_farms, fn (Builder $query) => $query->whereIn('farm_id', $membership->farms()->pluck('farms.id')));
    }

    public function animals(string $organizationId, OrganizationMembership $membership): Builder
    {
        return Animal::query()
            ->with($this->animalRelations())
            ->where('organization_id', $organizationId)
            ->when(! $membership->all_farms, fn (Builder $query) => $query->whereIn('current_farm_id', $membership->farms()->pluck('farms.id')));
    }

    /**
     * @return array<int, string>
     */
    public function animalRelations(): array
    {
        return ['species', 'breed', 'currentFarm', 'currentShed', 'currentGroup', 'mother', 'father'];
    }
}

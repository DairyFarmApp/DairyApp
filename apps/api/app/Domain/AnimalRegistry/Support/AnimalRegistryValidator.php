<?php

namespace App\Domain\AnimalRegistry\Support;

use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Domain\AnimalRegistry\Models\AnimalSpecies;
use App\Models\Farm;
use App\Models\OrganizationMembership;
use App\Models\Shed;
use Illuminate\Validation\ValidationException;

final class AnimalRegistryValidator
{
    public function classification(string $organizationId, string $speciesId, string $breedId, bool $requireActive = true): void
    {
        $species = AnimalSpecies::query()->find($speciesId);
        if (! $species || ($requireActive && ! $species->is_active)) {
            throw ValidationException::withMessages(['species_id' => ['The selected species is invalid.']]);
        }
        $breedQuery = AnimalBreed::withTrashed()
            ->where('organization_id', $organizationId)
            ->where('species_id', $speciesId);
        if ($requireActive) {
            $breedQuery->whereNull('deleted_at')->where('is_active', true);
        }
        if (! $breedQuery->find($breedId)) {
            throw ValidationException::withMessages(['breed_id' => ['The selected breed is invalid.']]);
        }
    }

    public function location(
        string $organizationId,
        OrganizationMembership $membership,
        string $farmId,
        string $shedId,
        ?string $groupId,
    ): void {
        $farm = Farm::query()->where('organization_id', $organizationId)->find($farmId);
        if (! $farm || ! $membership->canAccessFarm($farmId)) {
            throw ValidationException::withMessages(['current_farm_id' => ['The selected farm is invalid.']]);
        }
        $shed = Shed::query()
            ->where('organization_id', $organizationId)
            ->where('farm_id', $farmId)
            ->find($shedId);
        if (! $shed) {
            throw ValidationException::withMessages(['current_shed_id' => ['The selected shed is invalid.']]);
        }
        if ($groupId !== null) {
            $group = AnimalGroup::query()
                ->where('organization_id', $organizationId)
                ->where('farm_id', $farmId)
                ->find($groupId);
            if (! $group) {
                throw ValidationException::withMessages(['current_animal_group_id' => ['The selected animal group is invalid.']]);
            }
        }
    }

    public function groupLocation(
        string $organizationId,
        OrganizationMembership $membership,
        string $farmId,
        ?string $shedId,
    ): void {
        $farm = Farm::query()->where('organization_id', $organizationId)->find($farmId);
        if (! $farm || ! $membership->canAccessFarm($farmId)) {
            throw ValidationException::withMessages(['farm_id' => ['The selected farm is invalid.']]);
        }
        if ($shedId !== null && ! Shed::query()
            ->where('organization_id', $organizationId)
            ->where('farm_id', $farmId)
            ->whereKey($shedId)
            ->exists()) {
            throw ValidationException::withMessages(['default_shed_id' => ['The selected default shed is invalid.']]);
        }
    }
}

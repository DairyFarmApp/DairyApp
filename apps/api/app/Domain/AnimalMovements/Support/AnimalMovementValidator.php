<?php

namespace App\Domain\AnimalMovements\Support;

use App\Domain\AnimalMovements\Exceptions\AnimalMovementConflict;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Models\Farm;
use App\Models\OrganizationMembership;
use App\Models\Shed;
use Illuminate\Validation\ValidationException;

final class AnimalMovementValidator
{
    public function sourceSnapshot(Animal $animal, array $data): void
    {
        if (
            $animal->current_farm_id !== $data['source_farm_id']
            || $animal->current_shed_id !== $data['source_shed_id']
            || $animal->current_animal_group_id !== ($data['source_animal_group_id'] ?? null)
        ) {
            throw new AnimalMovementConflict(
                'SOURCE_LOCATION_CHANGED',
                'The animal location changed before the movement was submitted.',
                ['current_animal_version' => $animal->version],
            );
        }
    }

    public function destination(
        Animal $animal,
        OrganizationMembership $membership,
        string $farmId,
        string $shedId,
        ?string $groupId,
    ): void {
        $farm = Farm::query()
            ->where('organization_id', $animal->organization_id)
            ->find($farmId);
        if (! $farm || ! $membership->canAccessFarm($farmId)) {
            throw ValidationException::withMessages([
                'destination_farm_id' => ['The selected destination farm is invalid.'],
            ]);
        }
        $shed = Shed::query()
            ->where('organization_id', $animal->organization_id)
            ->where('farm_id', $farmId)
            ->find($shedId);
        if (! $shed) {
            throw ValidationException::withMessages([
                'destination_shed_id' => ['The selected destination shed is invalid.'],
            ]);
        }
        if ($groupId !== null && ! AnimalGroup::query()
            ->where('organization_id', $animal->organization_id)
            ->where('farm_id', $farmId)
            ->whereKey($groupId)
            ->exists()) {
            throw ValidationException::withMessages([
                'destination_animal_group_id' => ['The selected destination animal group is invalid.'],
            ]);
        }
        if (
            $animal->current_farm_id === $farmId
            && $animal->current_shed_id === $shedId
            && $animal->current_animal_group_id === $groupId
        ) {
            throw ValidationException::withMessages([
                'destination_farm_id' => ['The destination must differ from the current animal location.'],
            ]);
        }
    }
}

<?php

namespace App\Domain\AnimalMovements\Queries;

use App\Domain\AnimalMovements\Models\AnimalMovement;
use App\Models\OrganizationMembership;

final class AnimalMovementScope
{
    public function movement(
        string $organizationId,
        OrganizationMembership $membership,
        string $id,
    ): AnimalMovement {
        $movement = AnimalMovement::query()
            ->with($this->relations())
            ->where('organization_id', $organizationId)
            ->findOrFail($id);
        abort_unless(
            $membership->canAccessFarm($movement->source_farm_id)
            && $membership->canAccessFarm($movement->destination_farm_id),
            404,
        );

        return $movement;
    }

    /**
     * @return array<int, string>
     */
    public function relations(): array
    {
        return [
            'animal',
            'sourceFarm',
            'sourceShed',
            'sourceGroup',
            'destinationFarm',
            'destinationShed',
            'destinationGroup',
            'requester',
            'decisionMaker',
        ];
    }
}

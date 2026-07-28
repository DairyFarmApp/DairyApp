<?php

namespace App\Domain\AnimalWeights\Queries;

use App\Domain\AnimalWeights\Models\AnimalWeight;
use App\Models\OrganizationMembership;

final class AnimalWeightScope
{
    public function weight(
        string $organizationId,
        OrganizationMembership $membership,
        string $id,
    ): AnimalWeight {
        $weight = AnimalWeight::query()
            ->with($this->relations())
            ->where('organization_id', $organizationId)
            ->findOrFail($id);
        abort_unless(
            $membership->canAccessFarm($weight->farm_id)
                && $membership->canAccessFarm($weight->animal->current_farm_id),
            404,
        );

        return $weight;
    }

    /**
     * @return array<int, string>
     */
    public function relations(): array
    {
        return ['animal', 'farm', 'recorder', 'supersedes', 'supersededBy'];
    }
}

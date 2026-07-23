<?php

namespace App\Domain\AnimalMovements\Support;

use App\Domain\AnimalMovements\Exceptions\AnimalMovementConflict;
use App\Domain\AnimalMovements\Models\AnimalMovement;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Support\AuditService;
use Illuminate\Http\Request;

final class ApplyAnimalMovement
{
    public function __construct(private readonly AuditService $audit) {}

    public function execute(Request $request, AnimalMovement $movement, Animal $animal): AnimalMovement
    {
        if (
            $animal->current_farm_id !== $movement->source_farm_id
            || $animal->current_shed_id !== $movement->source_shed_id
            || $animal->current_animal_group_id !== $movement->source_animal_group_id
        ) {
            throw new AnimalMovementConflict(
                'STALE_MOVEMENT',
                'The animal has already moved from the recorded source location.',
                ['current_animal_version' => $animal->version],
            );
        }

        $oldLocation = [
            'farm_id' => $animal->current_farm_id,
            'shed_id' => $animal->current_shed_id,
            'animal_group_id' => $animal->current_animal_group_id,
            'version' => $animal->version,
        ];
        $oldMovement = $movement->toArray();
        $now = now();
        $animal->forceFill([
            'current_farm_id' => $movement->destination_farm_id,
            'current_shed_id' => $movement->destination_shed_id,
            'current_animal_group_id' => $movement->destination_animal_group_id,
            'updated_by' => $request->user()->id,
            'version' => $animal->version + 1,
        ])->save();
        $movement->forceFill([
            'status' => 'approved',
            'actual_effective_at' => $now,
            'decided_by' => $request->user()->id,
            'decision_at' => $now,
            'version' => $movement->version + 1,
        ])->save();
        $this->audit->record(
            $request,
            'animal.movement_approved',
            'animal_movement',
            $movement->id,
            $oldMovement,
            $movement->toArray(),
        );
        $this->audit->record(
            $request,
            'animal.location_changed',
            'animal',
            $animal->id,
            $oldLocation,
            [
                'farm_id' => $animal->current_farm_id,
                'shed_id' => $animal->current_shed_id,
                'animal_group_id' => $animal->current_animal_group_id,
                'version' => $animal->version,
                'movement_id' => $movement->id,
            ],
        );

        return $movement;
    }
}

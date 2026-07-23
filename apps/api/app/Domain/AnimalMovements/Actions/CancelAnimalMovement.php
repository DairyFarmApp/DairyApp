<?php

namespace App\Domain\AnimalMovements\Actions;

use App\Domain\AnimalMovements\Exceptions\AnimalMovementConflict;
use App\Domain\AnimalMovements\Exceptions\StaleAnimalMovementVersion;
use App\Domain\AnimalMovements\Models\AnimalMovement;
use App\Domain\AnimalMovements\Queries\AnimalMovementScope;
use App\Support\AuditService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class CancelAnimalMovement
{
    public function __construct(
        private readonly AnimalMovementScope $scope,
        private readonly AuditService $audit,
    ) {}

    public function execute(
        Request $request,
        AnimalMovement $movement,
        int $version,
        string $reason,
    ): AnimalMovement {
        return DB::transaction(function () use ($request, $movement, $version, $reason): AnimalMovement {
            $locked = AnimalMovement::query()->lockForUpdate()->findOrFail($movement->id);
            if ($locked->version !== $version) {
                throw new StaleAnimalMovementVersion($locked->version);
            }
            if ($locked->status !== 'pending') {
                throw new AnimalMovementConflict(
                    'MOVEMENT_NOT_PENDING',
                    'Only a pending movement can be cancelled.',
                    ['status' => $locked->status],
                );
            }
            $old = $locked->toArray();
            $locked->forceFill([
                'status' => 'cancelled',
                'decided_by' => $request->user()->id,
                'decision_at' => now(),
                'cancellation_reason' => $reason,
                'version' => $locked->version + 1,
            ])->save();
            $this->audit->record(
                $request,
                'animal.movement_cancelled',
                'animal_movement',
                $locked->id,
                $old,
                $locked->toArray(),
            );

            return $locked->load($this->scope->relations());
        });
    }
}

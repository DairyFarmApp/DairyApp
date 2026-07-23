<?php

namespace App\Domain\AnimalMovements\Actions;

use App\Domain\AnimalMovements\Exceptions\AnimalMovementConflict;
use App\Domain\AnimalMovements\Exceptions\StaleAnimalMovementVersion;
use App\Domain\AnimalMovements\Models\AnimalMovement;
use App\Domain\AnimalMovements\Queries\AnimalMovementScope;
use App\Domain\AnimalMovements\Support\ApplyAnimalMovement;
use App\Domain\AnimalRegistry\Models\Animal;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class ApproveAnimalMovement
{
    public function __construct(
        private readonly ApplyAnimalMovement $apply,
        private readonly AnimalMovementScope $scope,
    ) {}

    public function execute(Request $request, AnimalMovement $movement, int $version): AnimalMovement
    {
        return DB::transaction(function () use ($request, $movement, $version): AnimalMovement {
            $lockedMovement = AnimalMovement::query()->lockForUpdate()->findOrFail($movement->id);
            if ($lockedMovement->version !== $version) {
                throw new StaleAnimalMovementVersion($lockedMovement->version);
            }
            if ($lockedMovement->status !== 'pending') {
                throw new AnimalMovementConflict(
                    'MOVEMENT_NOT_PENDING',
                    'Only a pending movement can be approved.',
                    ['status' => $lockedMovement->status],
                );
            }
            if ($lockedMovement->approval_required && $lockedMovement->requested_by === $request->user()->id) {
                throw new AuthorizationException('A requester cannot approve their own movement.');
            }
            $animal = Animal::withTrashed()->lockForUpdate()->findOrFail($lockedMovement->animal_id);
            $this->apply->execute($request, $lockedMovement, $animal);

            return $lockedMovement->load($this->scope->relations());
        });
    }
}

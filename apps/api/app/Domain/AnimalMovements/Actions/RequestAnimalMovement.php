<?php

namespace App\Domain\AnimalMovements\Actions;

use App\Domain\AnimalMovements\Exceptions\AnimalMovementConflict;
use App\Domain\AnimalMovements\Models\AnimalMovement;
use App\Domain\AnimalMovements\Queries\AnimalMovementScope;
use App\Domain\AnimalMovements\Support\AnimalMovementSettings;
use App\Domain\AnimalMovements\Support\AnimalMovementValidator;
use App\Domain\AnimalMovements\Support\ApplyAnimalMovement;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Support\AuditService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

final class RequestAnimalMovement
{
    public function __construct(
        private readonly AnimalMovementValidator $validator,
        private readonly AnimalMovementSettings $settings,
        private readonly ApplyAnimalMovement $apply,
        private readonly AnimalMovementScope $scope,
        private readonly AuditService $audit,
    ) {}

    public function execute(Request $request, Animal $animal, array $data): AnimalMovement
    {
        return DB::transaction(function () use ($request, $animal, $data): AnimalMovement {
            $lockedAnimal = Animal::withTrashed()
                ->where('organization_id', $animal->organization_id)
                ->lockForUpdate()
                ->findOrFail($animal->id);
            if ($lockedAnimal->trashed()) {
                throw ValidationException::withMessages([
                    'animal_id' => ['Archived animals cannot be moved.'],
                ]);
            }
            $membership = $request->attributes->get('membership');
            abort_unless($membership->canAccessFarm($lockedAnimal->current_farm_id), 404);
            $this->validator->sourceSnapshot($lockedAnimal, $data);
            $this->validator->destination(
                $lockedAnimal,
                $membership,
                $data['destination_farm_id'],
                $data['destination_shed_id'],
                $data['destination_animal_group_id'] ?? null,
            );
            if (AnimalMovement::query()
                ->where('organization_id', $lockedAnimal->organization_id)
                ->where('animal_id', $lockedAnimal->id)
                ->where('status', 'pending')
                ->exists()) {
                throw new AnimalMovementConflict(
                    'PENDING_MOVEMENT_EXISTS',
                    'The animal already has a pending movement.',
                );
            }

            $approvalRequired = $this->settings->requiresApproval($lockedAnimal->organization_id);
            if (! $approvalRequired && ! $membership->can('animal_movements.approve')) {
                throw new AuthorizationException('Immediate movement requires approval authority.');
            }
            $movement = AnimalMovement::create([
                'id' => $data['id'] ?? (string) Str::uuid7(),
                'organization_id' => $lockedAnimal->organization_id,
                'animal_id' => $lockedAnimal->id,
                'source_farm_id' => $lockedAnimal->current_farm_id,
                'source_shed_id' => $lockedAnimal->current_shed_id,
                'source_animal_group_id' => $lockedAnimal->current_animal_group_id,
                'destination_farm_id' => $data['destination_farm_id'],
                'destination_shed_id' => $data['destination_shed_id'],
                'destination_animal_group_id' => $data['destination_animal_group_id'] ?? null,
                'requested_effective_at' => $data['requested_effective_at'],
                'reason' => $data['reason'],
                'notes' => $data['notes'] ?? null,
                'status' => 'pending',
                'approval_required' => $approvalRequired,
                'requested_by' => $request->user()->id,
                'version' => 1,
            ]);
            $this->audit->record(
                $request,
                'animal.movement_requested',
                'animal_movement',
                $movement->id,
                null,
                $movement->toArray(),
            );
            if (! $approvalRequired) {
                $this->apply->execute($request, $movement, $lockedAnimal);
            }

            return $movement->load($this->scope->relations());
        });
    }
}

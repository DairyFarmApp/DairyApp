<?php

namespace App\Domain\AnimalStatuses\Actions;

use App\Domain\AnimalRegistry\Exceptions\StaleAnimalRegistryVersion;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Queries\AnimalRegistryScope;
use App\Domain\AnimalStatuses\Exceptions\AnimalStatusConflict;
use App\Domain\AnimalStatuses\Models\AnimalStatusChange;
use App\Support\AuditService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

final class ChangeAnimalStatus
{
    public function __construct(
        private readonly AnimalRegistryScope $scope,
        private readonly AuditService $audit,
    ) {}

    public function execute(Request $request, Animal $animal, array $data): AnimalStatusChange
    {
        return DB::transaction(function () use ($request, $animal, $data): AnimalStatusChange {
            $locked = Animal::withTrashed()
                ->where('organization_id', $animal->organization_id)
                ->lockForUpdate()
                ->findOrFail($animal->id);
            if ($locked->trashed()) {
                throw ValidationException::withMessages([
                    'animal_id' => ['Archived animals cannot change operational status.'],
                ]);
            }
            $membership = $request->attributes->get('membership');
            abort_unless($membership->canAccessFarm($locked->current_farm_id), 404);
            if ($locked->version !== (int) $data['version']) {
                throw new StaleAnimalRegistryVersion($locked->version);
            }
            if ($locked->operational_status === $data['new_status']) {
                throw new AnimalStatusConflict(
                    'STATUS_UNCHANGED',
                    'The animal already has the requested operational status.',
                    ['current_status' => $locked->operational_status],
                );
            }
            $previous = $locked->operational_status;
            $sequence = ((int) AnimalStatusChange::query()
                ->where('organization_id', $locked->organization_id)
                ->where('animal_id', $locked->id)
                ->max('sequence')) + 1;
            $change = AnimalStatusChange::create([
                'id' => $data['id'] ?? (string) Str::uuid7(),
                'organization_id' => $locked->organization_id,
                'farm_id' => $locked->current_farm_id,
                'animal_id' => $locked->id,
                'previous_status' => $previous,
                'new_status' => $data['new_status'],
                'effective_at' => $data['effective_at'],
                'reason' => $data['reason'],
                'changed_by' => $request->user()->id,
                'sequence' => $sequence,
            ]);
            $oldAnimal = [
                'operational_status' => $previous,
                'version' => $locked->version,
            ];
            $locked->forceFill([
                'operational_status' => $data['new_status'],
                'updated_by' => $request->user()->id,
                'version' => $locked->version + 1,
            ])->save();
            $this->audit->record(
                $request,
                'animal.status_changed',
                'animal',
                $locked->id,
                $oldAnimal,
                [
                    'operational_status' => $locked->operational_status,
                    'version' => $locked->version,
                    'status_change_id' => $change->id,
                    'reason' => $change->reason,
                    'effective_at' => $change->effective_at?->toISOString(),
                ],
            );
            $change->setRelation('animal', $locked->load($this->scope->animalRelations()));

            return $change->load(['farm', 'changer']);
        });
    }
}

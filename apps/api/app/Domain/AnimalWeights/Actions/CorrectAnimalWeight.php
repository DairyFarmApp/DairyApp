<?php

namespace App\Domain\AnimalWeights\Actions;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalWeights\Exceptions\AnimalWeightConflict;
use App\Domain\AnimalWeights\Models\AnimalWeight;
use App\Domain\AnimalWeights\Queries\AnimalWeightScope;
use App\Domain\AnimalWeights\Support\AnimalWeightConverter;
use App\Domain\AnimalWeights\Support\AnimalWeightValidator;
use App\Support\AuditService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

final class CorrectAnimalWeight
{
    public function __construct(
        private readonly AnimalWeightConverter $converter,
        private readonly AnimalWeightValidator $validator,
        private readonly AnimalWeightScope $scope,
        private readonly AuditService $audit,
    ) {}

    public function execute(Request $request, AnimalWeight $weight, array $data): AnimalWeight
    {
        return DB::transaction(function () use ($request, $weight, $data): AnimalWeight {
            $animal = Animal::withTrashed()->lockForUpdate()->findOrFail($weight->animal_id);
            if ($animal->trashed()) {
                throw ValidationException::withMessages([
                    'animal_id' => ['Archived animals cannot receive weight corrections.'],
                ]);
            }
            $locked = AnimalWeight::query()->lockForUpdate()->findOrFail($weight->id);
            if ($locked->is_superseded || $locked->superseded_by_weight_id !== null) {
                throw new AnimalWeightConflict(
                    'WEIGHT_ALREADY_CORRECTED',
                    'This weight record already has a correction.',
                    ['superseded_by_weight_id' => $locked->superseded_by_weight_id],
                );
            }
            if ($locked->supersedes_weight_id !== null) {
                throw new AnimalWeightConflict(
                    'CORRECTION_CANNOT_BE_CORRECTED',
                    'A correction record cannot be corrected again.',
                );
            }
            $membership = $request->attributes->get('membership');
            abort_unless(
                $membership->canAccessFarm($animal->current_farm_id)
                    && $membership->canAccessFarm($locked->farm_id),
                404,
            );
            $enteredValue = $this->converter->fromMicrounits(
                $this->converter->toMicrounits((string) $data['value']),
            );
            $normalized = $this->validator->normalized(
                $locked->organization_id,
                $locked->farm_id,
                $enteredValue,
                $data['unit'],
            );
            $replacement = AnimalWeight::create([
                'id' => $data['id'] ?? (string) Str::uuid7(),
                'organization_id' => $locked->organization_id,
                'farm_id' => $locked->farm_id,
                'animal_id' => $locked->animal_id,
                'entered_value' => $enteredValue,
                'entered_unit' => $data['unit'],
                'normalized_kg' => $normalized,
                'observed_at' => $locked->observed_at,
                'source' => $locked->source,
                'notes' => array_key_exists('notes', $data) ? $data['notes'] : $locked->notes,
                'recorded_by' => $request->user()->id,
                'supersedes_weight_id' => $locked->id,
                'correction_reason' => $data['correction_reason'],
            ]);
            $old = $locked->toArray();
            $locked->forceFill([
                'is_superseded' => true,
                'superseded_by_weight_id' => $replacement->id,
            ])->save();
            $this->audit->record(
                $request,
                'animal.weight_corrected',
                'animal_weight',
                $replacement->id,
                $old,
                [
                    ...$replacement->toArray(),
                    'superseded_weight_id' => $locked->id,
                ],
            );

            return $replacement->load($this->scope->relations());
        });
    }
}

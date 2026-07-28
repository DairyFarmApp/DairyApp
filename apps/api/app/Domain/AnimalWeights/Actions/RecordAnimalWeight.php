<?php

namespace App\Domain\AnimalWeights\Actions;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalWeights\Models\AnimalWeight;
use App\Domain\AnimalWeights\Queries\AnimalWeightScope;
use App\Domain\AnimalWeights\Support\AnimalWeightConverter;
use App\Domain\AnimalWeights\Support\AnimalWeightValidator;
use App\Support\AuditService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

final class RecordAnimalWeight
{
    public function __construct(
        private readonly AnimalWeightConverter $converter,
        private readonly AnimalWeightValidator $validator,
        private readonly AnimalWeightScope $scope,
        private readonly AuditService $audit,
    ) {}

    public function execute(Request $request, Animal $animal, array $data): AnimalWeight
    {
        return DB::transaction(function () use ($request, $animal, $data): AnimalWeight {
            $lockedAnimal = Animal::withTrashed()
                ->where('organization_id', $animal->organization_id)
                ->lockForUpdate()
                ->findOrFail($animal->id);
            if ($lockedAnimal->trashed()) {
                throw ValidationException::withMessages([
                    'animal_id' => ['Archived animals cannot receive new weight records.'],
                ]);
            }
            $membership = $request->attributes->get('membership');
            abort_unless($membership->canAccessFarm($lockedAnimal->current_farm_id), 404);
            if ($data['farm_id'] !== $lockedAnimal->current_farm_id) {
                throw ValidationException::withMessages([
                    'farm_id' => ['The weight farm snapshot must match the animal current farm.'],
                ]);
            }
            $enteredValue = $this->converter->fromMicrounits(
                $this->converter->toMicrounits((string) $data['value']),
            );
            $normalized = $this->validator->normalized(
                $lockedAnimal->organization_id,
                $lockedAnimal->current_farm_id,
                $enteredValue,
                $data['unit'],
            );
            $weight = AnimalWeight::create([
                'id' => $data['id'] ?? (string) Str::uuid7(),
                'organization_id' => $lockedAnimal->organization_id,
                'farm_id' => $lockedAnimal->current_farm_id,
                'animal_id' => $lockedAnimal->id,
                'entered_value' => $enteredValue,
                'entered_unit' => $data['unit'],
                'normalized_kg' => $normalized,
                'observed_at' => $data['observed_at'],
                'source' => $data['source'],
                'notes' => $data['notes'] ?? null,
                'recorded_by' => $request->user()->id,
            ]);
            $this->audit->record(
                $request,
                'animal.weight_recorded',
                'animal_weight',
                $weight->id,
                null,
                $weight->toArray(),
            );

            return $weight->load($this->scope->relations());
        });
    }
}

<?php

namespace App\Domain\AnimalRegistry\Actions;

use App\Domain\AnimalRegistry\Exceptions\StaleAnimalRegistryVersion;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Queries\AnimalRegistryScope;
use App\Domain\AnimalRegistry\Support\AnimalRegistryValidator;
use App\Domain\AnimalRegistry\Support\ParentageValidator;
use App\Support\AuditService;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class UpdateAnimal
{
    use CreatesAnimalRegistryRecords;

    public function __construct(
        private readonly AnimalRegistryValidator $validator,
        private readonly ParentageValidator $parentage,
        private readonly AnimalRegistryScope $scope,
        private readonly AuditService $audit,
    ) {}

    public function execute(Request $request, Animal $animal, array $data): Animal
    {
        $speciesId = $data['species_id'] ?? $animal->species_id;
        $breedId = $data['breed_id'] ?? $animal->breed_id;
        $classificationChanged = $speciesId !== $animal->species_id || $breedId !== $animal->breed_id;
        $this->validator->classification($animal->organization_id, $speciesId, $breedId, $classificationChanged);
        $this->parentage->validate(
            $animal->organization_id,
            $animal->id,
            array_key_exists('mother_animal_id', $data) ? $data['mother_animal_id'] : $animal->mother_animal_id,
            array_key_exists('father_animal_id', $data) ? $data['father_animal_id'] : $animal->father_animal_id,
            array_key_exists('date_of_birth', $data) ? $data['date_of_birth'] : $animal->date_of_birth,
        );

        try {
            return DB::transaction(function () use ($request, $animal, $data): Animal {
                $locked = Animal::withTrashed()->lockForUpdate()->findOrFail($animal->id);
                if ($locked->version !== (int) $data['version']) {
                    throw new StaleAnimalRegistryVersion($locked->version);
                }
                unset($data['version']);
                $identifierChanged = collect(['animal_number', 'ear_tag_number', 'rfid_number'])
                    ->contains(fn (string $field) => array_key_exists($field, $data) && $data[$field] !== $locked->{$field});
                $old = $locked->toArray();
                $locked->fill($data);
                $locked->updated_by = $request->user()->id;
                $locked->version++;
                $locked->save();
                $this->audit->record(
                    $request,
                    $identifierChanged ? 'animal.identifiers_updated' : 'animal.updated',
                    'animal',
                    $locked->id,
                    $old,
                    $locked->toArray(),
                );

                return $locked->load($this->scope->animalRelations());
            });
        } catch (QueryException $exception) {
            $this->translateUniqueViolation($exception, 'identifiers');
        }
    }
}

<?php

namespace App\Domain\AnimalRegistry\Actions;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Queries\AnimalRegistryScope;
use App\Domain\AnimalRegistry\Support\AnimalNumberGenerator;
use App\Domain\AnimalRegistry\Support\AnimalRegistryValidator;
use App\Domain\AnimalRegistry\Support\ParentageValidator;
use App\Support\AuditService;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

final class CreateAnimal
{
    use CreatesAnimalRegistryRecords;

    public function __construct(
        private readonly AnimalRegistryValidator $validator,
        private readonly ParentageValidator $parentage,
        private readonly AnimalNumberGenerator $numbers,
        private readonly AnimalRegistryScope $scope,
        private readonly AuditService $audit,
    ) {}

    public function execute(Request $request, array $data): Animal
    {
        $organizationId = $request->attributes->get('organization_id');
        $membership = $request->attributes->get('membership');
        $this->validator->classification($organizationId, $data['species_id'], $data['breed_id']);
        $this->validator->location(
            $organizationId,
            $membership,
            $data['current_farm_id'],
            $data['current_shed_id'],
            $data['current_animal_group_id'] ?? null,
        );
        $animalId = $data['id'] ?? (string) Str::uuid7();
        $this->parentage->validate(
            $organizationId,
            $animalId,
            $data['mother_animal_id'] ?? null,
            $data['father_animal_id'] ?? null,
            $data['date_of_birth'] ?? null,
        );
        foreach ([
            'animal_number' => 'animal_number',
            'ear_tag_number' => 'ear_tag_number',
            'rfid_number' => 'rfid_number',
        ] as $field => $column) {
            $value = $data[$field] ?? null;
            if ($value !== null && Animal::withTrashed()
                ->where('organization_id', $organizationId)
                ->where($column, $value)
                ->exists()) {
                throw ValidationException::withMessages([$field => ['The identifier is already in use.']]);
            }
        }

        try {
            return DB::transaction(function () use ($request, $data, $organizationId, $animalId): Animal {
                $animalNumber = $data['animal_number'] ?? $this->numbers->next($organizationId);
                $animal = Animal::create([
                    ...$data,
                    'id' => $animalId,
                    'organization_id' => $organizationId,
                    'animal_number' => $animalNumber,
                    'operational_status' => $data['operational_status'] ?? 'active',
                    'version' => 1,
                    'created_by' => $request->user()->id,
                    'updated_by' => $request->user()->id,
                ]);
                $this->audit->record($request, 'animal.created', 'animal', $animal->id, null, $animal->toArray());

                return $animal->load($this->scope->animalRelations());
            });
        } catch (QueryException $exception) {
            $this->translateUniqueViolation($exception, 'identifiers');
        }
    }
}

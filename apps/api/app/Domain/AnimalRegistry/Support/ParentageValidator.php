<?php

namespace App\Domain\AnimalRegistry\Support;

use App\Domain\AnimalRegistry\Models\Animal;
use Illuminate\Support\Carbon;
use Illuminate\Validation\ValidationException;

final class ParentageValidator
{
    public function validate(string $organizationId, ?string $animalId, ?string $motherId, ?string $fatherId, mixed $dateOfBirth): void
    {
        if ($animalId !== null && ($animalId === $motherId || $animalId === $fatherId)) {
            throw ValidationException::withMessages(['parentage' => ['An animal cannot be its own parent.']]);
        }

        $mother = $this->parent($organizationId, $motherId, 'mother_animal_id');
        $father = $this->parent($organizationId, $fatherId, 'father_animal_id');
        if ($mother && $mother->sex !== 'female') {
            throw ValidationException::withMessages(['mother_animal_id' => ['The mother must be female.']]);
        }
        if ($father && $father->sex !== 'male') {
            throw ValidationException::withMessages(['father_animal_id' => ['The father must be male.']]);
        }

        $childDate = $dateOfBirth ? Carbon::parse($dateOfBirth)->startOfDay() : null;
        foreach ([['mother_animal_id', $mother], ['father_animal_id', $father]] as [$field, $parent]) {
            if ($childDate && $parent?->date_of_birth && ! $parent->date_of_birth->lt($childDate)) {
                throw ValidationException::withMessages([$field => ['A parent must be older than the child.']]);
            }
        }

        if ($animalId !== null) {
            foreach (array_filter([$motherId, $fatherId]) as $parentId) {
                if ($this->isDescendant($organizationId, $parentId, $animalId)) {
                    throw ValidationException::withMessages(['parentage' => ['Circular parentage is not permitted.']]);
                }
            }
        }
    }

    private function parent(string $organizationId, ?string $id, string $field): ?Animal
    {
        if ($id === null) {
            return null;
        }
        $parent = Animal::withTrashed()
            ->where('organization_id', $organizationId)
            ->find($id);
        if (! $parent) {
            throw ValidationException::withMessages([$field => ['The selected parent is invalid.']]);
        }

        return $parent;
    }

    private function isDescendant(string $organizationId, string $candidateId, string $animalId): bool
    {
        $visited = [];
        $pending = [$candidateId];
        while ($pending !== []) {
            $id = array_pop($pending);
            if ($id === $animalId) {
                return true;
            }
            if (isset($visited[$id])) {
                continue;
            }
            $visited[$id] = true;
            $animal = Animal::withTrashed()
                ->where('organization_id', $organizationId)
                ->find($id);
            if ($animal) {
                foreach ([$animal->mother_animal_id, $animal->father_animal_id] as $parentId) {
                    if ($parentId !== null) {
                        $pending[] = $parentId;
                    }
                }
            }
        }

        return false;
    }
}

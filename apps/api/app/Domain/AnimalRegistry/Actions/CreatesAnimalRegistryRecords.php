<?php

namespace App\Domain\AnimalRegistry\Actions;

use Illuminate\Database\QueryException;
use Illuminate\Validation\ValidationException;

trait CreatesAnimalRegistryRecords
{
    private function translateUniqueViolation(QueryException $exception, string $field): never
    {
        if (in_array((string) $exception->getCode(), ['19', '23000'], true)) {
            throw ValidationException::withMessages([$field => ['The value is already in use.']]);
        }

        throw $exception;
    }
}

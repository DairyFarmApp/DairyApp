<?php

namespace App\Domain\AnimalRegistry\Support;

use Illuminate\Support\Str;

final class AnimalRegistryNormalizer
{
    public function code(string $value): string
    {
        return strtoupper(Str::slug(trim($value), '-'));
    }

    public function name(string $value): string
    {
        return Str::lower(preg_replace('/\s+/u', ' ', trim($value)) ?? trim($value));
    }

    public function animalNumber(?string $value): ?string
    {
        if ($value === null || trim($value) === '') {
            return null;
        }

        return strtoupper(preg_replace('/\s+/u', '-', trim($value)) ?? trim($value));
    }

    public function earTag(?string $value): ?string
    {
        if ($value === null || trim($value) === '') {
            return null;
        }
        $normalized = strtoupper(trim($value));
        $normalized = preg_replace('/\s*([.\/_-])\s*/u', '$1', $normalized) ?? $normalized;

        return preg_replace('/\s+/u', '-', $normalized) ?? $normalized;
    }

    public function rfid(?string $value): ?string
    {
        if ($value === null || trim($value) === '') {
            return null;
        }

        return strtoupper(preg_replace('/[\s-]+/u', '', trim($value)) ?? trim($value));
    }

    public function optionalText(mixed $value): mixed
    {
        if (! is_string($value)) {
            return $value;
        }
        $trimmed = trim($value);

        return $trimmed === '' ? null : $trimmed;
    }
}

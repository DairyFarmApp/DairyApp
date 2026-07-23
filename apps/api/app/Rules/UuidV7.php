<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;
use Ramsey\Uuid\Uuid;

class UuidV7 implements ValidationRule
{
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        try {
            if (! is_string($value) || Uuid::fromString($value)->getVersion() !== 7) {
                $fail('The :attribute field must be a UUID version 7 value.');
            }
        } catch (\Throwable) {
            $fail('The :attribute field must be a UUID version 7 value.');
        }
    }
}

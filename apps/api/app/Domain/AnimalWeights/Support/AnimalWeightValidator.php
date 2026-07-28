<?php

namespace App\Domain\AnimalWeights\Support;

use Illuminate\Validation\ValidationException;

final class AnimalWeightValidator
{
    public function __construct(
        private readonly AnimalWeightConverter $converter,
        private readonly AnimalWeightSettings $settings,
    ) {}

    public function normalized(
        string $organizationId,
        string $farmId,
        string $enteredValue,
        string $unit,
    ): string {
        $normalized = $this->converter->normalize($enteredValue, $unit);
        $normalizedMicrounits = $this->converter->toMicrounits($normalized);
        if ($normalizedMicrounits <= 0) {
            throw ValidationException::withMessages([
                'value' => ['The animal weight must be greater than zero.'],
            ]);
        }
        $maximum = $this->settings->maximumKg($organizationId, $farmId);
        if ($normalizedMicrounits > $this->converter->toMicrounits($maximum)) {
            throw ValidationException::withMessages([
                'value' => ["The animal weight must not exceed {$maximum} kg after conversion."],
            ]);
        }

        return $normalized;
    }
}

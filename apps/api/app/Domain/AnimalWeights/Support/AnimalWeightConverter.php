<?php

namespace App\Domain\AnimalWeights\Support;

use InvalidArgumentException;

final class AnimalWeightConverter
{
    private const SCALE = 1_000_000;

    private const LB_TO_KG_NUMERATOR = 45_359_237;

    private const LB_TO_KG_DENOMINATOR = 100_000_000;

    public function normalize(string $value, string $unit): string
    {
        $enteredMicrounits = $this->toMicrounits($value);
        $kilogramMicrounits = match ($unit) {
            'kg' => $enteredMicrounits,
            'lb' => intdiv(
                ($enteredMicrounits * self::LB_TO_KG_NUMERATOR)
                    + intdiv(self::LB_TO_KG_DENOMINATOR, 2),
                self::LB_TO_KG_DENOMINATOR,
            ),
            default => throw new InvalidArgumentException('Unsupported animal weight unit.'),
        };

        return $this->fromMicrounits($kilogramMicrounits);
    }

    public function toMicrounits(string $value): int
    {
        $value = trim($value);
        if (preg_match('/^\d{1,12}(?:\.\d{1,6})?$/', $value) !== 1) {
            throw new InvalidArgumentException('Animal weights require a positive decimal with at most six decimal places.');
        }
        [$whole, $fraction] = array_pad(explode('.', $value, 2), 2, '');
        $fraction = str_pad($fraction, 6, '0');

        return ((int) $whole * self::SCALE) + (int) $fraction;
    }

    public function fromMicrounits(int $value): string
    {
        return sprintf('%d.%06d', intdiv($value, self::SCALE), $value % self::SCALE);
    }
}

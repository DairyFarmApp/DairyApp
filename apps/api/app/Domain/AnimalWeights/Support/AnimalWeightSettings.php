<?php

namespace App\Domain\AnimalWeights\Support;

use App\Models\Setting;
use Throwable;

final class AnimalWeightSettings
{
    public const MAXIMUM_KEY = 'animal_weight_max_kg';

    public const DEFAULT_MAXIMUM_KG = '3000.000000';

    public function __construct(private readonly AnimalWeightConverter $converter) {}

    public function maximumKg(string $organizationId, string $farmId): string
    {
        $setting = Setting::query()
            ->where('organization_id', $organizationId)
            ->where('farm_id', $farmId)
            ->where('key', self::MAXIMUM_KEY)
            ->first()
            ?? Setting::query()
                ->where('organization_id', $organizationId)
                ->whereNull('farm_id')
                ->where('key', self::MAXIMUM_KEY)
                ->first();
        $value = is_array($setting?->value) ? ($setting->value['kilograms'] ?? null) : null;
        if (! is_string($value)) {
            return self::DEFAULT_MAXIMUM_KG;
        }

        try {
            return $this->converter->fromMicrounits($this->converter->toMicrounits($value));
        } catch (Throwable) {
            return self::DEFAULT_MAXIMUM_KG;
        }
    }
}

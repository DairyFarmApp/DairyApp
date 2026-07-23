<?php

namespace App\Domain\AnimalMovements\Support;

use App\Models\Setting;

final class AnimalMovementSettings
{
    public const APPROVAL_KEY = 'animal_movement_requires_approval';

    public function requiresApproval(string $organizationId): bool
    {
        $setting = Setting::query()
            ->where('organization_id', $organizationId)
            ->whereNull('farm_id')
            ->where('key', self::APPROVAL_KEY)
            ->first();
        if (! $setting) {
            return true;
        }

        $value = $setting->value;

        return is_array($value) && array_key_exists('enabled', $value)
            ? (bool) $value['enabled']
            : true;
    }
}

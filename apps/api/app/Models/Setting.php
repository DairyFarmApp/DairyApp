<?php

namespace App\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'key', 'type', 'value'];

    protected function casts(): array
    {
        return ['value' => 'array'];
    }

    protected static function booted(): void
    {
        static::saving(function (Setting $setting): void {
            $setting->scope_key = hash('sha256', implode('|', [
                $setting->organization_id,
                $setting->farm_id ?? '-',
                $setting->key,
            ]));
        });
    }
}

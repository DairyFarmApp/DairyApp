<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class HealthSymptom extends Model
{
    use UsesUuidV7;

    protected $fillable = ['code', 'name', 'name_roman_urdu', 'body_system', 'is_emergency', 'emergency_message', 'is_active'];

    protected function casts(): array
    {
        return ['is_emergency' => 'boolean', 'is_active' => 'boolean'];
    }

    public function diseases(): BelongsToMany
    {
        return $this->belongsToMany(HealthDisease::class, 'health_disease_symptom', 'symptom_id', 'disease_id')->withPivot(['weight', 'is_key']);
    }
}

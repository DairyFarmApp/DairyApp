<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AnimalHealthCase extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'animal_id', 'case_number', 'reported_at', 'severity', 'temperature_c', 'status', 'top_disease_id', 'top_score', 'emergency', 'emergency_message', 'notes', 'created_by', 'version'];

    protected function casts(): array
    {
        return ['reported_at' => 'datetime', 'temperature_c' => 'decimal:2', 'top_score' => 'decimal:2', 'emergency' => 'boolean', 'version' => 'integer'];
    }

    public function topDisease(): BelongsTo
    {
        return $this->belongsTo(HealthDisease::class, 'top_disease_id');
    }

    public function symptoms(): BelongsToMany
    {
        return $this->belongsToMany(HealthSymptom::class, 'animal_health_case_symptoms', 'health_case_id', 'symptom_id')->withPivot(['presence', 'severity']);
    }

    public function differentials(): HasMany
    {
        return $this->hasMany(AnimalHealthDifferential::class, 'health_case_id')->orderBy('rank');
    }
}

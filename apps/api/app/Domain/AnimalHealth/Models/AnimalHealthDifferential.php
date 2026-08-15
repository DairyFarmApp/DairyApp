<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AnimalHealthDifferential extends Model
{
    use UsesUuidV7;

    protected $fillable = ['health_case_id', 'disease_id', 'score', 'matched_symptoms', 'missing_key_symptoms', 'rank'];

    protected function casts(): array
    {
        return ['score' => 'decimal:2', 'matched_symptoms' => 'array', 'missing_key_symptoms' => 'array', 'rank' => 'integer'];
    }

    public function disease(): BelongsTo
    {
        return $this->belongsTo(HealthDisease::class);
    }
}

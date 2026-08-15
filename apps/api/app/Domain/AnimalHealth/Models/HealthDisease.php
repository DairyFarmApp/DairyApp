<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class HealthDisease extends Model
{
    use UsesUuidV7;

    protected $fillable = ['code', 'name', 'name_roman_urdu', 'species', 'summary', 'summary_roman_urdu', 'immediate_care', 'immediate_care_roman_urdu', 'confirmation_guidance', 'confirmation_guidance_roman_urdu', 'safe_home_care', 'safe_home_care_roman_urdu', 'do_not_do', 'do_not_do_roman_urdu', 'feed_water_guidance', 'feed_water_guidance_roman_urdu', 'urgency', 'source_title', 'source_url', 'source_reviewed_on', 'review_status', 'reviewed_by', 'reviewed_at', 'knowledge_version', 'is_active'];

    protected function casts(): array
    {
        return ['species' => 'array', 'source_reviewed_on' => 'date', 'reviewed_at' => 'datetime', 'is_active' => 'boolean'];
    }

    public function symptoms(): BelongsToMany
    {
        return $this->belongsToMany(HealthSymptom::class, 'health_disease_symptom', 'disease_id', 'symptom_id')->withPivot(['weight', 'is_key']);
    }
}

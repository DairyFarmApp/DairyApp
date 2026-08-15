<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class AnimalHeatRecord extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'animal_id', 'detected_at', 'symptoms', 'detection_method', 'detected_by_name', 'intensity', 'recommended_action', 'notes', 'created_by'];

    protected function casts(): array
    {
        return ['detected_at' => 'datetime', 'symptoms' => 'array'];
    }
}

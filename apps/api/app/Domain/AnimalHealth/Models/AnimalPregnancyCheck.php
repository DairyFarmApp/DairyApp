<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class AnimalPregnancyCheck extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'animal_id', 'breeding_service_id', 'checked_on', 'method', 'veterinarian_name', 'result', 'estimated_age_days', 'expected_calving_date', 'follow_up_date', 'notes', 'created_by'];

    protected function casts(): array
    {
        return ['checked_on' => 'date', 'expected_calving_date' => 'date', 'follow_up_date' => 'date'];
    }
}

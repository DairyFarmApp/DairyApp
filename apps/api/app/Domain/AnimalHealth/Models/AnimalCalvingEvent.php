<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class AnimalCalvingEvent extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'mother_animal_id', 'pregnancy_check_id', 'calved_at', 'calving_type', 'veterinarian_name', 'complications', 'placenta_status', 'mother_condition', 'treatment_required', 'post_calving_check_due', 'calf_animal_ids', 'notes', 'created_by'];

    protected function casts(): array
    {
        return ['calved_at' => 'datetime', 'post_calving_check_due' => 'date', 'calf_animal_ids' => 'array', 'treatment_required' => 'boolean'];
    }
}

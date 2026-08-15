<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class CalfCareProfile extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'animal_id', 'birth_at', 'birth_weight_kg', 'birth_condition', 'colostrum_given', 'colostrum_at', 'colostrum_quantity_litres', 'colostrum_quality', 'navel_treated', 'navel_treated_at', 'navel_product', 'weaning_target_date', 'actual_weaning_date', 'feed_plan', 'target_daily_gain_kg', 'health_status', 'notes', 'created_by', 'updated_by', 'version'];

    protected function casts(): array
    {
        return ['birth_at' => 'datetime', 'colostrum_at' => 'datetime', 'navel_treated_at' => 'datetime', 'weaning_target_date' => 'date', 'actual_weaning_date' => 'date', 'colostrum_given' => 'boolean', 'navel_treated' => 'boolean', 'birth_weight_kg' => 'decimal:3', 'target_daily_gain_kg' => 'decimal:3'];
    }
}

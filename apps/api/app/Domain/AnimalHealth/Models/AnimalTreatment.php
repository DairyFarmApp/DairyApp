<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AnimalTreatment extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'animal_id', 'health_case_id', 'inventory_item_id', 'treatment_number', 'administered_at', 'animal_weight_kg', 'dose', 'dose_unit', 'route', 'frequency', 'duration_days', 'inventory_quantity_used', 'veterinarian_name', 'veterinarian_instructions', 'notes', 'administered_by', 'version'];

    protected function casts(): array
    {
        return ['administered_at' => 'datetime', 'animal_weight_kg' => 'decimal:3', 'dose' => 'decimal:3', 'inventory_quantity_used' => 'decimal:3', 'duration_days' => 'integer', 'version' => 'integer'];
    }

    public function withdrawals(): HasMany
    {
        return $this->hasMany(AnimalWithdrawalRestriction::class, 'treatment_id');
    }
}

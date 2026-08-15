<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AnimalBreedingService extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'animal_id', 'heat_record_id', 'service_number', 'bred_at', 'method', 'bull_animal_id', 'semen_item_id', 'semen_batch_id', 'semen_straw_number', 'breed_name', 'supplier', 'technician_name', 'cost_pkr', 'pregnancy_check_due_date', 'notes', 'created_by'];

    protected function casts(): array
    {
        return ['bred_at' => 'datetime', 'pregnancy_check_due_date' => 'date', 'cost_pkr' => 'decimal:2'];
    }

    public function pregnancyChecks(): HasMany
    {
        return $this->hasMany(AnimalPregnancyCheck::class, 'breeding_service_id');
    }
}

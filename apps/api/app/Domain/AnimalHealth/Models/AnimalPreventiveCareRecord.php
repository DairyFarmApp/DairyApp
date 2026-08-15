<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class AnimalPreventiveCareRecord extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'animal_id', 'inventory_item_id', 'inventory_batch_id', 'campaign_id', 'record_number', 'type', 'disease_covered', 'dose', 'dose_unit', 'inventory_quantity_used', 'administered_at', 'next_due_date', 'veterinarian_name', 'administered_by_name', 'cost_pkr', 'reaction', 'notes', 'created_by', 'version'];

    protected function casts(): array
    {
        return ['administered_at' => 'datetime', 'next_due_date' => 'date', 'dose' => 'decimal:3', 'inventory_quantity_used' => 'decimal:3', 'cost_pkr' => 'decimal:2'];
    }
}

<?php

namespace App\Domain\MilkProduction\Models;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Models\Concerns\UsesUuidV7;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MilkEntry extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'id',
        'organization_id',
        'farm_id',
        'milk_production_slot_id',
        'animal_id',
        'revision',
        'quantity_litres',
        'rejected_quantity_litres',
        'rejection_reason',
        'notes',
        'entry_source',
        'is_current',
        'supersedes_entry_id',
        'superseded_by_entry_id',
        'correction_reason',
        'recorded_by',
    ];

    protected function casts(): array
    {
        return [
            'quantity_litres' => 'decimal:3',
            'rejected_quantity_litres' => 'decimal:3',
            'revision' => 'integer',
            'is_current' => 'boolean',
        ];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class);
    }

    public function slot(): BelongsTo
    {
        return $this->belongsTo(MilkProductionSlot::class, 'milk_production_slot_id');
    }

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class);
    }

    public function recorder(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recorded_by');
    }

    public function supersedes(): BelongsTo
    {
        return $this->belongsTo(self::class, 'supersedes_entry_id');
    }
}

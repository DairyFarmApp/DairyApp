<?php

namespace App\Domain\AnimalRegistry\Models;

use App\Domain\Inventory\Models\InventoryItem;
use App\Models\Concerns\UsesUuidV7;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AnimalFeedConsumption extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'id',
        'organization_id',
        'farm_id',
        'animal_id',
        'inventory_item_id',
        'date',
        'session',
        'quantity',
        'unit',
        'notes',
        'recorded_by',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
            'quantity' => 'decimal:3',
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

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class);
    }

    public function item(): BelongsTo
    {
        return $this->belongsTo(InventoryItem::class, 'inventory_item_id');
    }

    public function recorder(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recorded_by');
    }
}

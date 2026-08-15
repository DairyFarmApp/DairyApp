<?php

namespace App\Domain\Feed\Models;

use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Domain\Inventory\Models\InventoryItem;
use App\Models\Concerns\UsesUuidV7;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\Shed;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class DailyFeedIssue extends Model
{
    use SoftDeletes, UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'shed_id',
        'animal_group_id',
        'date',
        'inventory_item_id',
        'planned_quantity',
        'issued_quantity',
        'consumed_quantity',
        'wasted_quantity',
        'returned_quantity',
        'inventory_posted', 'inventory_net_quantity',
        'employee_id',
        'notes',
        'version',
        'created_by',
        'updated_by',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
            'planned_quantity' => 'decimal:3',
            'issued_quantity' => 'decimal:3',
            'consumed_quantity' => 'decimal:3',
            'wasted_quantity' => 'decimal:3',
            'returned_quantity' => 'decimal:3',
            'inventory_posted' => 'boolean', 'inventory_net_quantity' => 'decimal:3',
            'version' => 'integer',
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

    public function shed(): BelongsTo
    {
        return $this->belongsTo(Shed::class);
    }

    public function animalGroup(): BelongsTo
    {
        return $this->belongsTo(AnimalGroup::class);
    }

    public function inventoryItem(): BelongsTo
    {
        return $this->belongsTo(InventoryItem::class);
    }

    public function createdBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function updatedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'updated_by');
    }
}

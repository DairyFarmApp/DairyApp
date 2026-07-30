<?php

namespace App\Domain\Inventory\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StockMovement extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'inventory_item_id',
        'inventory_batch_id',
        'movement_type',
        'quantity_change',
        'unit_cost',
        'occurred_at',
        'reason',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'quantity_change' => 'decimal:3',
            'unit_cost' => 'decimal:4',
            'occurred_at' => 'datetime',
        ];
    }

    public function item(): BelongsTo
    {
        return $this->belongsTo(InventoryItem::class, 'inventory_item_id');
    }

    public function batch(): BelongsTo
    {
        return $this->belongsTo(InventoryBatch::class, 'inventory_batch_id');
    }
}

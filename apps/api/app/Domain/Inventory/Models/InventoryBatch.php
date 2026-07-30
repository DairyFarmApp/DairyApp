<?php

namespace App\Domain\Inventory\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class InventoryBatch extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'inventory_item_id',
        'batch_number',
        'supplier',
        'purchase_date',
        'expiry_date',
        'unit_cost',
        'current_quantity',
        'version',
    ];

    protected function casts(): array
    {
        return [
            'purchase_date' => 'date',
            'expiry_date' => 'date',
            'unit_cost' => 'decimal:4',
            'current_quantity' => 'decimal:3',
            'version' => 'integer',
        ];
    }

    public function item(): BelongsTo
    {
        return $this->belongsTo(InventoryItem::class, 'inventory_item_id');
    }

    public function movements(): HasMany
    {
        return $this->hasMany(StockMovement::class, 'inventory_batch_id');
    }
}

<?php

namespace App\Domain\Commerce\Models;

use App\Domain\Inventory\Models\InventoryItem;
use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PurchaseOrderItem extends Model
{
    use UsesUuidV7;

    protected $fillable = ['purchase_order_id', 'inventory_item_id', 'ordered_quantity', 'received_quantity', 'unit_rate', 'line_total'];

    protected function casts(): array
    {
        return ['ordered_quantity' => 'decimal:3', 'received_quantity' => 'decimal:3', 'unit_rate' => 'decimal:4', 'line_total' => 'decimal:2'];
    }

    public function inventoryItem(): BelongsTo
    {
        return $this->belongsTo(InventoryItem::class);
    }
}

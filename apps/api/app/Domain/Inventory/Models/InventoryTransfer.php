<?php

namespace App\Domain\Inventory\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class InventoryTransfer extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'source_farm_id', 'destination_farm_id', 'source_item_id', 'destination_item_id', 'transfer_number', 'quantity', 'unit', 'transferred_at', 'reason', 'status', 'created_by'];

    protected function casts(): array
    {
        return ['quantity' => 'decimal:3', 'transferred_at' => 'datetime'];
    }
}

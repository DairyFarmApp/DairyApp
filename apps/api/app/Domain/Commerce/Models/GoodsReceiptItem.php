<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class GoodsReceiptItem extends Model
{
    use UsesUuidV7;

    protected $fillable = ['goods_receipt_id', 'purchase_order_item_id', 'inventory_batch_id', 'stock_movement_id', 'batch_number', 'expiry_date', 'quantity', 'unit_cost'];

    protected function casts(): array
    {
        return ['expiry_date' => 'date', 'quantity' => 'decimal:3', 'unit_cost' => 'decimal:4'];
    }
}

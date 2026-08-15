<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class GoodsReceipt extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'purchase_order_id', 'receipt_number', 'received_at', 'quality_status', 'notes', 'received_by'];

    protected function casts(): array
    {
        return ['received_at' => 'datetime'];
    }

    public function items(): HasMany
    {
        return $this->hasMany(GoodsReceiptItem::class);
    }

    public function purchaseOrder(): BelongsTo
    {
        return $this->belongsTo(PurchaseOrder::class);
    }
}

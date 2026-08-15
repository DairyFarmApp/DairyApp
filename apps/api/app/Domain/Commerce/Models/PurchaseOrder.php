<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class PurchaseOrder extends Model
{
    use SoftDeletes, UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'supplier_id', 'purchase_number', 'purchase_date', 'expected_date', 'status', 'discount', 'tax', 'transport_cost', 'other_cost', 'subtotal', 'total', 'notes', 'approved_by', 'approved_at', 'version', 'created_by', 'updated_by'];

    protected function casts(): array
    {
        return ['purchase_date' => 'date', 'expected_date' => 'date', 'approved_at' => 'datetime', 'discount' => 'decimal:2', 'tax' => 'decimal:2', 'transport_cost' => 'decimal:2', 'other_cost' => 'decimal:2', 'subtotal' => 'decimal:2', 'total' => 'decimal:2'];
    }

    public function supplier(): BelongsTo
    {
        return $this->belongsTo(Supplier::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(PurchaseOrderItem::class);
    }

    public function receipts(): HasMany
    {
        return $this->hasMany(GoodsReceipt::class);
    }
}

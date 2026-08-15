<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MilkSaleReturn extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'milk_sale_id', 'delivery_manifest_stop_id', 'return_number', 'returned_quantity', 'rejected_quantity', 'restocked_quantity', 'disposed_quantity', 'credit_amount', 'refund_due', 'refunded_amount', 'refund_status', 'reason', 'created_by'];

    protected function casts(): array
    {
        return ['returned_quantity' => 'decimal:3', 'rejected_quantity' => 'decimal:3', 'restocked_quantity' => 'decimal:3', 'disposed_quantity' => 'decimal:3', 'credit_amount' => 'decimal:2', 'refund_due' => 'decimal:2', 'refunded_amount' => 'decimal:2'];
    }
    public function refunds(): HasMany { return $this->hasMany(CustomerRefund::class); }
}

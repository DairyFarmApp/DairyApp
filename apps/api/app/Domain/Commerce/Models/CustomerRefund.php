<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CustomerRefund extends Model
{
    use UsesUuidV7;
    protected $fillable = ['organization_id', 'farm_id', 'customer_id', 'milk_sale_id', 'milk_sale_return_id', 'refund_number', 'refund_date', 'amount', 'payment_method', 'reference', 'notes', 'created_by'];
    protected function casts(): array { return ['refund_date' => 'date', 'amount' => 'decimal:2']; }
    public function customer(): BelongsTo { return $this->belongsTo(Customer::class); }
    public function sale(): BelongsTo { return $this->belongsTo(MilkSale::class, 'milk_sale_id'); }
    public function saleReturn(): BelongsTo { return $this->belongsTo(MilkSaleReturn::class, 'milk_sale_return_id'); }
}

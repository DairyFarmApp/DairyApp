<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class MilkSale extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'customer_id', 'invoice_number', 'sold_at', 'milk_batch_date', 'quantity_litres', 'base_rate', 'fat_adjustment', 'snf_adjustment', 'quality_adjustment', 'discount', 'tax', 'delivery_charges', 'total_amount', 'paid_amount', 'balance_amount', 'payment_status', 'status', 'delivery_status', 'payment_method', 'driver', 'vehicle', 'notes', 'created_by', 'confirmed_by', 'confirmed_at', 'cancelled_by', 'cancelled_at', 'cancellation_reason'];

    protected function casts(): array
    {
        return ['sold_at' => 'datetime', 'milk_batch_date' => 'date', 'confirmed_at' => 'datetime', 'cancelled_at' => 'datetime', 'quantity_litres' => 'decimal:3', 'total_amount' => 'decimal:2', 'paid_amount' => 'decimal:2', 'balance_amount' => 'decimal:2'];
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(CustomerPayment::class);
    }

    public function deliveryManifestStop(): HasOne
    {
        return $this->hasOne(DeliveryManifestStop::class);
    }
}

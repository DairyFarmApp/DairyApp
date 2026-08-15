<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class DeliveryManifestStop extends Model
{
    use UsesUuidV7;

    protected $fillable = ['delivery_manifest_id', 'delivery_route_stop_id', 'milk_sale_id', 'customer_id', 'stop_order', 'planned_quantity', 'delivered_quantity', 'returned_quantity', 'rejected_quantity', 'status', 'delivered_at', 'acknowledged_by', 'proof_storage_path', 'proof_original_name', 'proof_mime_type', 'gps_latitude', 'gps_longitude', 'notes'];

    protected function casts(): array
    {
        return ['delivered_at' => 'datetime', 'planned_quantity' => 'decimal:3', 'delivered_quantity' => 'decimal:3', 'returned_quantity' => 'decimal:3', 'rejected_quantity' => 'decimal:3'];
    }

    public function sale(): BelongsTo
    {
        return $this->belongsTo(MilkSale::class, 'milk_sale_id');
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function saleReturn(): HasOne
    {
        return $this->hasOne(MilkSaleReturn::class);
    }
}

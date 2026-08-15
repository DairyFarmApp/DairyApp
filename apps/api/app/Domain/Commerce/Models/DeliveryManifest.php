<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class DeliveryManifest extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'delivery_route_id', 'delivery_vehicle_id', 'delivery_driver_id', 'delivery_number', 'delivery_date', 'status', 'planned_quantity', 'loaded_quantity', 'delivered_quantity', 'returned_quantity', 'rejected_quantity', 'notes', 'created_by'];

    protected function casts(): array
    {
        return ['delivery_date' => 'date', 'planned_quantity' => 'decimal:3', 'loaded_quantity' => 'decimal:3', 'delivered_quantity' => 'decimal:3', 'returned_quantity' => 'decimal:3', 'rejected_quantity' => 'decimal:3'];
    }

    public function route(): BelongsTo
    {
        return $this->belongsTo(DeliveryRoute::class, 'delivery_route_id');
    }

    public function vehicle(): BelongsTo
    {
        return $this->belongsTo(DeliveryVehicle::class, 'delivery_vehicle_id');
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(DeliveryDriver::class, 'delivery_driver_id');
    }

    public function stops(): HasMany
    {
        return $this->hasMany(DeliveryManifestStop::class)->orderBy('stop_order');
    }
}

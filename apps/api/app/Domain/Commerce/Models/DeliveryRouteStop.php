<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DeliveryRouteStop extends Model
{
    use UsesUuidV7;

    protected $fillable = ['delivery_route_id', 'customer_id', 'stop_order', 'delivery_address', 'planned_time', 'notes'];

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }
}

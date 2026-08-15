<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class DeliveryVehicle extends Model
{
    use SoftDeletes,UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'code', 'registration_number', 'description', 'capacity_litres', 'is_active'];

    protected function casts(): array
    {
        return ['capacity_litres' => 'decimal:3', 'is_active' => 'boolean'];
    }
}

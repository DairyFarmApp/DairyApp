<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class DeliveryDriver extends Model
{
    use SoftDeletes,UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'code', 'name', 'phone', 'license_number', 'is_active'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }
}

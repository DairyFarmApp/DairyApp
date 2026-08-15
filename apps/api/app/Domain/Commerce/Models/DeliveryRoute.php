<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class DeliveryRoute extends Model
{
    use SoftDeletes,UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'code', 'name', 'description', 'is_active', 'version'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function stops(): HasMany
    {
        return $this->hasMany(DeliveryRouteStop::class)->orderBy('stop_order');
    }
}

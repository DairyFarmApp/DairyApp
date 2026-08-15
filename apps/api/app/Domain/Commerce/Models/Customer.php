<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Customer extends Model
{
    use SoftDeletes, UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'code', 'name', 'customer_type', 'phone', 'email', 'address', 'delivery_address', 'tax_information', 'credit_limit', 'payment_terms_days', 'default_milk_rate', 'quality_based_pricing', 'opening_balance', 'current_balance', 'route_name', 'is_active', 'notes', 'version', 'created_by', 'updated_by'];

    protected function casts(): array
    {
        return ['credit_limit' => 'decimal:2', 'default_milk_rate' => 'decimal:2', 'quality_based_pricing' => 'boolean', 'opening_balance' => 'decimal:2', 'current_balance' => 'decimal:2', 'is_active' => 'boolean'];
    }
}

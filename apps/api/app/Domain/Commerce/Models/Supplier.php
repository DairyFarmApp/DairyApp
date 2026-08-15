<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Supplier extends Model
{
    use SoftDeletes, UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'code', 'name', 'contact_person', 'phone', 'email', 'address', 'tax_information', 'categories', 'payment_terms_days', 'credit_limit', 'opening_balance', 'current_balance', 'is_active', 'notes', 'version', 'created_by', 'updated_by'];

    protected function casts(): array
    {
        return ['categories' => 'array', 'credit_limit' => 'decimal:2', 'opening_balance' => 'decimal:2', 'current_balance' => 'decimal:2', 'is_active' => 'boolean'];
    }
}

<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class CustomerPayment extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'customer_id', 'milk_sale_id', 'payment_number', 'payment_date', 'amount', 'payment_method', 'reference', 'notes', 'created_by'];

    protected function casts(): array
    {
        return ['payment_date' => 'date', 'amount' => 'decimal:2'];
    }
}

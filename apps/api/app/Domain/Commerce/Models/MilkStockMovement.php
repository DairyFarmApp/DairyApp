<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class MilkStockMovement extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'milk_batch_date', 'milk_sale_id', 'movement_type', 'quantity_change', 'occurred_at', 'reason', 'created_by'];

    protected function casts(): array
    {
        return ['milk_batch_date' => 'date', 'quantity_change' => 'decimal:3', 'occurred_at' => 'datetime'];
    }
}

<?php

namespace App\Domain\Inventory\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class InventoryItem extends Model
{
    use SoftDeletes, UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'kind',
        'item_code',
        'barcode',
        'name',
        'category',
        'brand',
        'unit',
        'minimum_stock',
        'maximum_stock',
        'notes',
        'is_active',
        'version',
        'created_by',
        'updated_by',
    ];

    protected function casts(): array
    {
        return [
            'minimum_stock' => 'decimal:3',
            'maximum_stock' => 'decimal:3',
            'is_active' => 'boolean',
            'version' => 'integer',
        ];
    }

    public function batches(): HasMany
    {
        return $this->hasMany(InventoryBatch::class);
    }

    public function movements(): HasMany
    {
        return $this->hasMany(StockMovement::class);
    }
}

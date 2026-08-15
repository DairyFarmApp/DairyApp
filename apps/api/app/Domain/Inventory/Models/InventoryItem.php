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
        'generic_name',
        'drap_registration_number',
        'concentration',
        'milk_withdrawal_hours',
        'meat_withdrawal_days',
        'regulatory_verified_on',
        'category',
        'brand',
        'unit',
        'minimum_stock',
        'maximum_stock',
        'notes',
        'dry_matter_percent','crude_protein_percent','metabolizable_energy_mj_per_kg','fibre_percent','fat_percent','minerals_percent',
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
            'milk_withdrawal_hours' => 'integer',
            'meat_withdrawal_days' => 'integer',
            'regulatory_verified_on' => 'date',
            'dry_matter_percent'=>'decimal:3','crude_protein_percent'=>'decimal:3','metabolizable_energy_mj_per_kg'=>'decimal:3','fibre_percent'=>'decimal:3','fat_percent'=>'decimal:3','minerals_percent'=>'decimal:3',
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

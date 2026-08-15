<?php

namespace App\Domain\Feed\Models;

use App\Domain\Inventory\Models\InventoryItem;
use App\Models\Concerns\UsesUuidV7;
use App\Models\Farm;
use App\Models\Organization;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FeedRationIngredient extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'feed_ration_plan_id',
        'inventory_item_id',
        'quantity_per_animal',
        'unit',
        'estimated_cost',
    ];

    protected function casts(): array
    {
        return [
            'quantity_per_animal' => 'decimal:3',
            'estimated_cost' => 'decimal:4',
        ];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class);
    }

    public function plan(): BelongsTo
    {
        return $this->belongsTo(FeedRationPlan::class, 'feed_ration_plan_id');
    }

    public function inventoryItem(): BelongsTo
    {
        return $this->belongsTo(InventoryItem::class);
    }
}

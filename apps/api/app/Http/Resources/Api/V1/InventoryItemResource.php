<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InventoryItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $batches = $this->relationLoaded('batches') ? $this->batches : collect();
        $stock = $batches->sum(fn ($batch) => (float) $batch->current_quantity);
        $value = $batches->sum(fn ($batch) => (float) $batch->current_quantity * (float) $batch->unit_cost);

        return [
            'id' => $this->id,
            'organization_id' => $this->organization_id,
            'farm_id' => $this->farm_id,
            'kind' => $this->kind,
            'item_code' => $this->item_code,
            'barcode' => $this->barcode,
            'name' => $this->name,
            'category' => $this->category,
            'brand' => $this->brand,
            'unit' => $this->unit,
            'minimum_stock' => $this->minimum_stock,
            'maximum_stock' => $this->maximum_stock,
            'current_stock' => number_format($stock, 3, '.', ''),
            'total_value' => number_format($value, 4, '.', ''),
            'notes' => $this->notes,
            'is_active' => $this->is_active,
            'version' => $this->version,
            'batches' => $batches->map(fn ($batch) => [
                'id' => $batch->id,
                'batch_number' => $batch->batch_number,
                'supplier' => $batch->supplier,
                'purchase_date' => $batch->purchase_date?->toDateString(),
                'expiry_date' => $batch->expiry_date?->toDateString(),
                'unit_cost' => $batch->unit_cost,
                'current_quantity' => $batch->current_quantity,
                'version' => $batch->version,
            ])->values(),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
            'is_archived' => $this->trashed(),
        ];
    }
}

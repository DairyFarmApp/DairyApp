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
            'generic_name' => $this->generic_name,
            'drap_registration_number' => $this->drap_registration_number,
            'concentration' => $this->concentration,
            'milk_withdrawal_hours' => $this->milk_withdrawal_hours,
            'meat_withdrawal_days' => $this->meat_withdrawal_days,
            'regulatory_verified_on' => $this->regulatory_verified_on?->toDateString(),
            'category' => $this->category,
            'brand' => $this->brand,
            'unit' => $this->unit,
            'minimum_stock' => $this->minimum_stock,
            'maximum_stock' => $this->maximum_stock,
            'current_stock' => number_format($stock, 3, '.', ''),
            'total_value' => number_format($value, 4, '.', ''),
            'notes' => $this->notes,
            'nutrition'=>['dry_matter_percent'=>$this->dry_matter_percent,'crude_protein_percent'=>$this->crude_protein_percent,'metabolizable_energy_mj_per_kg'=>$this->metabolizable_energy_mj_per_kg,'fibre_percent'=>$this->fibre_percent,'fat_percent'=>$this->fat_percent,'minerals_percent'=>$this->minerals_percent],
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

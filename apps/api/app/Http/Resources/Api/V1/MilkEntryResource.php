<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MilkEntryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'slot_id' => $this->milk_production_slot_id,
            'organization_id' => $this->organization_id,
            'farm_id' => $this->farm_id,
            'shed_id' => $this->slot->shed_id,
            'shed_name' => $this->slot->shed?->name,
            'animal_id' => $this->animal_id,
            'animal_number' => $this->animal?->animal_number,
            'animal_name' => $this->animal?->name,
            'production_date' => $this->slot->production_date?->format('Y-m-d'),
            'session' => $this->slot->session,
            'quantity_litres' => $this->quantity_litres,
            'rejected_quantity_litres' => $this->rejected_quantity_litres,
            'sellable_quantity_litres' => number_format(
                (float) $this->quantity_litres - (float) $this->rejected_quantity_litres,
                3,
                '.',
                '',
            ),
            'rejection_reason' => $this->rejection_reason,
            'notes' => $this->notes,
            'entry_source' => $this->entry_source,
            'revision' => $this->revision,
            'is_current' => $this->is_current,
            'supersedes_entry_id' => $this->supersedes_entry_id,
            'correction_reason' => $this->correction_reason,
            'recorded_by' => $this->recorded_by,
            'recorded_by_name' => $this->recorder?->name,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}

<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FeedRationPlanResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'animal_group_id' => $this->animal_group_id,
            'production_stage' => $this->production_stage,
            'effective_date' => $this->effective_date?->format('Y-m-d'),
            'end_date' => $this->end_date?->format('Y-m-d'),
            'feeding_frequency' => $this->feeding_frequency,
            'created_by' => $this->created_by,
            'approved_by' => $this->approved_by,
            'version' => $this->version,
            'ingredients' => $this->whenLoaded('ingredients', function () {
                return $this->ingredients->map(fn ($i) => [
                    'id' => $i->id,
                    'inventory_item_id' => $i->inventory_item_id,
                    'quantity_per_animal' => $i->quantity_per_animal,
                    'unit' => $i->unit,
                    'estimated_cost' => $i->estimated_cost,
                ]);
            }),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}

<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AnimalFeedConsumptionResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'animal_id' => $this->animal_id,
            'inventory_item_id' => $this->inventory_item_id,
            'inventory_item_name' => $this->whenLoaded('item', fn () => $this->item->name),
            'date' => $this->date->toDateString(),
            'session' => $this->session,
            'quantity' => $this->quantity,
            'unit' => $this->unit,
            'notes' => $this->notes,
            'recorded_by' => $this->recorded_by,
            'recorded_by_name' => $this->whenLoaded('recorder', fn () => $this->recorder->name),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}

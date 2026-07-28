<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AnimalStatusChangeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'organization_id' => $this->organization_id,
            'farm_id' => $this->farm_id,
            'farm_name' => $this->whenLoaded('farm', fn () => $this->farm?->name),
            'animal_id' => $this->animal_id,
            'animal_number' => $this->whenLoaded('animal', fn () => $this->animal?->animal_number),
            'previous_status' => $this->previous_status,
            'new_status' => $this->new_status,
            'effective_at' => $this->effective_at?->toISOString(),
            'reason' => $this->reason,
            'changed_by' => $this->changed_by,
            'changed_by_name' => $this->whenLoaded('changer', fn () => $this->changer?->name),
            'sequence' => $this->sequence,
            'animal_version' => $this->whenLoaded('animal', fn () => $this->animal?->version),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}

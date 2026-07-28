<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AnimalWeightResource extends JsonResource
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
            'entered_value' => $this->entered_value,
            'entered_unit' => $this->entered_unit,
            'normalized_kg' => $this->normalized_kg,
            'observed_at' => $this->observed_at?->toISOString(),
            'source' => $this->source,
            'notes' => $this->notes,
            'recorded_by' => $this->recorded_by,
            'recorded_by_name' => $this->whenLoaded('recorder', fn () => $this->recorder?->name),
            'supersedes_weight_id' => $this->supersedes_weight_id,
            'superseded_by_weight_id' => $this->superseded_by_weight_id,
            'correction_reason' => $this->correction_reason,
            'is_superseded' => $this->is_superseded,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}

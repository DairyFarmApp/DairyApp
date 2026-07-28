<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AnimalResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $membership = $request->attributes->get('membership');
        $latestWeight = $this->relationLoaded('latestWeight')
            && $this->latestWeight !== null
            && $membership?->can('animals.view_weight_history')
            && $membership?->canAccessFarm($this->latestWeight->farm_id)
                ? (new AnimalWeightResource($this->latestWeight))->resolve($request)
                : null;

        return [
            'id' => $this->id,
            'organization_id' => $this->organization_id,
            'animal_number' => $this->animal_number,
            'ear_tag_number' => $this->ear_tag_number,
            'rfid_number' => $this->rfid_number,
            'name' => $this->name,
            'registration_number' => $this->registration_number,
            'species_id' => $this->species_id,
            'species_name' => $this->whenLoaded('species', fn () => $this->species?->name),
            'breed_id' => $this->breed_id,
            'breed_name' => $this->whenLoaded('breed', fn () => $this->breed?->name),
            'sex' => $this->sex,
            'life_stage' => $this->life_stage,
            'date_of_birth' => $this->date_of_birth?->toDateString(),
            'is_date_of_birth_estimated' => $this->is_date_of_birth_estimated,
            'colour' => $this->colour,
            'identifying_marks' => $this->identifying_marks,
            'current_farm_id' => $this->current_farm_id,
            'current_farm_name' => $this->whenLoaded('currentFarm', fn () => $this->currentFarm?->name),
            'current_shed_id' => $this->current_shed_id,
            'current_shed_name' => $this->whenLoaded('currentShed', fn () => $this->currentShed?->name),
            'current_animal_group_id' => $this->current_animal_group_id,
            'current_animal_group_name' => $this->whenLoaded('currentGroup', fn () => $this->currentGroup?->name),
            'mother_animal_id' => $this->mother_animal_id,
            'mother_animal_number' => $this->whenLoaded('mother', fn () => $this->mother?->animal_number),
            'father_animal_id' => $this->father_animal_id,
            'father_animal_number' => $this->whenLoaded('father', fn () => $this->father?->animal_number),
            'external_sire_reference' => $this->external_sire_reference,
            'origin' => $this->origin,
            'acquisition_date' => $this->acquisition_date?->toDateString(),
            'source_description' => $this->source_description,
            'notes' => $this->notes,
            'operational_status' => $this->operational_status,
            'latest_weight' => $latestWeight,
            'version' => $this->version,
            'created_by' => $this->created_by,
            'updated_by' => $this->updated_by,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
            'archived_at' => $this->archived_at?->toISOString(),
            'is_archived' => $this->trashed(),
        ];
    }
}

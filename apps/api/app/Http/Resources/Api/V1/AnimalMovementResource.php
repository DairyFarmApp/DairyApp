<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AnimalMovementResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'organization_id' => $this->organization_id,
            'animal_id' => $this->animal_id,
            'animal_number' => $this->whenLoaded('animal', fn () => $this->animal?->animal_number),
            'source_farm_id' => $this->source_farm_id,
            'source_farm_name' => $this->whenLoaded('sourceFarm', fn () => $this->sourceFarm?->name),
            'source_shed_id' => $this->source_shed_id,
            'source_shed_name' => $this->whenLoaded('sourceShed', fn () => $this->sourceShed?->name),
            'source_animal_group_id' => $this->source_animal_group_id,
            'source_animal_group_name' => $this->whenLoaded('sourceGroup', fn () => $this->sourceGroup?->name),
            'destination_farm_id' => $this->destination_farm_id,
            'destination_farm_name' => $this->whenLoaded('destinationFarm', fn () => $this->destinationFarm?->name),
            'destination_shed_id' => $this->destination_shed_id,
            'destination_shed_name' => $this->whenLoaded('destinationShed', fn () => $this->destinationShed?->name),
            'destination_animal_group_id' => $this->destination_animal_group_id,
            'destination_animal_group_name' => $this->whenLoaded('destinationGroup', fn () => $this->destinationGroup?->name),
            'requested_effective_at' => $this->requested_effective_at?->toISOString(),
            'actual_effective_at' => $this->actual_effective_at?->toISOString(),
            'reason' => $this->reason,
            'notes' => $this->notes,
            'status' => $this->status,
            'approval_required' => $this->approval_required,
            'requested_by' => $this->requested_by,
            'requested_by_name' => $this->whenLoaded('requester', fn () => $this->requester?->name),
            'decided_by' => $this->decided_by,
            'decided_by_name' => $this->whenLoaded('decisionMaker', fn () => $this->decisionMaker?->name),
            'decision_at' => $this->decision_at?->toISOString(),
            'rejection_reason' => $this->rejection_reason,
            'cancellation_reason' => $this->cancellation_reason,
            'version' => $this->version,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}

<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DailyFeedIssueResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'shed_id' => $this->shed_id,
            'animal_group_id' => $this->animal_group_id,
            'date' => $this->date?->format('Y-m-d'),
            'inventory_item_id' => $this->inventory_item_id,
            'planned_quantity' => $this->planned_quantity,
            'issued_quantity' => $this->issued_quantity,
            'consumed_quantity' => $this->consumed_quantity,
            'wasted_quantity' => $this->wasted_quantity,
            'returned_quantity' => $this->returned_quantity,
            'inventory_posted' => $this->inventory_posted, 'inventory_net_quantity' => $this->inventory_net_quantity,
            'employee_id' => $this->employee_id,
            'notes' => $this->notes,
            'version' => $this->version,
            'created_by' => $this->created_by,
            'updated_by' => $this->updated_by,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}

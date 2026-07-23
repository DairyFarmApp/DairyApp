<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ShedResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return ['id' => $this->id, 'organization_id' => $this->organization_id, 'farm_id' => $this->farm_id, 'name' => $this->name, 'code' => $this->code, 'version' => $this->version, 'updated_at' => $this->updated_at?->toISOString(), 'is_deleted' => $this->trashed()];
    }
}

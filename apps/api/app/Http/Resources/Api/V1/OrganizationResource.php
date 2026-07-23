<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrganizationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return ['id' => $this->id, 'name' => $this->name, 'timezone' => $this->timezone, 'locale' => $this->locale, 'version' => $this->version, 'updated_at' => $this->updated_at?->toISOString()];
    }
}

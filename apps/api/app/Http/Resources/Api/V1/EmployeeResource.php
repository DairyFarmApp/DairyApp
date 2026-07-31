<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EmployeeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'organization_id' => $this->organization_id,
            'farm_id' => $this->farm_id,
            'shed_id' => $this->shed_id,
            'employee_number' => $this->employee_number,
            'name' => $this->name,
            'phone' => $this->phone,
            'email' => $this->email,
            'designation' => $this->designation,
            'department' => $this->department,
            'joining_date' => $this->joining_date?->toDateString(),
            'employment_type' => $this->employment_type,
            'monthly_salary' => $this->monthly_salary,
            'currency' => 'PKR',
            'address' => $this->address,
            'emergency_contact' => $this->emergency_contact,
            'notes' => $this->notes,
            'is_active' => $this->is_active,
            'version' => $this->version,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}

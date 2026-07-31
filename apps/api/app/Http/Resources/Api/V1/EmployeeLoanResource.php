<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EmployeeLoanResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'employee_id' => $this->employee_id,
            'employee_number' => $this->whenLoaded('employee', fn () => $this->employee->employee_number),
            'employee_name' => $this->whenLoaded('employee', fn () => $this->employee->name),
            'loan_number' => $this->loan_number,
            'disbursement_date' => $this->disbursement_date?->toDateString(),
            'principal_amount' => $this->principal_amount,
            'monthly_installment' => $this->monthly_installment,
            'recovered_amount' => $this->recovered_amount,
            'outstanding_amount' => $this->outstanding_amount,
            'first_recovery_month' => $this->first_recovery_month?->format('Y-m'),
            'reason' => $this->reason,
            'notes' => $this->notes,
            'status' => $this->status,
            'currency' => 'PKR',
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}

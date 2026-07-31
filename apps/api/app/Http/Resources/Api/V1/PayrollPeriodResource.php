<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PayrollPeriodResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $entries = $this->relationLoaded('entries') ? $this->entries : collect();

        return [
            'id' => $this->id,
            'period_month' => $this->period_month?->format('Y-m'),
            'status' => $this->status,
            'currency' => 'PKR',
            'total_basic_salary' => $this->total_basic_salary,
            'total_loan_deduction' => $this->total_loan_deduction,
            'total_net_salary' => $this->total_net_salary,
            'approved_at' => $this->approved_at?->toISOString(),
            'paid_at' => $this->paid_at?->toISOString(),
            'entries' => $entries->map(fn ($entry) => [
                'id' => $entry->id,
                'employee_id' => $entry->employee_id,
                'employee_number' => $entry->employee?->employee_number,
                'employee_name' => $entry->employee?->name,
                'basic_salary' => $entry->basic_salary,
                'loan_deduction' => $entry->loan_deduction,
                'bonus' => $entry->bonus,
                'other_deduction' => $entry->other_deduction,
                'net_salary' => $entry->net_salary,
            ])->values(),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}

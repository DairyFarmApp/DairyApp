<?php

namespace App\Http\Requests\Api\V1;

use App\Rules\UuidV7;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class EmployeeStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $values = [];
        foreach ([
            'employee_number', 'name', 'phone', 'email', 'designation',
            'department', 'address', 'emergency_contact', 'notes',
        ] as $field) {
            if ($this->has($field)) {
                $value = trim((string) $this->input($field));
                $values[$field] = $value === '' ? null : $value;
            }
        }
        $this->merge($values);
    }

    public function rules(): array
    {
        return [
            'id' => ['sometimes', new UuidV7],
            'employee_number' => ['nullable', 'string', 'max:60'],
            'shed_id' => ['nullable', 'uuid'],
            'name' => ['required', 'string', 'max:180'],
            'phone' => ['nullable', 'string', 'max:40'],
            'email' => ['nullable', 'email:rfc', 'max:254'],
            'designation' => ['required', 'string', 'max:120'],
            'department' => ['nullable', 'string', 'max:120'],
            'joining_date' => ['required', 'date_format:Y-m-d', 'before_or_equal:today'],
            'employment_type' => ['required', Rule::in(['full_time', 'part_time', 'contract', 'casual'])],
            'monthly_salary' => ['required', 'decimal:0,2', 'gte:0', 'max:999999999999.99'],
            'address' => ['nullable', 'string', 'max:2000'],
            'emergency_contact' => ['nullable', 'string', 'max:180'],
            'notes' => ['nullable', 'string', 'max:5000'],
        ];
    }
}

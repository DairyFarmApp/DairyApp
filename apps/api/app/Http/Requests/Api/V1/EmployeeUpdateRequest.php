<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class EmployeeUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $values = [];
        foreach ([
            'name', 'phone', 'email', 'designation', 'department', 'address',
            'emergency_contact', 'notes',
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
            'version' => ['required', 'integer', 'min:1'],
            'shed_id' => ['sometimes', 'nullable', 'uuid'],
            'name' => ['sometimes', 'required', 'string', 'max:180'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:40'],
            'email' => ['sometimes', 'nullable', 'email:rfc', 'max:254'],
            'designation' => ['sometimes', 'required', 'string', 'max:120'],
            'department' => ['sometimes', 'nullable', 'string', 'max:120'],
            'joining_date' => ['sometimes', 'date_format:Y-m-d', 'before_or_equal:today'],
            'employment_type' => ['sometimes', Rule::in(['full_time', 'part_time', 'contract', 'casual'])],
            'monthly_salary' => ['sometimes', 'decimal:0,2', 'gte:0', 'max:999999999999.99'],
            'address' => ['sometimes', 'nullable', 'string', 'max:2000'],
            'emergency_contact' => ['sometimes', 'nullable', 'string', 'max:180'],
            'notes' => ['sometimes', 'nullable', 'string', 'max:5000'],
        ];
    }
}

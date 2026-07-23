<?php

namespace App\Http\Requests\Api\V1;

use App\Rules\UuidV7;
use Illuminate\Foundation\Http\FormRequest;

class AnimalMovementStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $values = [];
        foreach (['reason', 'notes'] as $field) {
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
            'source_farm_id' => ['required', 'uuid'],
            'source_shed_id' => ['required', 'uuid'],
            'source_animal_group_id' => ['nullable', 'uuid'],
            'destination_farm_id' => ['required', 'uuid'],
            'destination_shed_id' => ['required', 'uuid'],
            'destination_animal_group_id' => ['nullable', 'uuid'],
            'requested_effective_at' => ['required', 'date', 'before_or_equal:now'],
            'reason' => ['required', 'string', 'max:255'],
            'notes' => ['nullable', 'string', 'max:5000'],
        ];
    }
}

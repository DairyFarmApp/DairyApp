<?php

namespace App\Http\Requests\Api\V1;

use App\Rules\UuidV7;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AnimalWeightCorrectionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $values = [];
        foreach (['value', 'notes', 'correction_reason'] as $field) {
            if ($this->has($field)) {
                $value = trim((string) $this->input($field));
                $values[$field] = $value === '' ? null : $value;
            }
        }
        if ($this->has('unit')) {
            $values['unit'] = strtolower(trim((string) $this->input('unit')));
        }
        $this->merge($values);
    }

    public function rules(): array
    {
        return [
            'id' => ['sometimes', new UuidV7],
            'value' => ['required', 'string', 'regex:/^\d{1,12}(?:\.\d{1,6})?$/'],
            'unit' => ['required', Rule::in(['kg', 'lb'])],
            'notes' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'correction_reason' => ['required', 'string', 'max:2000'],
        ];
    }
}

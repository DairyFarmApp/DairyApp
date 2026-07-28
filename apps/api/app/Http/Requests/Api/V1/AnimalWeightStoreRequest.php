<?php

namespace App\Http\Requests\Api\V1;

use App\Rules\UuidV7;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AnimalWeightStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $values = [];
        foreach (['value', 'notes'] as $field) {
            if ($this->has($field)) {
                $value = trim((string) $this->input($field));
                $values[$field] = $value === '' ? null : $value;
            }
        }
        if ($this->has('unit')) {
            $values['unit'] = strtolower(trim((string) $this->input('unit')));
        }
        if ($this->has('source')) {
            $values['source'] = strtolower(trim((string) $this->input('source')));
        }
        $this->merge($values);
    }

    public function rules(): array
    {
        return [
            'id' => ['sometimes', new UuidV7],
            'farm_id' => ['required', new UuidV7],
            'value' => ['required', 'string', 'regex:/^\d{1,12}(?:\.\d{1,6})?$/'],
            'unit' => ['required', Rule::in(['kg', 'lb'])],
            'observed_at' => ['required', 'date', 'before_or_equal:'.now()->addMinutes(5)->toDateTimeString()],
            'source' => ['required', Rule::in(['manual', 'scale', 'estimated', 'imported'])],
            'notes' => ['nullable', 'string', 'max:5000'],
        ];
    }
}

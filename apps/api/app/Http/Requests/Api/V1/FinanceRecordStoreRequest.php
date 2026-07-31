<?php

namespace App\Http\Requests\Api\V1;

use App\Rules\UuidV7;
use Illuminate\Foundation\Http\FormRequest;

class FinanceRecordStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $values = [];
        foreach (['category', 'party', 'reference', 'description'] as $field) {
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
            'recorded_on' => ['required', 'date_format:Y-m-d', 'before_or_equal:today'],
            'category' => ['required', 'string', 'max:100'],
            'party' => ['nullable', 'string', 'max:180'],
            'amount' => ['required', 'decimal:0,2', 'gt:0', 'max:999999999999.99'],
            'reference' => ['nullable', 'string', 'max:160'],
            'description' => ['nullable', 'string', 'max:5000'],
        ];
    }
}

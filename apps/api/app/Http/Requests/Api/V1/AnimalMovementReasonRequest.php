<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class AnimalMovementReasonRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('reason')) {
            $this->merge(['reason' => trim((string) $this->input('reason'))]);
        }
    }

    public function rules(): array
    {
        return [
            'version' => ['required', 'integer', 'min:1'],
            'reason' => ['required', 'string', 'max:2000'],
        ];
    }
}

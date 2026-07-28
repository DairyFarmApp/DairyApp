<?php

namespace App\Http\Requests\Api\V1;

use App\Rules\UuidV7;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AnimalStatusChangeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $values = [];
        if ($this->has('reason')) {
            $values['reason'] = trim((string) $this->input('reason'));
        }
        if ($this->has('new_status')) {
            $values['new_status'] = strtolower(trim((string) $this->input('new_status')));
        }
        $this->merge($values);
    }

    public function rules(): array
    {
        return [
            'id' => ['sometimes', new UuidV7],
            'new_status' => ['required', Rule::in(['active', 'inactive', 'missing'])],
            'effective_at' => ['required', 'date', 'before_or_equal:now'],
            'reason' => ['required', 'string', 'max:2000'],
            'version' => ['required', 'integer', 'min:1'],
        ];
    }
}

<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ProfileUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $values = [];
        foreach (['name', 'email', 'phone_number'] as $field) {
            if ($this->has($field)) {
                $values[$field] = trim((string) $this->input($field));
            }
        }
        if (array_key_exists('email', $values)) {
            $values['email'] = strtolower($values['email']);
        }
        $this->merge($values);
    }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'required', 'string', 'min:2', 'max:160'],
            'email' => [
                'sometimes',
                'required',
                'email',
                'max:255',
                Rule::unique('users', 'email')->ignore($this->user()?->id),
            ],
            'phone_number' => ['sometimes', 'nullable', 'string', 'max:40', 'regex:/^[0-9+(). -]{7,40}$/'],
            'current_password' => ['required_with:email', 'string'],
        ];
    }
}

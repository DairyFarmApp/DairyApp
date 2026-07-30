<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class FamilySignupRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'name' => trim((string) $this->input('name')),
            'email' => strtolower(trim((string) $this->input('email'))),
            'phone_number' => trim((string) $this->input('phone_number')),
        ]);
    }

    public function rules(): array
    {
        return [
            'invitation_token' => ['required', 'string', 'max:250'],
            'name' => ['required', 'string', 'min:2', 'max:160'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'phone_number' => ['nullable', 'string', 'max:40', 'regex:/^[0-9+(). -]{7,40}$/'],
            'password' => ['required', 'confirmed', Password::min(10)->letters()->numbers()],
            'device_id' => ['nullable', 'uuid'],
            'device_name' => ['nullable', 'string', 'max:120'],
        ];
    }
}

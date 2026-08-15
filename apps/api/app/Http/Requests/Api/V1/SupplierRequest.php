<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class SupplierRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $required = $this->isMethod('post') ? 'required' : 'sometimes';

        return [
            'farm_id' => [$required, 'uuid'], 'name' => [$required, 'string', 'max:180'],
            'contact_person' => ['nullable', 'string', 'max:160'], 'phone' => ['nullable', 'string', 'max:40'],
            'email' => ['nullable', 'email', 'max:190'], 'address' => ['nullable', 'string', 'max:2000'],
            'tax_information' => ['nullable', 'string', 'max:190'], 'categories' => ['nullable', 'array', 'max:20'],
            'categories.*' => ['string', 'max:80'], 'payment_terms_days' => ['sometimes', 'integer', 'min:0', 'max:3650'],
            'credit_limit' => ['sometimes', 'numeric', 'min:0', 'max:999999999999.99'],
            'opening_balance' => [$this->isMethod('post') ? 'sometimes' : 'prohibited', 'numeric', 'min:0', 'max:999999999999.99'],
            'is_active' => ['sometimes', 'boolean'], 'notes' => ['nullable', 'string', 'max:4000'],
            'version' => [$this->isMethod('patch') ? 'required' : 'sometimes', 'integer', 'min:1'],
        ];
    }
}

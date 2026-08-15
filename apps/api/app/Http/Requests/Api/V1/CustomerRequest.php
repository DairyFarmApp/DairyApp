<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CustomerRequest extends FormRequest
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
            'customer_type' => [$required, Rule::in(['individual', 'shop', 'distributor', 'milk_collection_company', 'factory', 'institution'])],
            'phone' => ['nullable', 'string', 'max:40'], 'email' => ['nullable', 'email', 'max:190'],
            'address' => ['nullable', 'string', 'max:2000'], 'delivery_address' => ['nullable', 'string', 'max:2000'],
            'tax_information' => ['nullable', 'string', 'max:190'], 'credit_limit' => ['sometimes', 'numeric', 'min:0', 'max:999999999999.99'],
            'payment_terms_days' => ['sometimes', 'integer', 'min:0', 'max:3650'], 'default_milk_rate' => ['nullable', 'numeric', 'min:0', 'max:99999999.99'],
            'quality_based_pricing' => ['sometimes', 'boolean'],
            'opening_balance' => [$this->isMethod('post') ? 'sometimes' : 'prohibited', 'numeric', 'min:0', 'max:999999999999.99'],
            'route_name' => ['nullable', 'string', 'max:160'], 'is_active' => ['sometimes', 'boolean'],
            'notes' => ['nullable', 'string', 'max:4000'], 'version' => [$this->isMethod('patch') ? 'required' : 'sometimes', 'integer', 'min:1'],
        ];
    }
}

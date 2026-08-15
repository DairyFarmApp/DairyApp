<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class InventoryItemUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:180'],
            'generic_name' => ['nullable', 'string', 'max:180'],
            'drap_registration_number' => ['nullable', 'string', 'max:100'],
            'concentration' => ['nullable', 'string', 'max:100'],
            'milk_withdrawal_hours' => ['nullable', 'integer', 'min:0', 'max:8760'],
            'meat_withdrawal_days' => ['nullable', 'integer', 'min:0', 'max:3650'],
            'regulatory_verified_on' => ['nullable', 'date', 'before_or_equal:today'],
            'category' => ['required', 'string', 'max:100'],
            'barcode' => ['nullable', 'string', 'max:120'],
            'brand' => ['nullable', 'string', 'max:160'],
            'unit' => ['required', 'string', 'max:40'],
            'minimum_stock' => ['required', 'string', 'regex:/^\d{1,14}(?:\.\d{1,3})?$/'],
            'maximum_stock' => ['nullable', 'string', 'regex:/^\d{1,14}(?:\.\d{1,3})?$/', 'gte:minimum_stock'],
            'notes' => ['nullable', 'string', 'max:5000'],
            'version' => ['required', 'integer', 'min:1'],
        ];
    }
}

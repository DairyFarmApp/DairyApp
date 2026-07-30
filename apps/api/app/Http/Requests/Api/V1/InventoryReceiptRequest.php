<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class InventoryReceiptRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'batch_number' => ['required', 'string', 'max:120'],
            'supplier' => ['nullable', 'string', 'max:180'],
            'purchase_date' => ['nullable', 'date'],
            'expiry_date' => ['nullable', 'date', 'after_or_equal:purchase_date'],
            'quantity' => ['required', 'string', 'regex:/^\d{1,14}(?:\.\d{1,3})?$/', 'not_in:0,0.0,0.00,0.000'],
            'unit_cost' => ['required', 'string', 'regex:/^\d{1,14}(?:\.\d{1,4})?$/'],
            'reason' => ['nullable', 'string', 'max:1000'],
        ];
    }
}

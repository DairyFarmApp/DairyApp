<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class PurchaseOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return ['farm_id' => ['required', 'uuid'], 'supplier_id' => ['required', 'uuid'], 'purchase_date' => ['required', 'date'], 'expected_date' => ['nullable', 'date', 'after_or_equal:purchase_date'], 'discount' => ['sometimes', 'numeric', 'min:0'], 'tax' => ['sometimes', 'numeric', 'min:0'], 'transport_cost' => ['sometimes', 'numeric', 'min:0'], 'other_cost' => ['sometimes', 'numeric', 'min:0'], 'notes' => ['nullable', 'string', 'max:4000'], 'items' => ['required', 'array', 'min:1', 'max:100'], 'items.*.inventory_item_id' => ['required', 'uuid', 'distinct'], 'items.*.quantity' => ['required', 'numeric', 'gt:0'], 'items.*.unit_rate' => ['required', 'numeric', 'min:0']];
    }
}

<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class GoodsReceiptRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return ['received_at' => ['sometimes', 'date'], 'quality_status' => ['required', Rule::in(['accepted', 'conditionally_accepted', 'rejected'])], 'notes' => ['nullable', 'string', 'max:4000'], 'items' => ['required', 'array', 'min:1'], 'items.*.purchase_order_item_id' => ['required', 'uuid', 'distinct'], 'items.*.batch_number' => ['required', 'string', 'max:100'], 'items.*.expiry_date' => ['nullable', 'date'], 'items.*.quantity' => ['required', 'numeric', 'gt:0']];
    }
}

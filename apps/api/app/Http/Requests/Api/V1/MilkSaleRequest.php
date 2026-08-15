<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class MilkSaleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return ['customer_id' => ['required', 'uuid'], 'sold_at' => ['required', 'date'], 'milk_batch_date' => ['required', 'date'], 'quantity_litres' => ['required', 'numeric', 'gt:0'], 'base_rate' => ['required', 'numeric', 'min:0'], 'fat_adjustment' => ['sometimes', 'numeric'], 'snf_adjustment' => ['sometimes', 'numeric'], 'quality_adjustment' => ['sometimes', 'numeric'], 'discount' => ['sometimes', 'numeric', 'min:0'], 'tax' => ['sometimes', 'numeric', 'min:0'], 'delivery_charges' => ['sometimes', 'numeric', 'min:0'], 'delivery_status' => ['sometimes', Rule::in(['pending', 'dispatched', 'delivered', 'partially_delivered'])], 'driver' => ['nullable', 'string', 'max:160'], 'vehicle' => ['nullable', 'string', 'max:100'], 'notes' => ['nullable', 'string', 'max:4000']];
    }
}

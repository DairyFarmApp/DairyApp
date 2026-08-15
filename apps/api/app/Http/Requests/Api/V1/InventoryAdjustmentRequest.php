<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class InventoryAdjustmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->attributes->get('membership')->can('inventory.adjust');
    }

    public function rules(): array
    {
        return ['batch_id' => ['required', 'uuid'], 'adjustment_type' => ['required', Rule::in(['increase', 'decrease', 'damage', 'expiry'])], 'quantity' => ['required', 'numeric', 'min:0.001'], 'occurred_at' => ['required', 'date', 'before_or_equal:now'], 'reason' => ['required', 'string', 'min:10', 'max:2000']];
    }
}

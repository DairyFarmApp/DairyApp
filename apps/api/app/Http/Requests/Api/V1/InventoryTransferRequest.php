<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class InventoryTransferRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->attributes->get('membership')->can('inventory.transfer');
    }

    public function rules(): array
    {
        return ['destination_farm_id' => ['required', 'uuid', 'different:source_farm_id'], 'quantity' => ['required', 'numeric', 'min:0.001'], 'transferred_at' => ['required', 'date', 'before_or_equal:now'], 'reason' => ['required', 'string', 'min:10', 'max:2000']];
    }
}

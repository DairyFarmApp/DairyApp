<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class InventoryUsageRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'quantity' => ['required', 'decimal:0,3', 'gt:0', 'max:999999999999999.999'],
            'occurred_at' => ['nullable', 'date', 'before_or_equal:now'],
            'purpose' => ['required', 'string', 'max:500'],
        ];
    }
}

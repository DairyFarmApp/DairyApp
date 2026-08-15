<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class AnimalFeedConsumptionStoreRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'inventory_item_id' => ['required', 'uuid'],
            'date' => ['required', 'date', 'before_or_equal:today'],
            'session' => ['required', 'string', 'max:24'],
            'quantity' => ['required', 'numeric', 'min:0.001'],
            'unit' => ['required', 'string', 'max:16'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}

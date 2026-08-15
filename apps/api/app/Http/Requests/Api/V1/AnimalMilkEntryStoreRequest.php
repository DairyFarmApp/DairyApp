<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class AnimalMilkEntryStoreRequest extends FormRequest
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
            'production_date' => ['required', 'date', 'before_or_equal:today'],
            'session' => ['required', 'string', 'max:24'],
            'quantity_litres' => ['required', 'numeric', 'min:0.001'],
            'rejected_quantity_litres' => ['nullable', 'numeric', 'min:0'],
            'rejection_reason' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}

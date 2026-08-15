<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class PreventiveCareStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->attributes->get('membership')->can('health.preventive.manage');
    }

    public function rules(): array
    {
        return [
            'animal_ids' => ['required', 'array', 'min:1', 'max:500'], 'animal_ids.*' => ['uuid', 'distinct'], 'inventory_item_id' => ['required', 'uuid'],
            'type' => ['required', Rule::in(['vaccination', 'deworming'])], 'disease_covered' => ['nullable', 'required_if:type,vaccination', 'string', 'max:200'],
            'dose' => ['required', 'numeric', 'min:0.001'], 'dose_unit' => ['required', 'string', 'max:24'], 'inventory_quantity_used_per_animal' => ['required', 'numeric', 'min:0.001'],
            'administered_at' => ['required', 'date', 'before_or_equal:now'], 'next_due_date' => ['nullable', 'date', 'after:administered_at'],
            'veterinarian_name' => ['nullable', 'required_if:type,vaccination', 'string', 'max:160'], 'administered_by_name' => ['required', 'string', 'max:160'],
            'cost_pkr_per_animal' => ['required', 'numeric', 'min:0', 'max:999999999999.99'], 'reaction' => ['nullable', 'string', 'max:2000'], 'notes' => ['nullable', 'string', 'max:2000'],
        ];
    }
}

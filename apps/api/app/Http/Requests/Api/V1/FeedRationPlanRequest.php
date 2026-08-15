<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class FeedRationPlanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->attributes->get('membership')->can('inventory.manage');
    }

    public function rules(): array
    {
        return [
            'id' => ['nullable', 'uuid'],
            'name' => ['required', 'string', 'max:180'],
            'animal_group_id' => ['nullable', 'uuid'],
            'production_stage' => ['nullable', 'string', 'max:60'],
            'effective_date' => ['required', 'date'],
            'end_date' => ['nullable', 'date', 'after_or_equal:effective_date'],
            'feeding_frequency' => ['required', 'integer', 'min:1', 'max:24'],
            'ingredients' => ['required', 'array', 'min:1'],
            'ingredients.*.inventory_item_id' => ['required', 'uuid'],
            'ingredients.*.quantity_per_animal' => ['required', 'numeric', 'min:0.001'],
            'ingredients.*.unit' => ['required', 'string', 'max:40'],
        ];
    }
}

<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AnimalTreatmentStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->attributes->get('membership')->can('health.treat');
    }

    public function rules(): array
    {
        return ['health_case_id' => ['required', 'uuid'], 'inventory_item_id' => ['required', 'uuid'], 'administered_at' => ['required', 'date', 'before_or_equal:now'], 'animal_weight_kg' => ['required', 'numeric', 'min:1', 'max:2000'], 'dose' => ['required', 'numeric', 'min:0.001'], 'dose_unit' => ['required', 'string', 'max:24'], 'route' => ['required', Rule::in(['oral', 'intramuscular', 'subcutaneous', 'intravenous', 'intramammary', 'topical', 'other'])], 'frequency' => ['required', 'string', 'max:80'], 'duration_days' => ['required', 'integer', 'min:1', 'max:365'], 'inventory_quantity_used' => ['required', 'numeric', 'min:0.001'], 'veterinarian_name' => ['required', 'string', 'max:160'], 'veterinarian_instructions' => ['required', 'string', 'max:2000'], 'notes' => ['nullable', 'string', 'max:2000']];
    }
}

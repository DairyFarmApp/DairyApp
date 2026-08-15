<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class BreedingEventRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->attributes->get('membership')->can('breeding.manage');
    }

    public function rules(): array
    {
        $event = $this->route('event');

        return match ($event) {
            'heat' => ['detected_at' => ['required', 'date', 'before_or_equal:now'], 'symptoms' => ['required', 'array', 'min:1'], 'symptoms.*' => ['string', 'max:100'], 'detection_method' => ['required', 'string', 'max:80'], 'detected_by_name' => ['required', 'string', 'max:160'], 'intensity' => ['required', Rule::in(['weak', 'moderate', 'strong'])], 'recommended_action' => ['required', 'string', 'max:1000'], 'notes' => ['nullable', 'string', 'max:2000']], 'service' => ['heat_record_id' => ['nullable', 'uuid'], 'bred_at' => ['required', 'date', 'before_or_equal:now'], 'method' => ['required', Rule::in(['natural', 'artificial'])], 'bull_animal_id' => ['nullable', 'required_if:method,natural', 'uuid'], 'semen_item_id' => ['nullable', 'required_if:method,artificial', 'uuid'], 'semen_straw_number' => ['nullable', 'required_if:method,artificial', 'string', 'max:160'], 'breed_name' => ['nullable', 'string', 'max:160'], 'supplier' => ['nullable', 'string', 'max:160'], 'technician_name' => ['required', 'string', 'max:160'], 'cost_pkr' => ['required', 'numeric', 'min:0'], 'notes' => ['nullable', 'string', 'max:2000']], 'pregnancy-check' => ['breeding_service_id' => ['required', 'uuid'], 'checked_on' => ['required', 'date', 'before_or_equal:today'], 'method' => ['required', 'string', 'max:80'], 'veterinarian_name' => ['required', 'string', 'max:160'], 'result' => ['required', Rule::in(['pregnant', 'not_pregnant', 'uncertain'])], 'estimated_age_days' => ['nullable', 'required_if:result,pregnant', 'integer', 'min:1', 'max:330'], 'follow_up_date' => ['nullable', 'date', 'after:checked_on'], 'notes' => ['nullable', 'string', 'max:2000']], 'calving' => ['pregnancy_check_id' => ['required', 'uuid'], 'calved_at' => ['required', 'date', 'before_or_equal:now'], 'calving_type' => ['required', Rule::in(['normal', 'assisted', 'difficult', 'caesarean'])], 'veterinarian_name' => ['nullable', 'string', 'max:160'], 'complications' => ['nullable', 'string', 'max:2000'], 'placenta_status' => ['required', Rule::in(['normal', 'retained', 'unknown'])], 'mother_condition' => ['required', 'string', 'max:80'], 'treatment_required' => ['required', 'boolean'], 'notes' => ['nullable', 'string', 'max:2000'], 'calves' => ['required', 'array', 'min:1', 'max:4'], 'calves.*.sex' => ['required', Rule::in(['female', 'male'])], 'calves.*.breed_id' => ['required', 'uuid'], 'calves.*.birth_weight_kg' => ['required', 'numeric', 'min:1', 'max:100'], 'calves.*.condition' => ['required', 'string', 'max:80'], 'calves.*.ear_tag_number' => ['nullable', 'string', 'max:80']],default => []
        };
    }
}

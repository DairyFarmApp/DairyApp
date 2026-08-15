<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CalfCareRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->attributes->get('membership')->can('calves.manage');
    }

    public function rules(): array
    {
        return ['birth_at' => ['required', 'date', 'before_or_equal:now'], 'birth_weight_kg' => ['required', 'numeric', 'min:1', 'max:100'], 'birth_condition' => ['required', 'string', 'max:80'], 'colostrum_given' => ['required', 'boolean'], 'colostrum_at' => ['nullable', 'required_if:colostrum_given,true', 'date', 'after_or_equal:birth_at'], 'colostrum_quantity_litres' => ['nullable', 'required_if:colostrum_given,true', 'numeric', 'min:0.001', 'max:20'], 'colostrum_quality' => ['nullable', 'string', 'max:40'], 'navel_treated' => ['required', 'boolean'], 'navel_treated_at' => ['nullable', 'required_if:navel_treated,true', 'date', 'after_or_equal:birth_at'], 'navel_product' => ['nullable', 'required_if:navel_treated,true', 'string', 'max:160'], 'weaning_target_date' => ['required', 'date', 'after:birth_at'], 'actual_weaning_date' => ['nullable', 'date', 'after:birth_at'], 'feed_plan' => ['nullable', 'string', 'max:255'], 'target_daily_gain_kg' => ['required', 'numeric', 'min:0.05', 'max:3'], 'health_status' => ['required', Rule::in(['normal', 'monitoring', 'sick', 'critical', 'recovered'])], 'notes' => ['nullable', 'string', 'max:2000']];
    }
}

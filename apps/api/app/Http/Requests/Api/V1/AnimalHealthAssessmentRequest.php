<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AnimalHealthAssessmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->attributes->get('membership')->can('health.assess');
    }

    public function rules(): array
    {
        return [
            'reported_at' => ['nullable', 'date', 'before_or_equal:now'],
            'severity' => ['required', Rule::in(['mild', 'moderate', 'severe'])],
            'temperature_c' => ['nullable', 'numeric', 'between:30,45'],
            'symptom_ids' => ['required', 'array', 'min:1', 'max:30'],
            'symptom_ids.*' => ['required', 'uuid', 'distinct', 'exists:health_symptoms,id'],
            'notes' => ['nullable', 'string', 'max:2000'],
        ];
    }
}

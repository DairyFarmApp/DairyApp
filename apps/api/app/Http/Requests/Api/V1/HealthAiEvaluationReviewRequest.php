<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class HealthAiEvaluationReviewRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->attributes->get('membership')->can('health.ai.review');
    }

    public function rules(): array
    {
        return [
            'decision' => ['required', Rule::in(['approved', 'rejected', 'changes_requested'])],
            'reviewer_notes' => ['required', 'string', 'min:10', 'max:3000'],
            'reviewer_name' => ['required', 'string', 'max:160'],
            'reviewer_registration' => ['required', 'string', 'max:100'],
        ];
    }
}

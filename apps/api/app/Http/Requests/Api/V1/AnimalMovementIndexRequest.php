<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AnimalMovementIndexRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'filter' => ['sometimes', 'array:status,search'],
            'filter.status' => ['sometimes', Rule::in(['pending', 'approved', 'rejected', 'cancelled'])],
            'filter.search' => ['sometimes', 'string', 'max:120'],
            'sort' => ['sometimes', Rule::in([
                'requested_effective_at',
                '-requested_effective_at',
                'actual_effective_at',
                '-actual_effective_at',
                'status',
                '-status',
            ])],
            'page' => ['sometimes', 'array:size,page'],
            'page.size' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'page.page' => ['sometimes', 'integer', 'min:1'],
        ];
    }
}

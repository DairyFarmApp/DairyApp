<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AnimalWeightIndexRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'sort' => ['sometimes', Rule::in([
                'observed_at',
                '-observed_at',
                'created_at',
                '-created_at',
            ])],
            'page' => ['sometimes', 'array:size,page'],
            'page.size' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'page.page' => ['sometimes', 'integer', 'min:1'],
        ];
    }
}

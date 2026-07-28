<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class AnimalStatusHistoryIndexRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'page' => ['sometimes', 'array:size,page'],
            'page.size' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'page.page' => ['sometimes', 'integer', 'min:1'],
        ];
    }
}

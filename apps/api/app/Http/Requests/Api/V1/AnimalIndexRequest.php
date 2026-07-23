<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AnimalIndexRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'filter.search' => ['sometimes', 'string', 'max:160'],
            'filter.species_id' => ['sometimes', 'uuid'],
            'filter.breed_id' => ['sometimes', 'uuid'],
            'filter.sex' => ['sometimes', Rule::in(['female', 'male'])],
            'filter.life_stage' => ['sometimes', Rule::in(['calf', 'juvenile', 'adult'])],
            'filter.farm_id' => ['sometimes', 'uuid'],
            'filter.shed_id' => ['sometimes', 'uuid'],
            'filter.group_id' => ['sometimes', 'uuid'],
            'filter.operational_status' => ['sometimes', Rule::in(['active', 'inactive', 'missing'])],
            'filter.archive_state' => ['sometimes', Rule::in(['active', 'archived', 'all'])],
            'sort' => ['sometimes', Rule::in(['animal_number', '-animal_number', 'name', '-name', 'date_of_birth', '-date_of_birth', 'created_at', '-created_at', 'updated_at', '-updated_at', 'operational_status', '-operational_status'])],
            'page.size' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'page.number' => ['sometimes', 'integer', 'min:1'],
        ];
    }
}

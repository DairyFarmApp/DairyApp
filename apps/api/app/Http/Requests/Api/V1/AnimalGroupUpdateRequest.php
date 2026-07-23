<?php

namespace App\Http\Requests\Api\V1;

use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Domain\AnimalRegistry\Support\AnimalRegistryNormalizer;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AnimalGroupUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $normalizer = app(AnimalRegistryNormalizer::class);
        $values = [];
        if ($this->has('code')) {
            $values['code'] = $normalizer->code((string) $this->input('code'));
        }
        if ($this->has('name')) {
            $values['name'] = trim((string) $this->input('name'));
            $values['normalized_name'] = $normalizer->name((string) $this->input('name'));
        }
        if ($this->has('description')) {
            $values['description'] = $normalizer->optionalText($this->input('description'));
        }
        $this->merge($values);
    }

    public function rules(): array
    {
        $organizationId = $this->attributes->get('organization_id');
        $groupId = $this->route('group');
        $farmId = AnimalGroup::withTrashed()
            ->where('organization_id', $organizationId)
            ->whereKey($groupId)
            ->value('farm_id');

        return [
            'farm_id' => ['prohibited'],
            'default_shed_id' => ['sometimes', 'nullable', 'uuid'],
            'code' => [
                'sometimes',
                'string',
                'max:40',
                'regex:/^[A-Z0-9][A-Z0-9-]*$/',
                Rule::unique('animal_groups', 'code')->ignore($groupId)->where(fn ($query) => $query->where('organization_id', $organizationId)->where('farm_id', $farmId)),
            ],
            'name' => ['sometimes', 'string', 'max:120'],
            'normalized_name' => [
                'sometimes',
                'string',
                'max:120',
                Rule::unique('animal_groups', 'normalized_name')->ignore($groupId)->where(fn ($query) => $query->where('organization_id', $organizationId)->where('farm_id', $farmId)),
            ],
            'description' => ['sometimes', 'nullable', 'string', 'max:2000'],
            'is_active' => ['sometimes', 'boolean'],
            'version' => ['required', 'integer', 'min:1'],
        ];
    }
}

<?php

namespace App\Http\Requests\Api\V1;

use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Domain\AnimalRegistry\Support\AnimalRegistryNormalizer;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AnimalBreedUpdateRequest extends FormRequest
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
        $breed = $this->route('breed');
        $speciesId = AnimalBreed::withTrashed()
            ->where('organization_id', $organizationId)
            ->whereKey($breed)
            ->value('species_id');

        return [
            'species_id' => ['prohibited'],
            'code' => [
                'sometimes',
                'string',
                'max:40',
                'regex:/^[A-Z0-9][A-Z0-9-]*$/',
                Rule::unique('animal_breeds', 'code')->ignore($breed)->where(fn ($query) => $query->where('organization_id', $organizationId)->where('species_id', $speciesId)),
            ],
            'name' => ['sometimes', 'string', 'max:120'],
            'normalized_name' => [
                'sometimes',
                'string',
                'max:120',
                Rule::unique('animal_breeds', 'normalized_name')->ignore($breed)->where(fn ($query) => $query->where('organization_id', $organizationId)->where('species_id', $speciesId)),
            ],
            'description' => ['sometimes', 'nullable', 'string', 'max:2000'],
            'is_active' => ['sometimes', 'boolean'],
            'version' => ['required', 'integer', 'min:1'],
        ];
    }
}

<?php

namespace App\Http\Requests\Api\V1;

use App\Domain\AnimalRegistry\Support\AnimalRegistryNormalizer;
use App\Rules\UuidV7;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AnimalBreedStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $normalizer = app(AnimalRegistryNormalizer::class);
        $this->merge([
            'code' => $normalizer->code((string) $this->input('code', '')),
            'name' => trim((string) $this->input('name', '')),
            'normalized_name' => $normalizer->name((string) $this->input('name', '')),
            'description' => $normalizer->optionalText($this->input('description')),
        ]);
    }

    public function rules(): array
    {
        return [
            'id' => ['sometimes', new UuidV7],
            'species_id' => ['required', 'uuid', Rule::exists('animal_species', 'id')->where('is_active', true)],
            'code' => [
                'required',
                'string',
                'max:40',
                'regex:/^[A-Z0-9][A-Z0-9-]*$/',
            ],
            'name' => ['required', 'string', 'max:120'],
            'normalized_name' => [
                'required',
                'string',
                'max:120',
            ],
            'description' => ['nullable', 'string', 'max:2000'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}

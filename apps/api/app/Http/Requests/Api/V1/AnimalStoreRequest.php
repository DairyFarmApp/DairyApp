<?php

namespace App\Http\Requests\Api\V1;

use App\Domain\AnimalRegistry\Support\AnimalRegistryNormalizer;
use App\Rules\UuidV7;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

class AnimalStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $normalizer = app(AnimalRegistryNormalizer::class);
        $values = [];
        foreach (['name', 'registration_number', 'colour', 'identifying_marks', 'external_sire_reference', 'source_description', 'notes'] as $field) {
            if ($this->has($field)) {
                $values[$field] = $normalizer->optionalText($this->input($field));
            }
        }
        $values['animal_number'] = $normalizer->animalNumber($this->input('animal_number'));
        $values['ear_tag_number'] = $normalizer->earTag($this->input('ear_tag_number'));
        $values['rfid_number'] = $normalizer->rfid($this->input('rfid_number'));
        $this->merge($values);
    }

    public function rules(): array
    {
        return [
            'id' => ['sometimes', new UuidV7],
            'animal_number' => ['nullable', 'string', 'max:40', 'regex:/^[A-Z0-9][A-Z0-9._\/-]*$/'],
            'ear_tag_number' => ['nullable', 'string', 'max:80', 'regex:/^[A-Z0-9][A-Z0-9._\/-]*$/'],
            'rfid_number' => ['nullable', 'string', 'max:120', 'regex:/^[A-Z0-9]+$/'],
            'name' => ['nullable', 'string', 'max:120'],
            'registration_number' => ['nullable', 'string', 'max:120'],
            'species_id' => ['required', 'uuid'],
            'breed_id' => ['required', 'uuid'],
            'sex' => ['required', Rule::in(['female', 'male'])],
            'life_stage' => ['required', Rule::in(['calf', 'juvenile', 'adult'])],
            'date_of_birth' => ['nullable', 'date', 'before_or_equal:today'],
            'is_date_of_birth_estimated' => ['sometimes', 'boolean'],
            'colour' => ['nullable', 'string', 'max:80'],
            'identifying_marks' => ['nullable', 'string', 'max:2000'],
            'current_farm_id' => ['required', 'uuid'],
            'current_shed_id' => ['required', 'uuid'],
            'current_animal_group_id' => ['nullable', 'uuid'],
            'mother_animal_id' => ['nullable', 'uuid', 'different:father_animal_id'],
            'father_animal_id' => ['nullable', 'uuid', 'different:mother_animal_id'],
            'external_sire_reference' => ['nullable', 'string', 'max:160'],
            'origin' => ['required', Rule::in(['born_on_farm', 'purchased', 'transferred_in', 'other'])],
            'acquisition_date' => ['nullable', 'date', 'before_or_equal:today'],
            'source_description' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string', 'max:5000'],
            'operational_status' => ['sometimes', Rule::in(['active', 'inactive', 'missing'])],
        ];
    }

    public function after(): array
    {
        return [
            function (Validator $validator): void {
                if ($this->filled('animal_number') && ! $this->attributes->get('membership')?->can('animals.manage_identifiers')) {
                    $validator->errors()->add('animal_number', 'You do not have permission to supply an animal number.');
                }
            },
        ];
    }
}

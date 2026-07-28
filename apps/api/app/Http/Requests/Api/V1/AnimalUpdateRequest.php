<?php

namespace App\Http\Requests\Api\V1;

use App\Domain\AnimalRegistry\Support\AnimalRegistryNormalizer;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

class AnimalUpdateRequest extends FormRequest
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
        if ($this->has('animal_number')) {
            $values['animal_number'] = $normalizer->animalNumber($this->input('animal_number'));
        }
        if ($this->has('ear_tag_number')) {
            $values['ear_tag_number'] = $normalizer->earTag($this->input('ear_tag_number'));
        }
        if ($this->has('rfid_number')) {
            $values['rfid_number'] = $normalizer->rfid($this->input('rfid_number'));
        }
        $this->merge($values);
    }

    public function rules(): array
    {
        $organizationId = $this->attributes->get('organization_id');
        $animal = $this->route('animal');

        return [
            'current_farm_id' => ['prohibited'],
            'current_shed_id' => ['prohibited'],
            'current_animal_group_id' => ['prohibited'],
            'operational_status' => ['prohibited'],
            'animal_number' => ['sometimes', 'required', 'string', 'max:40', 'regex:/^[A-Z0-9][A-Z0-9._\/-]*$/', Rule::unique('animals', 'animal_number')->ignore($animal)->where('organization_id', $organizationId)],
            'ear_tag_number' => ['sometimes', 'nullable', 'string', 'max:80', 'regex:/^[A-Z0-9][A-Z0-9._\/-]*$/', Rule::unique('animals', 'ear_tag_number')->ignore($animal)->where('organization_id', $organizationId)],
            'rfid_number' => ['sometimes', 'nullable', 'string', 'max:120', 'regex:/^[A-Z0-9]+$/', Rule::unique('animals', 'rfid_number')->ignore($animal)->where('organization_id', $organizationId)],
            'name' => ['sometimes', 'nullable', 'string', 'max:120'],
            'registration_number' => ['sometimes', 'nullable', 'string', 'max:120'],
            'species_id' => ['sometimes', 'uuid'],
            'breed_id' => ['sometimes', 'uuid'],
            'sex' => ['sometimes', Rule::in(['female', 'male'])],
            'life_stage' => ['sometimes', Rule::in(['calf', 'juvenile', 'adult'])],
            'date_of_birth' => ['sometimes', 'nullable', 'date', 'before_or_equal:today'],
            'is_date_of_birth_estimated' => ['sometimes', 'boolean'],
            'colour' => ['sometimes', 'nullable', 'string', 'max:80'],
            'identifying_marks' => ['sometimes', 'nullable', 'string', 'max:2000'],
            'mother_animal_id' => ['sometimes', 'nullable', 'uuid', 'different:father_animal_id'],
            'father_animal_id' => ['sometimes', 'nullable', 'uuid', 'different:mother_animal_id'],
            'external_sire_reference' => ['sometimes', 'nullable', 'string', 'max:160'],
            'origin' => ['sometimes', Rule::in(['born_on_farm', 'purchased', 'transferred_in', 'other'])],
            'acquisition_date' => ['sometimes', 'nullable', 'date', 'before_or_equal:today'],
            'source_description' => ['sometimes', 'nullable', 'string', 'max:255'],
            'notes' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'version' => ['required', 'integer', 'min:1'],
        ];
    }

    public function after(): array
    {
        return [
            function (Validator $validator): void {
                if ($this->hasAny(['animal_number', 'ear_tag_number', 'rfid_number'])
                    && ! $this->attributes->get('membership')?->can('animals.manage_identifiers')) {
                    $validator->errors()->add('identifiers', 'You do not have permission to update animal identifiers.');
                }
            },
        ];
    }
}

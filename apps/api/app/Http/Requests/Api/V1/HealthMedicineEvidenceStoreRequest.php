<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class HealthMedicineEvidenceStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->attributes->get('membership')->can('health.medicine_evidence.manage');
    }

    public function rules(): array
    {
        return [
            'disease_id' => ['required', 'uuid', 'exists:health_diseases,id'], 'active_ingredient' => ['required', 'string', 'max:180'], 'brand_name' => ['required', 'string', 'max:180'],
            'manufacturer' => ['required', 'string', 'max:180'], 'dosage_form' => ['required', 'string', 'max:120'], 'drap_registration_number' => ['required', 'string', 'max:100'],
            'drap_registry_url' => ['required', 'url', 'max:1000', 'starts_with:https://eapp.dra.gov.pk/,https://www.dra.gov.pk/'], 'drap_verified_on' => ['required', 'date', 'before_or_equal:today'],
            'indication' => ['required', 'string', 'max:500'], 'species_scope' => ['required', 'string', 'max:255'], 'contraindications' => ['required', 'string', 'max:3000'],
            'withdrawal_guidance' => ['required', 'string', 'max:3000'], 'source_id' => ['required', 'uuid', 'exists:health_knowledge_sources,id'],
        ];
    }
}

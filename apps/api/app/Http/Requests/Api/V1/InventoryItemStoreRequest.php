<?php

namespace App\Http\Requests\Api\V1;

use App\Rules\UuidV7;
use Illuminate\Foundation\Http\FormRequest;

class InventoryItemStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $values = [];
        foreach ([
            'item_code', 'barcode', 'name', 'category', 'brand', 'unit',
            'supplier', 'batch_number', 'notes',
            'generic_name', 'drap_registration_number', 'concentration',
        ] as $field) {
            if ($this->has($field)) {
                $value = trim((string) $this->input($field));
                $values[$field] = $value === '' ? null : $value;
            }
        }
        $this->merge($values);
    }

    public function rules(): array
    {
        $decimal = ['required', 'string', 'regex:/^\d{1,14}(?:\.\d{1,4})?$/'];

        return [
            'id' => ['sometimes', new UuidV7],
            'farm_id' => ['required', new UuidV7],
            'item_code' => ['nullable', 'string', 'max:60'],
            'barcode' => ['nullable', 'string', 'max:120'],
            'name' => ['required', 'string', 'max:180'],
            'generic_name' => ['nullable', 'required_if:kind,medicine', 'string', 'max:180'],
            'drap_registration_number' => ['nullable', 'string', 'max:100'],
            'concentration' => ['nullable', 'required_if:kind,medicine', 'string', 'max:100'],
            'milk_withdrawal_hours' => ['nullable', 'integer', 'min:0', 'max:8760'],
            'meat_withdrawal_days' => ['nullable', 'integer', 'min:0', 'max:3650'],
            'regulatory_verified_on' => ['nullable', 'date', 'before_or_equal:today'],
            'category' => ['required', 'string', 'max:100'],
            'brand' => ['nullable', 'string', 'max:160'],
            'unit' => ['required', 'string', 'max:40'],
            'minimum_stock' => ['required', 'string', 'regex:/^\d{1,14}(?:\.\d{1,3})?$/'],
            'maximum_stock' => ['nullable', 'string', 'regex:/^\d{1,14}(?:\.\d{1,3})?$/', 'gte:minimum_stock'],
            'notes' => ['nullable', 'string', 'max:5000'],
            'dry_matter_percent'=>['nullable','numeric','min:0','max:100'],'crude_protein_percent'=>['nullable','numeric','min:0','max:100'],'metabolizable_energy_mj_per_kg'=>['nullable','numeric','min:0','max:100'],'fibre_percent'=>['nullable','numeric','min:0','max:100'],'fat_percent'=>['nullable','numeric','min:0','max:100'],'minerals_percent'=>['nullable','numeric','min:0','max:100'],
            'batch_number' => ['required', 'string', 'max:120'],
            'supplier' => ['nullable', 'string', 'max:180'],
            'purchase_date' => ['nullable', 'date'],
            'expiry_date' => ['nullable', 'date', 'after_or_equal:purchase_date'],
            'opening_quantity' => ['required', 'string', 'regex:/^\d{1,14}(?:\.\d{1,3})?$/', 'not_in:0,0.0,0.00,0.000'],
            'unit_cost' => $decimal,
        ];
    }
}

<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class InventoryExportRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $itemIds = $this->query('item_ids');
        if (is_string($itemIds)) {
            $itemIds = array_values(array_filter(
                array_map('trim', explode(',', $itemIds)),
                fn (string $value): bool => $value !== '',
            ));
        }

        $prepared = [
            'from_date' => $this->query('from_date'),
            'to_date' => $this->query('to_date'),
        ];
        if ($itemIds !== null) {
            $prepared['item_ids'] = $itemIds;
        }
        $this->merge($prepared);
    }

    public function rules(): array
    {
        return [
            'item_ids' => ['sometimes', 'array', 'max:200'],
            'item_ids.*' => ['required', 'uuid', 'distinct'],
            'from_date' => ['nullable', 'date_format:Y-m-d'],
            'to_date' => ['nullable', 'date_format:Y-m-d', 'after_or_equal:from_date'],
        ];
    }
}

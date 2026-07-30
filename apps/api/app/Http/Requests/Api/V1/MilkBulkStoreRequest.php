<?php

namespace App\Http\Requests\Api\V1;

use App\Rules\UuidV7;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

class MilkBulkStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'production_date' => ['required', 'date_format:Y-m-d', 'before_or_equal:today'],
            'session' => ['required', Rule::in(['morning', 'afternoon', 'evening'])],
            'entries' => ['required', 'array', 'min:1', 'max:200'],
            'entries.*.id' => ['required', new UuidV7, 'distinct'],
            'entries.*.slot_id' => ['required', new UuidV7, 'distinct'],
            'entries.*.animal_id' => ['required', 'uuid', 'distinct'],
            'entries.*.quantity_litres' => ['required', 'decimal:0,3', 'gt:0', 'max:99999.999'],
            'entries.*.rejected_quantity_litres' => ['sometimes', 'decimal:0,3', 'gte:0', 'max:99999.999'],
            'entries.*.rejection_reason' => ['nullable', 'string', 'max:255'],
            'entries.*.notes' => ['nullable', 'string', 'max:2000'],
            'entries.*.entry_source' => ['sometimes', Rule::in(['manual', 'offline'])],
        ];
    }

    public function after(): array
    {
        return [
            function (Validator $validator): void {
                foreach ((array) $this->input('entries', []) as $index => $entry) {
                    $quantity = (float) ($entry['quantity_litres'] ?? 0);
                    $rejected = (float) ($entry['rejected_quantity_litres'] ?? 0);
                    if ($rejected > $quantity) {
                        $validator->errors()->add(
                            "entries.$index.rejected_quantity_litres",
                            'Rejected milk cannot exceed total milk.',
                        );
                    }
                    if ($rejected > 0 && trim((string) ($entry['rejection_reason'] ?? '')) === '') {
                        $validator->errors()->add(
                            "entries.$index.rejection_reason",
                            'A rejection reason is required when rejected milk is recorded.',
                        );
                    }
                }
            },
        ];
    }
}

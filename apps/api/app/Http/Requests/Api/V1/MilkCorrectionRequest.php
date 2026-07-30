<?php

namespace App\Http\Requests\Api\V1;

use App\Rules\UuidV7;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

class MilkCorrectionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id' => ['required', new UuidV7],
            'quantity_litres' => ['required', 'decimal:0,3', 'gt:0', 'max:99999.999'],
            'rejected_quantity_litres' => ['sometimes', 'decimal:0,3', 'gte:0', 'max:99999.999'],
            'rejection_reason' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string', 'max:2000'],
            'entry_source' => ['sometimes', Rule::in(['manual', 'offline'])],
            'correction_reason' => ['required', 'string', 'min:5', 'max:500'],
        ];
    }

    public function after(): array
    {
        return [
            function (Validator $validator): void {
                $quantity = (float) $this->input('quantity_litres', 0);
                $rejected = (float) $this->input('rejected_quantity_litres', 0);
                if ($rejected > $quantity) {
                    $validator->errors()->add(
                        'rejected_quantity_litres',
                        'Rejected milk cannot exceed total milk.',
                    );
                }
                if ($rejected > 0 && trim((string) $this->input('rejection_reason', '')) === '') {
                    $validator->errors()->add(
                        'rejection_reason',
                        'A rejection reason is required when rejected milk is recorded.',
                    );
                }
            },
        ];
    }
}

<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class DailyFeedIssueRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->attributes->get('membership')->can('inventory.manage');
    }

    public function rules(): array
    {
        return [
            'id' => ['nullable', 'uuid'],
            'shed_id' => ['nullable', 'uuid'],
            'animal_group_id' => ['nullable', 'uuid'],
            'date' => ['required', 'date', 'before_or_equal:today'],
            'inventory_item_id' => ['required', 'uuid'],
            'planned_quantity' => ['required', 'numeric', 'min:0'],
            'issued_quantity' => ['required', 'numeric', 'min:0'],
            'consumed_quantity' => ['required', 'numeric', 'min:0'],
            'wasted_quantity' => ['required', 'numeric', 'min:0'],
            'returned_quantity' => ['required', 'numeric', 'min:0'],
            'employee_id' => ['nullable', 'uuid'],
            'notes' => ['nullable', 'string'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator): void {
            $issued = (float) $this->input('issued_quantity', 0);
            $accounted = (float) $this->input('consumed_quantity', 0) + (float) $this->input('wasted_quantity', 0) + (float) $this->input('returned_quantity', 0);
            if (abs($issued - $accounted) > 0.0005) {
                $validator->errors()->add('issued_quantity', 'Issued quantity must equal consumed + wasted + returned quantity.');
            }
        });
    }
}

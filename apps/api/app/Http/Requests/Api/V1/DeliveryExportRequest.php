<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class DeliveryExportRequest extends FormRequest
{
    public function authorize(): bool { return true; }
    protected function prepareForValidation(): void
    {
        $this->merge(['from_date' => $this->query('from_date'), 'to_date' => $this->query('to_date'), 'status' => $this->query('status')]);
    }
    public function rules(): array
    {
        return ['from_date' => ['nullable', 'date_format:Y-m-d'], 'to_date' => ['nullable', 'date_format:Y-m-d', 'after_or_equal:from_date'], 'status' => ['nullable', Rule::in(['scheduled', 'dispatched', 'delivered', 'partially_delivered', 'failed', 'returned'])]];
    }
}

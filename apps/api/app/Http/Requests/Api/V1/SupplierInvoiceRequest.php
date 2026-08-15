<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class SupplierInvoiceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return ['purchase_order_id' => ['required', 'uuid'], 'supplier_invoice_number' => ['required', 'string', 'max:100'], 'invoice_date' => ['required', 'date'], 'due_date' => ['required', 'date', 'after_or_equal:invoice_date'], 'notes' => ['nullable', 'string', 'max:4000']];
    }
}

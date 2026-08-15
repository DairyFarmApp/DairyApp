<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CustomerPaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return ['payment_date' => ['required', 'date'], 'amount' => ['required', 'numeric', 'gt:0'], 'payment_method' => ['required', Rule::in(['cash', 'bank_transfer', 'cheque', 'mobile_wallet', 'other'])], 'reference' => ['nullable', 'string', 'max:160'], 'notes' => ['nullable', 'string', 'max:4000']];
    }
}

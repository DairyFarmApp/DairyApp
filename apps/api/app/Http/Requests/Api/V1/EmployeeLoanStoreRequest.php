<?php

namespace App\Http\Requests\Api\V1;

use App\Rules\UuidV7;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class EmployeeLoanStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'reason' => trim((string) $this->input('reason')),
            'notes' => $this->filled('notes') ? trim((string) $this->input('notes')) : null,
        ]);
    }

    public function rules(): array
    {
        return [
            'id' => ['sometimes', new UuidV7],
            'employee_id' => ['required', 'uuid'],
            'disbursement_date' => ['required', 'date_format:Y-m-d', 'before_or_equal:today'],
            'principal_amount' => ['required', 'decimal:0,2', 'gt:0', 'max:999999999999.99'],
            'monthly_installment' => [
                'required', 'decimal:0,2', 'gt:0', 'lte:principal_amount',
                'max:999999999999.99',
            ],
            'first_recovery_month' => ['required', 'date_format:Y-m'],
            'reason' => ['required', 'string', 'max:500'],
            'notes' => ['nullable', 'string', 'max:5000'],
        ];
    }

    public function after(): array
    {
        return [
            function (Validator $validator): void {
                $disbursementValue = (string) $this->input('disbursement_date');
                $recoveryValue = (string) $this->input('first_recovery_month');
                if (
                    ! preg_match('/^\d{4}-\d{2}-\d{2}$/', $disbursementValue)
                    || ! preg_match('/^\d{4}-\d{2}$/', $recoveryValue)
                ) {
                    return;
                }
                try {
                    $disbursement = CarbonImmutable::createFromFormat(
                        'Y-m-d',
                        $disbursementValue,
                    );
                    $recovery = CarbonImmutable::createFromFormat(
                        'Y-m-d',
                        $recoveryValue.'-01',
                    );
                } catch (\Throwable) {
                    return;
                }
                if ($disbursement && $recovery && $recovery->isBefore($disbursement->startOfMonth())) {
                    $validator->errors()->add(
                        'first_recovery_month',
                        'Loan recovery cannot begin before disbursement.',
                    );
                }
            },
        ];
    }
}

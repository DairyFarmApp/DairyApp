<?php

namespace App\Domain\Workforce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class EmployeeLoan extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'employee_id',
        'loan_number',
        'disbursement_date',
        'principal_amount',
        'monthly_installment',
        'recovered_amount',
        'outstanding_amount',
        'first_recovery_month',
        'reason',
        'notes',
        'status',
        'journal_entry_id',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'disbursement_date' => 'date:Y-m-d',
            'first_recovery_month' => 'date:Y-m-d',
            'principal_amount' => 'decimal:2',
            'monthly_installment' => 'decimal:2',
            'recovered_amount' => 'decimal:2',
            'outstanding_amount' => 'decimal:2',
        ];
    }

    public function employee(): BelongsTo
    {
        return $this->belongsTo(Employee::class);
    }

    public function installments(): HasMany
    {
        return $this->hasMany(EmployeeLoanInstallment::class);
    }
}

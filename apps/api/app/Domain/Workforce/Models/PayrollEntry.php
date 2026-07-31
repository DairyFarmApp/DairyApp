<?php

namespace App\Domain\Workforce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PayrollEntry extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'payroll_period_id',
        'employee_id',
        'basic_salary',
        'loan_deduction',
        'bonus',
        'other_deduction',
        'net_salary',
    ];

    protected function casts(): array
    {
        return [
            'basic_salary' => 'decimal:2',
            'loan_deduction' => 'decimal:2',
            'bonus' => 'decimal:2',
            'other_deduction' => 'decimal:2',
            'net_salary' => 'decimal:2',
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

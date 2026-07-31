<?php

namespace App\Domain\Workforce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class EmployeeLoanInstallment extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'employee_loan_id',
        'payroll_entry_id',
        'amount',
        'recovered_on',
    ];

    protected function casts(): array
    {
        return ['amount' => 'decimal:2', 'recovered_on' => 'date:Y-m-d'];
    }
}

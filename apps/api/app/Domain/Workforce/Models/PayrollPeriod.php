<?php

namespace App\Domain\Workforce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PayrollPeriod extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'period_month',
        'status',
        'total_basic_salary',
        'total_loan_deduction',
        'total_net_salary',
        'generated_by',
        'approved_by',
        'paid_by',
        'approved_at',
        'paid_at',
        'journal_entry_id',
    ];

    protected function casts(): array
    {
        return [
            'period_month' => 'date:Y-m-d',
            'total_basic_salary' => 'decimal:2',
            'total_loan_deduction' => 'decimal:2',
            'total_net_salary' => 'decimal:2',
            'approved_at' => 'datetime',
            'paid_at' => 'datetime',
        ];
    }

    public function entries(): HasMany
    {
        return $this->hasMany(PayrollEntry::class);
    }
}

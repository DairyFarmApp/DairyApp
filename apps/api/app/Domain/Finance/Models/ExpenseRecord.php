<?php

namespace App\Domain\Finance\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class ExpenseRecord extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'expense_number',
        'recorded_on',
        'category',
        'payee',
        'amount',
        'reference',
        'description',
        'journal_entry_id',
        'created_by',
    ];

    protected function casts(): array
    {
        return ['recorded_on' => 'date:Y-m-d', 'amount' => 'decimal:2'];
    }
}

<?php

namespace App\Domain\Finance\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class IncomeRecord extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'income_number',
        'recorded_on',
        'category',
        'payer',
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

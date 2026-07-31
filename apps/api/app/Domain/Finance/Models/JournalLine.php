<?php

namespace App\Domain\Finance\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class JournalLine extends Model
{
    use UsesUuidV7;

    protected $table = 'finance_journal_lines';

    protected $fillable = [
        'organization_id',
        'farm_id',
        'journal_entry_id',
        'system_account_id',
        'debit',
        'credit',
        'memo',
    ];

    protected function casts(): array
    {
        return ['debit' => 'decimal:2', 'credit' => 'decimal:2'];
    }

    public function account(): BelongsTo
    {
        return $this->belongsTo(SystemAccount::class, 'system_account_id');
    }
}

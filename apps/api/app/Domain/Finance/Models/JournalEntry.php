<?php

namespace App\Domain\Finance\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class JournalEntry extends Model
{
    use UsesUuidV7;

    protected $table = 'finance_journal_entries';

    protected $fillable = [
        'organization_id',
        'farm_id',
        'entry_number',
        'occurred_on',
        'source_type',
        'source_id',
        'description',
        'status',
        'reversal_of_id',
        'posted_by',
    ];

    protected function casts(): array
    {
        return ['occurred_on' => 'date:Y-m-d'];
    }

    public function lines(): HasMany
    {
        return $this->hasMany(JournalLine::class);
    }
}

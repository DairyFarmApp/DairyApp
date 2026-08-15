<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class CommercialLedgerEntry extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'party_type', 'party_id', 'occurred_at', 'entry_type', 'debit', 'credit', 'balance_after', 'reference_type', 'reference_id', 'description', 'created_by'];

    protected function casts(): array
    {
        return ['occurred_at' => 'datetime', 'debit' => 'decimal:2', 'credit' => 'decimal:2', 'balance_after' => 'decimal:2'];
    }
}

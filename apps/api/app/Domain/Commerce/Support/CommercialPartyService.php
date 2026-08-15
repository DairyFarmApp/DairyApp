<?php

namespace App\Domain\Commerce\Support;

use App\Domain\Commerce\Models\CommercialLedgerEntry;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class CommercialPartyService
{
    public function nextCode(string $model, string $organizationId, string $prefix): string
    {
        return DB::transaction(function () use ($model, $organizationId, $prefix): string {
            $latest = $model::withTrashed()->where('organization_id', $organizationId)->lockForUpdate()->orderByDesc('code')->value('code');
            $sequence = $latest && preg_match('/(\d+)$/', $latest, $matches) ? ((int) $matches[1]) + 1 : 1;

            return sprintf('%s-%05d', $prefix, $sequence);
        });
    }

    public function openingLedger(Model $party, string $partyType, ?string $actorId): void
    {
        $amount = (float) $party->opening_balance;
        if ($amount <= 0) {
            return;
        }
        CommercialLedgerEntry::create([
            'organization_id' => $party->organization_id, 'farm_id' => $party->farm_id,
            'party_type' => $partyType, 'party_id' => $party->id, 'occurred_at' => now(),
            'entry_type' => 'opening_balance',
            'debit' => $partyType === 'customer' ? $amount : 0,
            'credit' => $partyType === 'supplier' ? $amount : 0,
            'balance_after' => $amount, 'reference_type' => $partyType,
            'reference_id' => $party->id, 'description' => 'Opening balance', 'created_by' => $actorId,
        ]);
    }
}

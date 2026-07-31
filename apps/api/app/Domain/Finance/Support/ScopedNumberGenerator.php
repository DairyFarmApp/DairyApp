<?php

namespace App\Domain\Finance\Support;

use Illuminate\Support\Facades\DB;

final class ScopedNumberGenerator
{
    public function next(string $organizationId, string $sequenceKey, string $prefix): string
    {
        DB::table('organization_sequences')->insertOrIgnore([
            'organization_id' => $organizationId,
            'sequence_key' => $sequenceKey,
            'next_value' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $sequence = DB::table('organization_sequences')
            ->where('organization_id', $organizationId)
            ->where('sequence_key', $sequenceKey)
            ->lockForUpdate()
            ->first();

        if (! $sequence) {
            throw new \RuntimeException('The requested number sequence could not be acquired.');
        }

        DB::table('organization_sequences')
            ->where('organization_id', $organizationId)
            ->where('sequence_key', $sequenceKey)
            ->update([
                'next_value' => $sequence->next_value + 1,
                'updated_at' => now(),
            ]);

        return $prefix.str_pad((string) $sequence->next_value, 6, '0', STR_PAD_LEFT);
    }
}

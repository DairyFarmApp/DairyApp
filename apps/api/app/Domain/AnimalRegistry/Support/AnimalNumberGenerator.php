<?php

namespace App\Domain\AnimalRegistry\Support;

use Illuminate\Support\Facades\DB;

final class AnimalNumberGenerator
{
    public function next(string $organizationId): string
    {
        DB::table('organization_sequences')->insertOrIgnore([
            'organization_id' => $organizationId,
            'sequence_key' => 'animal_number',
            'next_value' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $sequence = DB::table('organization_sequences')
            ->where('organization_id', $organizationId)
            ->where('sequence_key', 'animal_number')
            ->lockForUpdate()
            ->first();
        if (! $sequence) {
            throw new \RuntimeException('Animal number sequence could not be acquired.');
        }

        DB::table('organization_sequences')
            ->where('organization_id', $organizationId)
            ->where('sequence_key', 'animal_number')
            ->update(['next_value' => $sequence->next_value + 1, 'updated_at' => now()]);

        return 'AN-'.str_pad((string) $sequence->next_value, 6, '0', STR_PAD_LEFT);
    }
}

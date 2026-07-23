<?php

namespace Tests\Feature;

use App\Models\Setting;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class FoundationSchemaTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_foundation_constraints_indexes_uuid_and_json_are_usable(): void
    {
        $data = $this->foundation();

        $this->assertTrue(Schema::hasColumns('api_sessions', ['access_token_hash', 'renewal_token_hash', 'renewal_reuse_detected_at']));
        $this->assertTrue(Schema::hasTable('api_session_renewal_tokens'));
        $this->assertContains('farms_organization_id_code_unique', Schema::getIndexListing('farms'));
        $this->assertContains('idempotency_records_scope_key_unique', Schema::getIndexListing('idempotency_records'));
        $this->assertNotEmpty(Schema::getForeignKeys('sheds'));
        $this->assertSame(36, strlen($data['farm']->id));

        $setting = Setting::create([
            'organization_id' => $data['organization']->id,
            'farm_id' => $data['farm']->id,
            'key' => 'foundation.validation',
            'type' => 'json',
            'value' => ['enabled' => true, 'limit' => 5],
        ]);
        $this->assertEquals(['enabled' => true, 'limit' => 5], $setting->fresh()->value);

        Setting::create([
            'organization_id' => $data['organization']->id,
            'farm_id' => null,
            'key' => 'organization.validation',
            'type' => 'json',
            'value' => ['enabled' => true],
        ]);

        foreach ([
            fn () => Setting::create([
                'organization_id' => $data['organization']->id,
                'farm_id' => null,
                'key' => 'organization.validation',
                'type' => 'json',
                'value' => ['enabled' => false],
            ]),
            fn () => DB::table('farms')->insert([
                'id' => '018f0000-0000-7000-8000-000000000099',
                'organization_id' => $data['organization']->id,
                'name' => 'Duplicate Code',
                'code' => $data['farm']->code,
                'timezone' => 'UTC',
                'version' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]),
        ] as $operation) {
            try {
                $operation();
                $this->fail('A duplicate foundation scope unexpectedly succeeded.');
            } catch (QueryException) {
                $this->assertTrue(true);
            }
        }
    }
}

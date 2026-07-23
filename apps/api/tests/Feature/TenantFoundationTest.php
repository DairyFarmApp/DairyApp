<?php

namespace Tests\Feature;

use App\Models\Farm;
use App\Models\Organization;
use App\Models\OrganizationMembership;
use App\Models\Permission;
use App\Models\Role;
use App\Models\Shed;
use App\Support\AuditService;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Ramsey\Uuid\Uuid;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class TenantFoundationTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    private array $permissions = ['organizations.view', 'organizations.update', 'farms.view', 'farms.create', 'farms.update', 'farms.archive', 'sheds.view', 'sheds.create', 'sheds.update', 'sheds.archive'];

    public function test_organization_and_farm_isolation_hide_foreign_records(): void
    {
        $this->foundation($this->permissions);
        $foreignOrg = Organization::create(['name' => 'Foreign Dairy']);
        $foreignFarm = Farm::create(['organization_id' => $foreignOrg->id, 'name' => 'Foreign Farm', 'code' => 'FOREIGN', 'timezone' => 'UTC']);
        $foreignShed = Shed::create(['organization_id' => $foreignOrg->id, 'farm_id' => $foreignFarm->id, 'name' => 'Foreign Shed', 'code' => 'FOREIGN']);
        $token = $this->loginToken();
        $this->getJson('/api/v1/organizations/'.$foreignOrg->id, $this->bearer($token))->assertNotFound();
        $this->getJson('/api/v1/farms/'.$foreignFarm->id, $this->bearer($token))->assertNotFound();
        $this->getJson('/api/v1/sheds/'.$foreignShed->id, $this->bearer($token))->assertNotFound();
        $this->patchJson('/api/v1/sheds/'.$foreignShed->id, ['name' => 'Spoofed'], $this->bearer($token))->assertNotFound();
    }

    public function test_restricted_membership_cannot_access_unassigned_farm(): void
    {
        $data = $this->foundation($this->permissions, false);
        $other = Farm::create(['organization_id' => $data['organization']->id, 'name' => 'South Farm', 'code' => 'SOUTH', 'timezone' => 'UTC']);
        $token = $this->loginToken();
        $this->getJson('/api/v1/farms/'.$other->id, $this->bearer($token))->assertNotFound();
        $this->postJson('/api/v1/auth/switch-farm', ['farm_id' => $other->id], $this->bearer($token))->assertForbidden();
    }

    public function test_permission_checks_block_unauthorized_create(): void
    {
        $this->foundation(['organizations.view', 'farms.view']);
        $token = $this->loginToken();
        $this->postJson('/api/v1/farms', ['name' => 'Blocked Farm', 'timezone' => 'UTC'], $this->bearer($token))->assertForbidden();
    }

    public function test_organization_and_farm_switching_verify_membership_and_access(): void
    {
        $data = $this->foundation($this->permissions, false);
        $secondOrg = Organization::create(['name' => 'Second Dairy']);
        $secondMembership = OrganizationMembership::create(['organization_id' => $secondOrg->id, 'user_id' => $data['user']->id, 'status' => 'active', 'all_farms' => true]);
        $role = Role::create(['organization_id' => $secondOrg->id, 'name' => 'Viewer', 'slug' => 'viewer']);
        $permission = Permission::firstOrCreate(['name' => 'organizations.view']);
        $role->permissions()->attach($permission);
        $secondMembership->roles()->attach($role, ['organization_id' => $secondOrg->id]);
        $login = $this->postJson('/api/v1/auth/login', ['email' => $data['user']->email, 'password' => 'Correct-Horse-2026'])->assertOk();
        $token = $login->json('data.access_token');
        $switched = $this->postJson('/api/v1/auth/switch-organization', ['organization_id' => $data['organization']->id], $this->bearer($token))->assertOk();
        $newToken = $switched->json('data.access_token');
        $this->postJson('/api/v1/auth/switch-farm', ['farm_id' => $data['farm']->id], $this->bearer($newToken))->assertOk()->assertJsonPath('data.active_farm_id', $data['farm']->id);
    }

    public function test_context_headers_cannot_spoof_server_side_session_authority(): void
    {
        $data = $this->foundation($this->permissions);
        $foreignOrg = Organization::create(['name' => 'Foreign Dairy']);
        $foreignFarm = Farm::create(['organization_id' => $foreignOrg->id, 'name' => 'Foreign Farm', 'code' => 'FOREIGN', 'timezone' => 'UTC']);
        $token = $this->loginToken();
        $headers = $this->bearer($token) + ['X-Organization-ID' => $foreignOrg->id, 'X-Farm-ID' => $foreignFarm->id];
        $response = $this->getJson('/api/v1/farms', $headers)->assertOk();
        $this->assertSame([$data['farm']->id], collect($response->json('data'))->pluck('id')->all());
        $this->getJson('/api/v1/farms/'.$foreignFarm->id, $headers)->assertNotFound();
    }

    public function test_switching_to_an_organization_without_membership_is_forbidden(): void
    {
        $this->foundation($this->permissions);
        $foreignOrg = Organization::create(['name' => 'Foreign Dairy']);
        $token = $this->loginToken();
        $this->postJson('/api/v1/auth/switch-organization', ['organization_id' => $foreignOrg->id], $this->bearer($token))->assertForbidden();
    }

    public function test_inactive_or_revoked_membership_invalidates_tenant_access(): void
    {
        $data = $this->foundation($this->permissions);
        $token = $this->loginToken($data['user']->email);
        $data['membership']->update(['status' => 'inactive']);
        $this->getJson('/api/v1/farms', $this->bearer($token))->assertForbidden()->assertJsonPath('error.code', 'ORGANIZATION_ACCESS_DENIED');
        $data['membership']->update(['status' => 'revoked']);
        $this->getJson('/api/v1/farms', $this->bearer($token))->assertForbidden()->assertJsonPath('error.code', 'ORGANIZATION_ACCESS_DENIED');
    }

    public function test_farm_and_shed_crud_are_tenant_scoped_audited_and_uuid7(): void
    {
        $this->foundation($this->permissions);
        $token = $this->loginToken();
        $headers = $this->bearer($token);
        $farm = $this->postJson('/api/v1/farms', ['name' => 'Riverside Farm', 'code' => 'RIVER', 'timezone' => 'Asia/Karachi'], $headers + ['Idempotency-Key' => 'farm-create-1'])->assertCreated()->json('data');
        $this->assertSame(7, Uuid::fromString($farm['id'])->getVersion());
        $this->patchJson('/api/v1/farms/'.$farm['id'], ['name' => 'Riverside Dairy Farm'], $headers)->assertOk();
        $shed = $this->postJson('/api/v1/farms/'.$farm['id'].'/sheds', ['name' => 'Main Shed', 'code' => 'MAIN'], $headers + ['Idempotency-Key' => 'shed-create-1'])->assertCreated()->json('data');
        $this->patchJson('/api/v1/sheds/'.$shed['id'], ['name' => 'Milking Shed'], $headers)->assertOk();
        $this->deleteJson('/api/v1/sheds/'.$shed['id'], [], $headers)->assertOk();
        $this->deleteJson('/api/v1/farms/'.$farm['id'], [], $headers)->assertOk();
        $this->assertDatabaseHas('audit_logs', ['action' => 'farm.created', 'entity_id' => $farm['id']]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'shed.archived', 'entity_id' => $shed['id']]);
    }

    public function test_idempotency_replays_committed_result_and_rejects_conflicting_payload(): void
    {
        $this->foundation($this->permissions);
        $token = $this->loginToken();
        $headers = $this->bearer($token) + ['Idempotency-Key' => 'same-key'];
        $first = $this->postJson('/api/v1/farms', ['name' => 'Idempotent Farm', 'code' => 'IDEM', 'timezone' => 'UTC'], $headers)->assertCreated();
        $second = $this->postJson('/api/v1/farms', ['name' => 'Idempotent Farm', 'code' => 'IDEM', 'timezone' => 'UTC'], $headers)->assertCreated();
        $this->assertSame($first->json('data.id'), $second->json('data.id'));
        $this->assertDatabaseCount('farms', 2);
        $this->postJson('/api/v1/farms', ['name' => 'Different Farm', 'code' => 'DIFF', 'timezone' => 'UTC'], $headers)->assertConflict()->assertJsonPath('error.code', 'IDEMPOTENCY_KEY_REUSED');
    }

    public function test_idempotency_fingerprint_is_independent_of_json_object_key_order(): void
    {
        $this->foundation($this->permissions);
        $token = $this->loginToken();
        $headers = $this->bearer($token) + ['Idempotency-Key' => 'canonical-key'];
        $first = $this->postJson('/api/v1/farms', ['name' => 'Canonical Farm', 'code' => 'CANON', 'timezone' => 'UTC'], $headers)->assertCreated();
        $second = $this->postJson('/api/v1/farms', ['timezone' => 'UTC', 'code' => 'CANON', 'name' => 'Canonical Farm'], $headers)->assertCreated();
        $this->assertSame($first->json('data.id'), $second->json('data.id'));
    }

    public function test_audit_redaction_removes_authentication_secrets(): void
    {
        $service = app(AuditService::class);
        $redacted = $service->redact(['password' => 'secret', 'password_confirmation' => 'secret', 'Authorization' => 'Bearer raw', 'nested' => ['access_token_hash' => 'hash', 'api-key' => 'raw', 'safe' => 'visible']]);
        $this->assertSame('[REDACTED]', $redacted['password']);
        $this->assertSame('[REDACTED]', $redacted['password_confirmation']);
        $this->assertSame('[REDACTED]', $redacted['Authorization']);
        $this->assertSame('[REDACTED]', $redacted['nested']['access_token_hash']);
        $this->assertSame('[REDACTED]', $redacted['nested']['api-key']);
        $this->assertSame('visible', $redacted['nested']['safe']);
    }

    public function test_sync_bootstrap_returns_only_authorized_reference_data(): void
    {
        $data = $this->foundation($this->permissions, false);
        $token = $this->loginToken();
        Farm::create(['organization_id' => $data['organization']->id, 'name' => 'Hidden Farm', 'code' => 'HIDDEN', 'timezone' => 'UTC']);
        $response = $this->getJson('/api/v1/sync/bootstrap', $this->bearer($token))->assertOk();
        $this->assertCount(1, $response->json('data.farms'));
        $this->assertNotEmpty($response->json('data.next_cursor'));
        $this->assertSame([$data['farm']->id], $response->json('data.authorized_farm_ids'));
    }

    public function test_sync_cursor_overlap_returns_archive_tombstones(): void
    {
        Carbon::setTestNow('2026-07-22 12:00:00');
        $data = $this->foundation($this->permissions);
        $token = $this->loginToken();
        $bootstrap = $this->getJson('/api/v1/sync/bootstrap', $this->bearer($token))->assertOk();
        $data['shed']->delete();
        $response = $this->getJson('/api/v1/sync/changes?cursor='.urlencode($bootstrap->json('data.next_cursor')), $this->bearer($token))->assertOk();
        $tombstone = collect($response->json('data.sheds'))->firstWhere('id', $data['shed']->id);
        $this->assertTrue($tombstone['is_deleted']);
        Carbon::setTestNow();
    }

    public function test_invalid_sync_cursor_is_rejected(): void
    {
        $this->foundation($this->permissions);
        $token = $this->loginToken();
        $this->getJson('/api/v1/sync/changes?cursor=not-a-cursor', $this->bearer($token))->assertBadRequest()->assertJsonPath('error.code', 'INVALID_CURSOR');
    }

    public function test_database_rejects_cross_tenant_rows_and_duplicate_assignments(): void
    {
        $data = $this->foundation($this->permissions, false);
        $foreignOrg = Organization::create(['name' => 'Foreign Dairy']);
        $foreignFarm = Farm::create(['organization_id' => $foreignOrg->id, 'name' => 'Foreign Farm', 'code' => 'FOREIGN', 'timezone' => 'UTC']);
        $foreignRole = Role::create(['organization_id' => $foreignOrg->id, 'name' => 'Foreign Role', 'slug' => 'foreign-role']);

        foreach ([
            ['sheds', [
                'id' => (string) Str::uuid7(),
                'organization_id' => $data['organization']->id,
                'farm_id' => $foreignFarm->id,
                'name' => 'Invalid Shed',
                'code' => 'INVALID',
                'version' => 1,
            ]],
            ['user_farm_access', ['organization_id' => $data['organization']->id, 'organization_membership_id' => $data['membership']->id, 'farm_id' => $foreignFarm->id]],
            ['membership_role', ['organization_id' => $data['organization']->id, 'organization_membership_id' => $data['membership']->id, 'role_id' => $foreignRole->id]],
            ['settings', [
                'id' => (string) Str::uuid7(),
                'organization_id' => $data['organization']->id,
                'farm_id' => $foreignFarm->id,
                'key' => 'invalid.cross-tenant',
                'type' => 'json',
                'value' => json_encode(['enabled' => true], JSON_THROW_ON_ERROR),
                'scope_key' => hash('sha256', 'invalid-cross-tenant-setting'),
            ]],
            ['api_sessions', [
                'id' => (string) Str::uuid7(),
                'user_id' => $data['user']->id,
                'organization_id' => $foreignOrg->id,
                'access_token_hash' => hash('sha256', 'invalid-access'),
                'renewal_token_hash' => hash('sha256', 'invalid-renewal'),
                'access_expires_at' => now()->addMinutes(15),
                'renewal_expires_at' => now()->addMonth(),
            ]],
        ] as [$table, $values]) {
            try {
                DB::table($table)->insert($values);
                $this->fail("Invalid tenant insert into {$table} unexpectedly succeeded.");
            } catch (QueryException) {
                $this->assertTrue(true);
            }
        }

        $permissionId = $data['role']->permissions()->value('permissions.id');
        foreach ([
            ['membership_role', [
                'organization_id' => $data['organization']->id,
                'organization_membership_id' => $data['membership']->id,
                'role_id' => $data['role']->id,
            ]],
            ['permission_role', [
                'role_id' => $data['role']->id,
                'permission_id' => $permissionId,
            ]],
        ] as [$table, $values]) {
            try {
                DB::table($table)->insert($values);
                $this->fail("Duplicate assignment in {$table} unexpectedly succeeded.");
            } catch (QueryException) {
                $this->assertTrue(true);
            }
        }

        $idempotency = [
            'id' => (string) Str::uuid7(),
            'organization_id' => $data['organization']->id,
            'user_id' => $data['user']->id,
            'scope_key' => hash('sha256', 'duplicate-scope'),
            'endpoint' => 'api/v1/farms',
            'method' => 'POST',
            'idempotency_key' => 'duplicate',
            'request_fingerprint' => hash('sha256', 'payload'),
            'status' => 'processing',
        ];
        DB::table('idempotency_records')->insert($idempotency);
        try {
            DB::table('idempotency_records')->insert([
                ...$idempotency,
                'id' => (string) Str::uuid7(),
            ]);
            $this->fail('Duplicate idempotency scope unexpectedly succeeded.');
        } catch (QueryException) {
            $this->assertTrue(true);
        }
    }
}

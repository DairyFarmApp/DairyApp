<?php

namespace Tests\Feature;

use App\Models\ApiSession;
use App\Models\ApiSessionRenewalToken;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class AuthenticationTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_login_issues_opaque_tokens_and_stores_only_hashes(): void
    {
        $this->foundation();
        $response = $this->postJson('/api/v1/auth/login', ['email' => 'owner@example.test', 'password' => 'Correct-Horse-2026', 'device_id' => '018f0000-0000-7000-8000-000000000099'])->assertOk();
        $access = $response->json('data.access_token');
        $renewal = $response->json('data.renewal_credential');
        $session = ApiSession::firstOrFail();
        $this->assertNotSame($access, $session->access_token_hash);
        $this->assertNotSame($renewal, $session->renewal_token_hash);
        $this->assertSame(hash('sha256', explode('.', $access, 2)[1]), $session->access_token_hash);
        $this->assertSame(hash('sha256', explode('.', $renewal, 2)[1]), $session->renewal_token_hash);
        $this->assertDatabaseHas('api_session_renewal_tokens', ['api_session_id' => $session->id, 'token_hash' => $session->renewal_token_hash]);
        $this->assertDatabaseMissing('api_sessions', ['access_token_hash' => $access]);
        $this->assertDatabaseMissing('api_session_renewal_tokens', ['token_hash' => $renewal]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'auth.login_succeeded']);
    }

    public function test_login_failure_is_generic_tracked_and_rate_limited(): void
    {
        $data = $this->foundation();
        $this->postJson('/api/v1/auth/login', ['email' => $data['user']->email, 'password' => 'wrong'])->assertUnauthorized()->assertJsonPath('error.code', 'INVALID_CREDENTIALS');
        $this->postJson('/api/v1/auth/login', ['email' => 'missing@example.test', 'password' => 'wrong'])->assertUnauthorized()->assertJsonPath('error.code', 'INVALID_CREDENTIALS');
        $this->assertSame(1, $data['user']->fresh()->failed_login_count);
        $this->assertDatabaseCount('audit_logs', 2);
        for ($attempt = 0; $attempt < 10; $attempt++) {
            $last = $this->postJson('/api/v1/auth/login', ['email' => $data['user']->email, 'password' => 'wrong']);
        }
        $last->assertStatus(429);
    }

    public function test_renewal_reuse_revokes_the_session_family_and_creates_a_security_event(): void
    {
        $this->foundation();
        $login = $this->postJson('/api/v1/auth/login', ['email' => 'owner@example.test', 'password' => 'Correct-Horse-2026'])->assertOk();
        $oldRenewal = $login->json('data.renewal_credential');
        $renewed = $this->postJson('/api/v1/auth/renew', ['renewal_credential' => $oldRenewal])->assertOk();
        $this->assertNotSame($login->json('data.access_token'), $renewed->json('data.access_token'));
        $this->assertNotSame($oldRenewal, $renewed->json('data.renewal_credential'));
        $this->assertSame(2, ApiSessionRenewalToken::count());
        $this->postJson('/api/v1/auth/renew', ['renewal_credential' => $oldRenewal])->assertUnauthorized()->assertJsonPath('error.code', 'INVALID_RENEWAL_CREDENTIAL');
        $this->assertNotNull(ApiSession::firstOrFail()->renewal_reuse_detected_at);
        $this->assertDatabaseHas('audit_logs', ['action' => 'auth.renewal_reuse_detected']);
        $this->getJson('/api/v1/auth/me', $this->bearer($renewed->json('data.access_token')))->assertUnauthorized();
        $this->postJson('/api/v1/auth/renew', ['renewal_credential' => $renewed->json('data.renewal_credential')])->assertUnauthorized();
    }

    public function test_current_user_logout_and_session_revocation_work(): void
    {
        $this->foundation();
        $token = $this->loginToken();
        $this->getJson('/api/v1/auth/me', $this->bearer($token))->assertOk()->assertJsonPath('data.user.email', 'owner@example.test');
        $this->postJson('/api/v1/auth/logout', [], $this->bearer($token))->assertOk();
        $this->getJson('/api/v1/auth/me', $this->bearer($token))->assertUnauthorized();
    }

    public function test_disabling_user_revokes_all_sessions(): void
    {
        $data = $this->foundation();
        $this->loginToken();
        $this->loginToken();
        $data['user']->update(['is_active' => false]);
        $this->assertSame(0, ApiSession::whereNull('revoked_at')->count());
    }

    public function test_renewal_is_rejected_after_logout_and_for_a_disabled_user(): void
    {
        $data = $this->foundation();
        $login = $this->postJson('/api/v1/auth/login', ['email' => $data['user']->email, 'password' => 'Correct-Horse-2026'])->assertOk();
        $this->postJson('/api/v1/auth/logout', [], $this->bearer($login->json('data.access_token')))->assertOk();
        $this->postJson('/api/v1/auth/renew', ['renewal_credential' => $login->json('data.renewal_credential')])->assertUnauthorized();

        $second = $this->postJson('/api/v1/auth/login', ['email' => $data['user']->email, 'password' => 'Correct-Horse-2026'])->assertOk();
        $data['user']->update(['is_active' => false]);
        $this->postJson('/api/v1/auth/renew', ['renewal_credential' => $second->json('data.renewal_credential')])->assertUnauthorized();
    }

    public function test_password_change_revokes_all_existing_sessions(): void
    {
        $data = $this->foundation();
        $first = $this->loginToken();
        $second = $this->loginToken();
        $data['user']->update(['password' => Hash::make('Replacement-Horse-2026')]);
        $this->getJson('/api/v1/auth/me', $this->bearer($first))->assertUnauthorized();
        $this->getJson('/api/v1/auth/me', $this->bearer($second))->assertUnauthorized();
    }

    public function test_server_side_access_and_renewal_expiry_are_enforced(): void
    {
        $this->foundation();
        $login = $this->postJson('/api/v1/auth/login', ['email' => 'owner@example.test', 'password' => 'Correct-Horse-2026'])->assertOk();
        $session = ApiSession::firstOrFail();
        $session->forceFill(['access_expires_at' => now()->subSecond()])->save();
        $this->getJson('/api/v1/auth/me', $this->bearer($login->json('data.access_token')))->assertUnauthorized();
        $session->forceFill(['renewal_expires_at' => now()->subSecond()])->save();
        $this->postJson('/api/v1/auth/renew', ['renewal_credential' => $login->json('data.renewal_credential')])->assertUnauthorized();
    }

    public function test_locked_account_cannot_be_kept_locked_by_requests_during_the_lock(): void
    {
        Carbon::setTestNow('2026-07-22 12:00:00');
        $data = $this->foundation();
        for ($attempt = 0; $attempt < 5; $attempt++) {
            $this->postJson('/api/v1/auth/login', ['email' => $data['user']->email, 'password' => 'wrong'])->assertUnauthorized();
        }
        $lockedUntil = $data['user']->fresh()->locked_until;
        $this->assertNotNull($lockedUntil);

        Carbon::setTestNow(now()->addMinute());
        $this->postJson('/api/v1/auth/login', ['email' => $data['user']->email, 'password' => 'wrong'])->assertUnauthorized();
        $this->assertTrue($data['user']->fresh()->locked_until->equalTo($lockedUntil));

        Carbon::setTestNow($lockedUntil->copy()->addSecond());
        $this->postJson('/api/v1/auth/login', ['email' => $data['user']->email, 'password' => 'Correct-Horse-2026'])->assertOk();
        $this->assertSame(0, $data['user']->fresh()->failed_login_count);
        $this->assertNull($data['user']->fresh()->locked_until);
        Carbon::setTestNow();
    }

    public function test_user_can_list_and_revoke_another_own_session(): void
    {
        $this->foundation();
        $first = $this->loginToken();
        $second = $this->loginToken();
        $sessions = $this->getJson('/api/v1/auth/sessions', $this->bearer($first))->assertOk();
        $target = collect($sessions->json('data'))->firstWhere('is_current', false)['id'];
        $this->deleteJson('/api/v1/auth/sessions/'.$target, [], $this->bearer($first))->assertOk();
        $this->getJson('/api/v1/auth/me', $this->bearer($second))->assertUnauthorized();
    }
}

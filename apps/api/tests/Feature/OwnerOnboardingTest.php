<?php

namespace Tests\Feature;

use App\Models\ApiSession;
use App\Models\FarmInviteLink;
use App\Models\OrganizationMembership;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class OwnerOnboardingTest extends TestCase
{
    use RefreshDatabase;

    public function test_primary_owner_signup_creates_one_named_farm_and_authenticated_context(): void
    {
        $response = $this->ownerSignup()->assertCreated();

        $organizationId = $response->json('data.active_organization_id');
        $farmId = $response->json('data.active_farm_id');
        $this->assertSame('owner@sunrise.test', $response->json('data.user.email'));
        $this->assertSame('+92 300 1234567', $response->json('data.user.phone_number'));
        $this->assertSame('Sunrise Dairy Farm', $response->json('data.organizations.0.name'));
        $this->assertSame('Sunrise Dairy Farm', $response->json('data.farms.0.name'));
        $this->assertNotEmpty($response->json('data.access_token'));
        $this->assertDatabaseCount('organizations', 1);
        $this->assertDatabaseCount('farms', 1);
        $this->assertDatabaseHas('organization_memberships', [
            'organization_id' => $organizationId,
            'user_id' => $response->json('data.user.id'),
            'membership_type' => 'primary_owner',
            'status' => 'active',
            'all_farms' => true,
        ]);
        $this->assertDatabaseHas('farms', [
            'id' => $farmId,
            'organization_id' => $organizationId,
            'name' => 'Sunrise Dairy Farm',
        ]);
        $this->assertContains('users.manage', $response->json('data.permissions'));
        $this->assertNotContains('farms.create', $response->json('data.permissions'));
        $this->postJson('/api/v1/farms', [
            'name' => 'Second Farm',
            'timezone' => 'Asia/Karachi',
        ], $this->bearer($response->json('data.access_token')))
            ->assertForbidden();
        $this->assertDatabaseHas('audit_logs', [
            'organization_id' => $organizationId,
            'action' => 'auth.primary_owner_registered',
        ]);
        $this->postJson('/api/v1/auth/login', [
            'email' => 'owner@sunrise.test',
            'password' => 'Owner-Pass-2026',
        ])->assertOk()
            ->assertJsonPath('data.active_organization_id', $organizationId)
            ->assertJsonPath('data.active_farm_id', $farmId);
    }

    public function test_owner_signup_validates_password_and_duplicate_email(): void
    {
        $this->ownerSignup()->assertCreated();
        $this->postJson('/api/v1/auth/owner-signup', [
            ...$this->ownerPayload(),
            'password' => 'short',
            'password_confirmation' => 'short',
        ])->assertUnprocessable()->assertJsonPath('error.code', 'VALIDATION_FAILED');
        $this->ownerSignup()->assertUnprocessable()
            ->assertJsonPath('error.code', 'VALIDATION_FAILED');
        $this->assertDatabaseCount('organizations', 1);
    }

    public function test_reusable_invite_adds_multiple_family_accounts_to_the_same_farm(): void
    {
        $owner = $this->ownerSignup()->assertCreated();
        $token = $this->rotateInvite($owner->json('data.access_token'));

        $this->postJson('/api/v1/auth/family-invite/inspect', [
            'invitation_token' => $token,
        ])->assertOk()
            ->assertJsonPath('data.farm.name', 'Sunrise Dairy Farm');

        $first = $this->familySignup(
            $token,
            'Fatima Saleem',
            'fatima@sunrise.test',
        )->assertCreated();
        $second = $this->familySignup(
            $token,
            'Hamza Saleem',
            'hamza@sunrise.test',
        )->assertCreated();

        $this->assertSame(
            $owner->json('data.active_organization_id'),
            $first->json('data.active_organization_id'),
        );
        $this->assertSame(
            $owner->json('data.active_farm_id'),
            $second->json('data.active_farm_id'),
        );
        $this->assertContains('animals.create', $first->json('data.permissions'));
        $this->assertDatabaseCount('farm_invite_links', 1);
        $storedInvite = FarmInviteLink::firstOrFail();
        $this->assertNotSame($token, $storedInvite->token_hash);
        $this->assertStringNotContainsString($token, $storedInvite->token_ciphertext);
        $this->assertSame(2, OrganizationMembership::query()
            ->where('membership_type', 'family_admin')
            ->where('status', 'active')
            ->count());
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'auth.family_account_registered',
        ]);
    }

    public function test_owner_can_disable_or_regenerate_invite_and_old_link_stops_working(): void
    {
        $owner = $this->ownerSignup()->assertCreated();
        $bearer = $this->bearer($owner->json('data.access_token'));
        $oldToken = $this->rotateInvite($owner->json('data.access_token'));

        $this->deleteJson('/api/v1/family-invite', [], $bearer)
            ->assertOk()
            ->assertJsonPath('data.disabled', true);
        $this->postJson('/api/v1/auth/family-invite/inspect', [
            'invitation_token' => $oldToken,
        ])->assertNotFound();

        $newToken = $this->postJson('/api/v1/family-invite', [], $bearer)
            ->assertCreated()
            ->json('data.invitation_token');
        $this->assertNotSame($oldToken, $newToken);
        $this->assertSame(2, FarmInviteLink::firstOrFail()->generation);
        $this->postJson('/api/v1/auth/family-invite/inspect', [
            'invitation_token' => $oldToken,
        ])->assertNotFound();
        $this->postJson('/api/v1/auth/family-invite/inspect', [
            'invitation_token' => $newToken,
        ])->assertOk();
    }

    public function test_primary_owner_can_remove_and_restore_family_while_family_cannot_manage_membership(): void
    {
        $owner = $this->ownerSignup()->assertCreated();
        $ownerToken = $owner->json('data.access_token');
        $invite = $this->rotateInvite($ownerToken);
        $family = $this->familySignup(
            $invite,
            'Fatima Saleem',
            'fatima@sunrise.test',
        )->assertCreated();
        $familyToken = $family->json('data.access_token');

        $this->getJson('/api/v1/family-members', $this->bearer($familyToken))
            ->assertForbidden();
        $members = $this->getJson(
            '/api/v1/family-members',
            $this->bearer($ownerToken),
        )->assertOk();
        $membershipId = $members->json('data.0.id');

        $this->deleteJson(
            '/api/v1/family-members/'.$membershipId,
            [],
            $this->bearer($ownerToken),
        )->assertOk();
        $this->assertDatabaseHas('organization_memberships', [
            'id' => $membershipId,
            'status' => 'removed',
        ]);
        $this->assertNotNull(
            ApiSession::query()->where('user_id', $family->json('data.user.id'))->firstOrFail()->revoked_at,
        );
        $this->getJson('/api/v1/auth/me', $this->bearer($familyToken))
            ->assertUnauthorized();

        $this->postJson(
            '/api/v1/family-members/'.$membershipId.'/restore',
            [],
            $this->bearer($ownerToken),
        )->assertOk();
        $this->assertDatabaseHas('organization_memberships', [
            'id' => $membershipId,
            'status' => 'active',
        ]);
        $this->postJson('/api/v1/auth/login', [
            'email' => 'fatima@sunrise.test',
            'password' => 'Family-Pass-2026',
        ])->assertOk()
            ->assertJsonPath(
                'data.active_organization_id',
                $owner->json('data.active_organization_id'),
            )
            ->assertJsonPath(
                'data.active_farm_id',
                $owner->json('data.active_farm_id'),
            );
    }

    public function test_family_memberships_are_concealed_across_farms(): void
    {
        $firstOwner = $this->ownerSignup()->assertCreated();
        $firstFamily = $this->familySignup(
            $this->rotateInvite($firstOwner->json('data.access_token')),
            'Fatima Saleem',
            'fatima@sunrise.test',
        )->assertCreated();
        $firstMembership = OrganizationMembership::query()
            ->where('user_id', $firstFamily->json('data.user.id'))
            ->firstOrFail();

        $secondOwner = $this->postJson('/api/v1/auth/owner-signup', [
            ...$this->ownerPayload(),
            'farm_name' => 'Green Valley Dairy',
            'email' => 'owner@green-valley.test',
        ])->assertCreated();

        $this->deleteJson(
            '/api/v1/family-members/'.$firstMembership->id,
            [],
            $this->bearer($secondOwner->json('data.access_token')),
        )->assertNotFound();

        $this->getJson(
            '/api/v1/family-members',
            $this->bearer($secondOwner->json('data.access_token')),
        )->assertOk()->assertJsonCount(0, 'data');
        $this->assertDatabaseHas('organization_memberships', [
            'id' => $firstMembership->id,
            'status' => 'active',
        ]);
    }

    public function test_profile_name_phone_email_and_photo_are_editable_with_current_password_protection(): void
    {
        Storage::fake('local');
        $owner = $this->ownerSignup()->assertCreated();
        $bearer = $this->bearer($owner->json('data.access_token'));

        $this->patchJson('/api/v1/auth/profile', [
            'name' => 'Tayyab Saleem',
            'phone_number' => '+92 333 7654321',
            'email' => 'updated@sunrise.test',
            'current_password' => 'wrong-password',
        ], $bearer)->assertUnprocessable()
            ->assertJsonPath('error.code', 'INVALID_CURRENT_PASSWORD');

        $this->patchJson('/api/v1/auth/profile', [
            'name' => 'Tayyab Saleem',
            'phone_number' => '+92 333 7654321',
            'email' => 'updated@sunrise.test',
            'current_password' => 'Owner-Pass-2026',
        ], $bearer)->assertOk()
            ->assertJsonPath('data.name', 'Tayyab Saleem')
            ->assertJsonPath('data.email', 'updated@sunrise.test')
            ->assertJsonPath('data.phone_number', '+92 333 7654321');

        $photo = UploadedFile::fake()->create('owner.png', 100, 'image/png');
        $this->post('/api/v1/auth/profile/photo', ['photo' => $photo], [
            ...$bearer,
            'Accept' => 'application/json',
        ])->assertOk()->assertJsonPath('data.has_profile_photo', true);
        $path = User::query()->where('email', 'updated@sunrise.test')->firstOrFail()->profile_photo_path;
        Storage::disk('local')->assertExists($path);
        $this->get('/api/v1/auth/profile/photo', $bearer)->assertOk();

        $this->deleteJson('/api/v1/auth/profile/photo', [], $bearer)
            ->assertOk()
            ->assertJsonPath('data.has_profile_photo', false);
        Storage::disk('local')->assertMissing($path);
    }

    private function ownerSignup()
    {
        return $this->postJson('/api/v1/auth/owner-signup', $this->ownerPayload());
    }

    private function ownerPayload(): array
    {
        return [
            'name' => 'Tayyab Saleem',
            'farm_name' => 'Sunrise Dairy Farm',
            'email' => 'owner@sunrise.test',
            'phone_number' => '+92 300 1234567',
            'password' => 'Owner-Pass-2026',
            'password_confirmation' => 'Owner-Pass-2026',
            'timezone' => 'Asia/Karachi',
            'device_name' => 'Owner browser',
        ];
    }

    private function rotateInvite(string $ownerToken): string
    {
        return $this->postJson(
            '/api/v1/family-invite',
            [],
            $this->bearer($ownerToken),
        )->assertCreated()->json('data.invitation_token');
    }

    private function familySignup(string $token, string $name, string $email)
    {
        return $this->postJson('/api/v1/auth/family-signup', [
            'invitation_token' => $token,
            'name' => $name,
            'email' => $email,
            'phone_number' => '+92 301 1234567',
            'password' => 'Family-Pass-2026',
            'password_confirmation' => 'Family-Pass-2026',
            'device_name' => 'Family browser',
        ]);
    }

    private function bearer(string $token): array
    {
        return ['Authorization' => 'Bearer '.$token];
    }
}

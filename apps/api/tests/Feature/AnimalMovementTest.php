<?php

namespace Tests\Feature;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Domain\AnimalRegistry\Models\AnimalSpecies;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\OrganizationMembership;
use App\Models\Permission;
use App\Models\Role;
use App\Models\Setting;
use App\Models\Shed;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class AnimalMovementTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    private array $permissions = [
        'animals.view',
        'animals.move',
        'animal_movements.view',
        'animal_movements.approve',
        'animal_movements.reject',
        'animal_movements.cancel',
    ];

    public function test_request_is_pending_idempotent_searchable_and_does_not_change_location(): void
    {
        $context = $this->movementContext();
        $headers = $this->bearer($this->loginToken());
        $payload = $this->movementPayload($context, ['reason' => 'Move to observation']);

        $created = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $payload,
            $headers + ['Idempotency-Key' => 'movement-request-1'],
        )->assertCreated();
        $replay = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $payload,
            $headers + ['Idempotency-Key' => 'movement-request-1'],
        )->assertCreated();

        $this->assertSame('pending', $created->json('data.status'));
        $this->assertTrue($created->json('data.approval_required'));
        $this->assertSame($created->json('data.id'), $replay->json('data.id'));
        $this->assertDatabaseCount('animal_movements', 1);
        $this->assertDatabaseHas('animals', [
            'id' => $context['animal']->id,
            'current_farm_id' => $context['sourceFarm']->id,
            'current_shed_id' => $context['sourceShed']->id,
            'current_animal_group_id' => $context['sourceGroup']->id,
        ]);
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $payload,
            $headers + ['Idempotency-Key' => 'movement-request-conflict'],
        )->assertConflict()->assertJsonPath('error.code', 'PENDING_MOVEMENT_EXISTS');
        $list = $this->getJson(
            "/api/v1/animals/{$context['animal']->id}/movements?filter%5Bsearch%5D=observation",
            $headers,
        )->assertOk();
        $this->assertCount(1, $list->json('data'));
        $this->assertSame(1, $list->json('meta.pagination.total'));
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'animal.movement_requested',
            'entity_id' => $created->json('data.id'),
        ]);
    }

    public function test_approval_disabled_applies_the_same_movement_action_immediately_and_atomically(): void
    {
        $context = $this->movementContext();
        $this->setApproval($context['organization']->id, false);
        $headers = $this->bearer($this->loginToken());

        $response = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $this->movementPayload($context),
            $headers + ['Idempotency-Key' => 'movement-immediate'],
        )->assertCreated();

        $response->assertJsonPath('data.status', 'approved')
            ->assertJsonPath('data.approval_required', false)
            ->assertJsonPath('data.version', 2);
        $this->assertNotNull($response->json('data.actual_effective_at'));
        $this->assertDatabaseHas('animals', [
            'id' => $context['animal']->id,
            'current_farm_id' => $context['destinationFarm']->id,
            'current_shed_id' => $context['destinationShed']->id,
            'current_animal_group_id' => $context['destinationGroup']->id,
            'version' => 2,
        ]);
        foreach ([
            'animal.movement_requested',
            'animal.movement_approved',
            'animal.location_changed',
        ] as $event) {
            $this->assertDatabaseHas('audit_logs', ['action' => $event]);
        }
    }

    public function test_distinct_approver_updates_location_and_decision_is_idempotent_but_not_repeatable(): void
    {
        $context = $this->movementContext();
        $requesterHeaders = $this->bearer($this->loginToken());
        $movement = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $this->movementPayload($context),
            $requesterHeaders + ['Idempotency-Key' => 'movement-for-approval'],
        )->assertCreated();
        $movementId = $movement->json('data.id');
        $this->postJson(
            "/api/v1/animal-movements/{$movementId}/approve",
            ['version' => 1],
            $requesterHeaders + ['Idempotency-Key' => 'self-approval'],
        )->assertForbidden();

        $approver = $this->authorizedUser($context, 'approver@example.test', $this->permissions);
        $approverHeaders = $this->bearer($approver['token']);
        $approved = $this->postJson(
            "/api/v1/animal-movements/{$movementId}/approve",
            ['version' => 1],
            $approverHeaders + ['Idempotency-Key' => 'approve-once'],
        )->assertOk();
        $replay = $this->postJson(
            "/api/v1/animal-movements/{$movementId}/approve",
            ['version' => 1],
            $approverHeaders + ['Idempotency-Key' => 'approve-once'],
        )->assertOk();

        $this->assertSame('approved', $approved->json('data.status'));
        $this->assertSame($approved->json('data.id'), $replay->json('data.id'));
        $this->assertSame($approver['user']->id, $approved->json('data.decided_by'));
        $this->postJson(
            "/api/v1/animal-movements/{$movementId}/approve",
            ['version' => 2],
            $approverHeaders + ['Idempotency-Key' => 'approve-twice'],
        )->assertConflict()->assertJsonPath('error.code', 'MOVEMENT_NOT_PENDING');
        $this->assertDatabaseHas('animals', [
            'id' => $context['animal']->id,
            'current_farm_id' => $context['destinationFarm']->id,
        ]);
    }

    public function test_rejection_requires_reason_and_cancellation_leave_location_unchanged(): void
    {
        $context = $this->movementContext();
        $requesterHeaders = $this->bearer($this->loginToken());
        $approver = $this->authorizedUser($context, 'decision@example.test', $this->permissions);
        $decisionHeaders = $this->bearer($approver['token']);
        $movementId = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $this->movementPayload($context),
            $requesterHeaders + ['Idempotency-Key' => 'movement-reject'],
        )->assertCreated()->json('data.id');

        $this->postJson(
            "/api/v1/animal-movements/{$movementId}/reject",
            ['version' => 1],
            $decisionHeaders,
        )->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['reason']]]);
        $this->postJson(
            "/api/v1/animal-movements/{$movementId}/reject",
            ['version' => 1, 'reason' => 'Destination is unavailable'],
            $decisionHeaders + ['Idempotency-Key' => 'reject-once'],
        )->assertOk()->assertJsonPath('data.status', 'rejected');
        $this->assertDatabaseHas('animals', [
            'id' => $context['animal']->id,
            'current_farm_id' => $context['sourceFarm']->id,
            'current_shed_id' => $context['sourceShed']->id,
            'current_animal_group_id' => $context['sourceGroup']->id,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'animal.movement_rejected',
            'entity_id' => $movementId,
        ]);

        $secondId = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $this->movementPayload($context),
            $requesterHeaders + ['Idempotency-Key' => 'movement-cancel'],
        )->assertCreated()->json('data.id');
        $this->postJson(
            "/api/v1/animal-movements/{$secondId}/cancel",
            ['version' => 1, 'reason' => 'Request entered in error'],
            $decisionHeaders + ['Idempotency-Key' => 'cancel-once'],
        )->assertOk()->assertJsonPath('data.status', 'cancelled');
        $this->assertDatabaseHas('animals', [
            'id' => $context['animal']->id,
            'current_farm_id' => $context['sourceFarm']->id,
            'current_shed_id' => $context['sourceShed']->id,
            'current_animal_group_id' => $context['sourceGroup']->id,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'animal.movement_cancelled',
            'entity_id' => $secondId,
        ]);
    }

    public function test_approved_movement_cannot_be_cancelled_or_edited_through_an_ordinary_endpoint(): void
    {
        $context = $this->movementContext();
        $this->setApproval($context['organization']->id, false);
        $headers = $this->bearer($this->loginToken());
        $movementId = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $this->movementPayload($context),
            $headers + ['Idempotency-Key' => 'movement-approved'],
        )->assertCreated()->json('data.id');

        $this->postJson(
            "/api/v1/animal-movements/{$movementId}/cancel",
            ['version' => 2, 'reason' => 'Attempted rollback'],
            $headers + ['Idempotency-Key' => 'cancel-approved'],
        )->assertConflict()->assertJsonPath('error.code', 'MOVEMENT_NOT_PENDING');
        $this->patchJson(
            "/api/v1/animal-movements/{$movementId}",
            ['reason' => 'Edited history', 'version' => 2],
            $headers,
        )->assertMethodNotAllowed();
    }

    public function test_source_destination_tenant_farm_shed_group_and_same_location_rules_are_enforced(): void
    {
        $context = $this->movementContext(allFarms: false);
        $headers = $this->bearer($this->loginToken());
        $base = $this->movementPayload($context);

        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            [...$base, 'source_shed_id' => $context['destinationShed']->id],
            $headers,
        )->assertConflict()->assertJsonPath('error.code', 'SOURCE_LOCATION_CHANGED');
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            [
                ...$base,
                'destination_farm_id' => $context['sourceFarm']->id,
                'destination_shed_id' => $context['sourceShed']->id,
                'destination_animal_group_id' => $context['sourceGroup']->id,
            ],
            $headers,
        )->assertUnprocessable();
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $base,
            $headers,
        )->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['destination_farm_id']]]);

        $context['membership']->farms()->attach(
            $context['destinationFarm']->id,
            ['organization_id' => $context['organization']->id],
        );
        $foreign = $this->foreignLocation();
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            [
                ...$base,
                'destination_farm_id' => $foreign['farm']->id,
                'destination_shed_id' => $foreign['shed']->id,
            ],
            $headers,
        )->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['destination_farm_id']]]);
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            [...$base, 'destination_shed_id' => $context['sourceShed']->id],
            $headers,
        )->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['destination_shed_id']]]);
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            [...$base, 'destination_animal_group_id' => $context['sourceGroup']->id],
            $headers,
        )->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['destination_animal_group_id']]]);
    }

    public function test_stale_movement_is_rejected_when_animal_location_changed_before_approval(): void
    {
        $context = $this->movementContext();
        $requesterHeaders = $this->bearer($this->loginToken());
        $movementId = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $this->movementPayload($context),
            $requesterHeaders + ['Idempotency-Key' => 'movement-stale'],
        )->assertCreated()->json('data.id');
        $context['animal']->forceFill([
            'current_farm_id' => $context['destinationFarm']->id,
            'current_shed_id' => $context['destinationShed']->id,
            'current_animal_group_id' => $context['destinationGroup']->id,
            'version' => 2,
        ])->save();
        $approver = $this->authorizedUser($context, 'stale-approver@example.test', $this->permissions);

        $this->postJson(
            "/api/v1/animal-movements/{$movementId}/approve",
            ['version' => 1],
            $this->bearer($approver['token']) + ['Idempotency-Key' => 'approve-stale'],
        )->assertConflict()->assertJsonPath('error.code', 'STALE_MOVEMENT');
        $this->assertDatabaseHas('animal_movements', ['id' => $movementId, 'status' => 'pending']);
    }

    public function test_permissions_tenant_and_both_farm_scope_conceal_movement_records(): void
    {
        $context = $this->movementContext();
        $headers = $this->bearer($this->loginToken());
        $movementId = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $this->movementPayload($context),
            $headers + ['Idempotency-Key' => 'movement-scope'],
        )->assertCreated()->json('data.id');

        $this->getJson("/api/v1/animals/{$context['animal']->id}/movements")
            ->assertUnauthorized();
        $context['role']->permissions()->detach(
            Permission::query()->where('name', 'animal_movements.view')->value('id'),
        );
        $this->getJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $headers,
        )->assertForbidden();
        $this->getJson("/api/v1/animal-movements/{$movementId}", $headers)->assertForbidden();
        $context['role']->permissions()->attach(
            Permission::query()->where('name', 'animal_movements.view')->value('id'),
        );
        $context['membership']->forceFill(['all_farms' => false])->save();
        $context['membership']->farms()->sync([
            $context['sourceFarm']->id => ['organization_id' => $context['organization']->id],
        ]);
        $this->getJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $headers,
        )->assertOk()->assertJsonCount(0, 'data');
        $this->getJson("/api/v1/animal-movements/{$movementId}", $headers)->assertNotFound();

        $foreign = $this->foreignLocation();
        $foreignAnimal = Animal::create([
            'organization_id' => $foreign['organization']->id,
            'animal_number' => 'AN-FOREIGN',
            'species_id' => $context['references']['species']->id,
            'breed_id' => $foreign['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'current_farm_id' => $foreign['farm']->id,
            'current_shed_id' => $foreign['shed']->id,
            'origin' => 'other',
        ]);
        $this->getJson(
            "/api/v1/animals/{$foreignAnimal->id}/movements",
            $headers,
        )->assertNotFound();
    }

    public function test_sync_bootstrap_and_incremental_include_authorized_movement_status_changes(): void
    {
        $context = $this->movementContext();
        $requesterHeaders = $this->bearer($this->loginToken());
        $movementId = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $this->movementPayload($context),
            $requesterHeaders + ['Idempotency-Key' => 'movement-sync'],
        )->assertCreated()->json('data.id');
        $bootstrap = $this->getJson('/api/v1/sync/bootstrap', $requesterHeaders)->assertOk();
        $this->assertTrue($bootstrap->json('data.animal_movements_authorized'));
        $this->assertSame('pending', collect($bootstrap->json('data.animal_movements'))->firstWhere('id', $movementId)['status']);

        $approver = $this->authorizedUser($context, 'sync-approver@example.test', $this->permissions);
        $this->postJson(
            "/api/v1/animal-movements/{$movementId}/approve",
            ['version' => 1],
            $this->bearer($approver['token']) + ['Idempotency-Key' => 'approve-sync'],
        )->assertOk();
        $changes = $this->getJson(
            '/api/v1/sync/changes?cursor='.urlencode($bootstrap->json('data.next_cursor')),
            $requesterHeaders,
        )->assertOk();
        $this->assertSame('approved', collect($changes->json('data.animal_movements'))->firstWhere('id', $movementId)['status']);

        $context['role']->permissions()->detach();
        $withoutPermission = $this->getJson('/api/v1/sync/bootstrap', $requesterHeaders)->assertOk();
        $this->assertFalse($withoutPermission->json('data.animal_movements_authorized'));
        $this->assertCount(0, $withoutPermission->json('data.animal_movements'));
    }

    public function test_immediate_movement_requires_approval_authority(): void
    {
        $context = $this->movementContext(permissions: [
            'animals.view',
            'animals.move',
            'animal_movements.view',
        ]);
        $this->setApproval($context['organization']->id, false);

        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/movements",
            $this->movementPayload($context),
            $this->bearer($this->loginToken()) + ['Idempotency-Key' => 'worker-immediate'],
        )->assertForbidden();
        $this->assertDatabaseCount('animal_movements', 0);
    }

    private function movementContext(
        bool $allFarms = true,
        ?array $permissions = null,
    ): array {
        $foundation = $this->foundation($permissions ?? $this->permissions, $allFarms);
        $references = $this->animalRegistryReferences($foundation);
        $destinationFarm = Farm::create([
            'organization_id' => $foundation['organization']->id,
            'name' => 'South Farm',
            'code' => 'SOUTH',
            'timezone' => 'UTC',
        ]);
        $destinationShed = Shed::create([
            'organization_id' => $foundation['organization']->id,
            'farm_id' => $destinationFarm->id,
            'name' => 'Receiving Shed',
            'code' => 'RECEIVING',
        ]);
        $destinationGroup = AnimalGroup::create([
            'organization_id' => $foundation['organization']->id,
            'farm_id' => $destinationFarm->id,
            'default_shed_id' => $destinationShed->id,
            'code' => 'RECEIVING',
            'name' => 'Receiving',
            'normalized_name' => 'receiving',
        ]);
        $animal = Animal::create([
            'organization_id' => $foundation['organization']->id,
            'animal_number' => 'AN-MOVE-001',
            'species_id' => $references['species']->id,
            'breed_id' => $references['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'current_farm_id' => $foundation['farm']->id,
            'current_shed_id' => $foundation['shed']->id,
            'current_animal_group_id' => $references['group']->id,
            'origin' => 'born_on_farm',
            'created_by' => $foundation['user']->id,
            'updated_by' => $foundation['user']->id,
        ]);

        return [
            ...$foundation,
            'references' => $references,
            'animal' => $animal,
            'sourceFarm' => $foundation['farm'],
            'sourceShed' => $foundation['shed'],
            'sourceGroup' => $references['group'],
            'destinationFarm' => $destinationFarm,
            'destinationShed' => $destinationShed,
            'destinationGroup' => $destinationGroup,
        ];
    }

    private function movementPayload(array $context, array $overrides = []): array
    {
        return [
            'source_farm_id' => $context['sourceFarm']->id,
            'source_shed_id' => $context['sourceShed']->id,
            'source_animal_group_id' => $context['sourceGroup']->id,
            'destination_farm_id' => $context['destinationFarm']->id,
            'destination_shed_id' => $context['destinationShed']->id,
            'destination_animal_group_id' => $context['destinationGroup']->id,
            'requested_effective_at' => now()->subMinute()->toISOString(),
            'reason' => 'Routine herd relocation',
            'notes' => 'Move after morning inspection.',
            ...$overrides,
        ];
    }

    private function setApproval(string $organizationId, bool $enabled): void
    {
        Setting::query()->updateOrCreate(
            [
                'organization_id' => $organizationId,
                'farm_id' => null,
                'key' => 'animal_movement_requires_approval',
            ],
            ['type' => 'boolean', 'value' => ['enabled' => $enabled]],
        );
    }

    private function authorizedUser(array $context, string $email, array $permissions): array
    {
        $user = User::create([
            'name' => 'Movement Approver',
            'email' => $email,
            'password' => Hash::make('Correct-Horse-2026'),
            'is_active' => true,
        ]);
        $membership = OrganizationMembership::create([
            'organization_id' => $context['organization']->id,
            'user_id' => $user->id,
            'status' => 'active',
            'all_farms' => true,
        ]);
        $role = Role::create([
            'organization_id' => $context['organization']->id,
            'name' => 'Movement Approver '.Str::random(5),
            'slug' => 'movement-approver-'.Str::lower(Str::random(5)),
        ]);
        foreach ($permissions as $permission) {
            $role->permissions()->attach(Permission::firstOrCreate(['name' => $permission])->id);
        }
        $membership->roles()->attach($role->id, ['organization_id' => $context['organization']->id]);

        return [
            'user' => $user,
            'membership' => $membership,
            'token' => $this->loginToken($email),
        ];
    }

    private function foreignLocation(): array
    {
        $organization = Organization::create(['name' => 'Foreign Dairy '.Str::random(5)]);
        $farm = Farm::create([
            'organization_id' => $organization->id,
            'name' => 'Foreign Farm',
            'code' => 'FOREIGN-'.Str::upper(Str::random(5)),
            'timezone' => 'UTC',
        ]);
        $shed = Shed::create([
            'organization_id' => $organization->id,
            'farm_id' => $farm->id,
            'name' => 'Foreign Shed',
            'code' => 'FOREIGN-'.Str::upper(Str::random(5)),
        ]);
        $breed = AnimalBreed::create([
            'organization_id' => $organization->id,
            'species_id' => AnimalSpecies::query()->firstOrFail()->id,
            'code' => 'FOREIGN-'.Str::upper(Str::random(5)),
            'name' => 'Foreign Breed',
            'normalized_name' => 'foreign breed '.Str::lower(Str::random(5)),
        ]);

        return compact('organization', 'farm', 'shed', 'breed');
    }
}

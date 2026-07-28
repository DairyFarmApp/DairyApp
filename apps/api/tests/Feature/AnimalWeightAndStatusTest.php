<?php

namespace Tests\Feature;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Domain\AnimalRegistry\Models\AnimalSpecies;
use App\Domain\AnimalStatuses\Models\AnimalStatusChange;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\Permission;
use App\Models\Setting;
use App\Models\Shed;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class AnimalWeightAndStatusTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    private string $weightFarmId;

    private array $permissions = [
        'animals.view',
        'animals.update',
        'animals.record_weight',
        'animals.correct_weight',
        'animals.view_weight_history',
        'animals.change_status',
        'animals.view_status_history',
    ];

    public function test_weights_are_idempotent_decimal_safe_paginated_audited_and_project_latest(): void
    {
        $context = $this->context();
        $headers = $this->bearer($this->loginToken());
        $firstPayload = $this->weightPayload([
            'value' => '500.125',
            'unit' => 'kg',
            'observed_at' => now()->subDays(2)->toISOString(),
        ]);
        $created = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/weights",
            $firstPayload,
            $headers + ['Idempotency-Key' => 'weight-create-one'],
        )->assertCreated();
        $replay = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/weights",
            $firstPayload,
            $headers + ['Idempotency-Key' => 'weight-create-one'],
        )->assertCreated();
        $second = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/weights",
            $this->weightPayload([
                'value' => '1100.000000',
                'unit' => 'lb',
                'observed_at' => now()->subDay()->toISOString(),
                'source' => 'manual',
            ]),
            $headers + ['Idempotency-Key' => 'weight-create-two'],
        )->assertCreated();

        $this->assertSame($created->json('data.id'), $replay->json('data.id'));
        $created->assertJsonPath('data.entered_value', '500.125000')
            ->assertJsonPath('data.normalized_kg', '500.125000');
        $second->assertJsonPath('data.entered_value', '1100.000000')
            ->assertJsonPath('data.normalized_kg', '498.951607');
        $this->assertDatabaseCount('animal_weights', 2);
        $list = $this->getJson(
            "/api/v1/animals/{$context['animal']->id}/weights?page%5Bsize%5D=1",
            $headers,
        )->assertOk();
        $this->assertCount(1, $list->json('data'));
        $this->assertSame(2, $list->json('meta.pagination.total'));
        $secondPage = $this->getJson(
            "/api/v1/animals/{$context['animal']->id}/weights?page%5Bsize%5D=1&page%5Bpage%5D=2",
            $headers,
        )->assertOk();
        $this->assertSame(2, $secondPage->json('meta.pagination.current_page'));
        $this->assertSame($created->json('data.id'), $secondPage->json('data.0.id'));
        $this->getJson(
            "/api/v1/animal-weights/{$second->json('data.id')}",
            $headers,
        )->assertOk()->assertJsonPath('data.animal_number', 'AN-WEIGHT-001');
        $this->getJson(
            "/api/v1/animals/{$context['animal']->id}",
            $headers,
        )->assertOk()
            ->assertJsonPath('data.latest_weight.id', $second->json('data.id'))
            ->assertJsonPath('data.latest_weight.normalized_kg', '498.951607');
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'animal.weight_recorded',
            'entity_id' => $created->json('data.id'),
        ]);
    }

    public function test_weight_validation_enforces_positive_maximum_time_source_and_archive_rules(): void
    {
        $context = $this->context();
        Setting::create([
            'organization_id' => $context['organization']->id,
            'key' => 'animal_weight_max_kg',
            'type' => 'decimal',
            'value' => ['kilograms' => '500.000000'],
        ]);
        $headers = $this->bearer($this->loginToken());

        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/weights",
            $this->weightPayload(['farm_id' => Str::uuid7()->toString()]),
            $headers + ['Idempotency-Key' => 'wrong-weight-farm'],
        )->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['farm_id']]]);

        foreach ([
            ['value' => '0', 'unit' => 'kg'],
            ['value' => '501', 'unit' => 'kg'],
            ['value' => '1200', 'unit' => 'lb'],
        ] as $index => $overrides) {
            $this->postJson(
                "/api/v1/animals/{$context['animal']->id}/weights",
                $this->weightPayload($overrides),
                $headers + ['Idempotency-Key' => "invalid-weight-{$index}"],
            )->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['value']]]);
        }
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/weights",
            $this->weightPayload(['observed_at' => now()->addMinutes(6)->toISOString()]),
            $headers,
        )->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['observed_at']]]);
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/weights",
            $this->weightPayload(['source' => 'unknown']),
            $headers,
        )->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['source']]]);

        $context['animal']->delete();
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/weights",
            $this->weightPayload(),
            $headers,
        )->assertUnprocessable();
        $this->assertDatabaseCount('animal_weights', 0);
    }

    public function test_weight_correction_is_linked_immutable_idempotent_and_updates_latest_projection(): void
    {
        $context = $this->context();
        $headers = $this->bearer($this->loginToken());
        $original = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/weights",
            $this->weightPayload(['value' => '450.000000']),
            $headers + ['Idempotency-Key' => 'weight-to-correct'],
        )->assertCreated();
        $payload = [
            'value' => '455.500000',
            'unit' => 'kg',
            'correction_reason' => 'The paper scale log was rechecked.',
            'notes' => 'Verified replacement.',
        ];
        $corrected = $this->postJson(
            "/api/v1/animal-weights/{$original->json('data.id')}/correct",
            $payload,
            $headers + ['Idempotency-Key' => 'weight-correction-one'],
        )->assertCreated();
        $replay = $this->postJson(
            "/api/v1/animal-weights/{$original->json('data.id')}/correct",
            $payload,
            $headers + ['Idempotency-Key' => 'weight-correction-one'],
        )->assertCreated();

        $this->assertSame($corrected->json('data.id'), $replay->json('data.id'));
        $corrected->assertJsonPath('data.supersedes_weight_id', $original->json('data.id'))
            ->assertJsonPath('data.normalized_kg', '455.500000');
        $this->assertDatabaseHas('animal_weights', [
            'id' => $original->json('data.id'),
            'is_superseded' => true,
            'superseded_by_weight_id' => $corrected->json('data.id'),
        ]);
        $this->postJson(
            "/api/v1/animal-weights/{$original->json('data.id')}/correct",
            $payload,
            $headers + ['Idempotency-Key' => 'weight-correction-twice'],
        )->assertConflict()->assertJsonPath('error.code', 'WEIGHT_ALREADY_CORRECTED');
        $this->postJson(
            "/api/v1/animal-weights/{$corrected->json('data.id')}/correct",
            $payload,
            $headers + ['Idempotency-Key' => 'weight-correction-loop'],
        )->assertConflict()->assertJsonPath('error.code', 'CORRECTION_CANNOT_BE_CORRECTED');
        $this->getJson(
            "/api/v1/animals/{$context['animal']->id}",
            $headers,
        )->assertOk()->assertJsonPath('data.latest_weight.id', $corrected->json('data.id'));
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'animal.weight_corrected',
            'entity_id' => $corrected->json('data.id'),
        ]);
    }

    public function test_status_changes_are_atomic_reasoned_versioned_idempotent_and_not_ordinary_edits(): void
    {
        $context = $this->context();
        $headers = $this->bearer($this->loginToken());
        $payload = [
            'new_status' => 'missing',
            'effective_at' => now()->subMinute()->toISOString(),
            'reason' => 'Not located during the evening headcount.',
            'version' => 1,
        ];
        $changed = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/status-changes",
            $payload,
            $headers + ['Idempotency-Key' => 'status-change-one'],
        )->assertCreated();
        $replay = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/status-changes",
            $payload,
            $headers + ['Idempotency-Key' => 'status-change-one'],
        )->assertCreated();

        $this->assertSame($changed->json('data.id'), $replay->json('data.id'));
        $changed->assertJsonPath('data.previous_status', 'active')
            ->assertJsonPath('data.new_status', 'missing')
            ->assertJsonPath('data.sequence', 1)
            ->assertJsonPath('data.animal_version', 2);
        $this->assertDatabaseHas('animals', [
            'id' => $context['animal']->id,
            'operational_status' => 'missing',
            'version' => 2,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'animal.status_changed',
            'entity_id' => $context['animal']->id,
        ]);
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/status-changes",
            [...$payload, 'version' => 2],
            $headers + ['Idempotency-Key' => 'status-same'],
        )->assertConflict()->assertJsonPath('error.code', 'STATUS_UNCHANGED');
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/status-changes",
            [
                'new_status' => 'active',
                'effective_at' => now()->toISOString(),
                'version' => 2,
            ],
            $headers,
        )->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['reason']]]);
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/status-changes",
            [
                'new_status' => 'active',
                'effective_at' => now()->toISOString(),
                'reason' => 'Animal was found and identity was confirmed.',
                'version' => 2,
            ],
            $headers + ['Idempotency-Key' => 'status-restored'],
        )->assertCreated()->assertJsonPath('data.sequence', 2);
        $history = $this->getJson(
            "/api/v1/animals/{$context['animal']->id}/status-history?page%5Bsize%5D=1",
            $headers,
        )->assertOk();
        $this->assertSame(2, $history->json('meta.pagination.total'));
        $this->assertSame('active', $history->json('data.0.new_status'));
        $olderHistory = $this->getJson(
            "/api/v1/animals/{$context['animal']->id}/status-history?page%5Bsize%5D=1&page%5Bpage%5D=2",
            $headers,
        )->assertOk();
        $this->assertSame(2, $olderHistory->json('meta.pagination.current_page'));
        $this->assertSame('missing', $olderHistory->json('data.0.new_status'));

        $this->patchJson(
            "/api/v1/animals/{$context['animal']->id}",
            ['operational_status' => 'inactive', 'version' => 3],
            $headers,
        )->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['operational_status']]]);
        $this->assertDatabaseHas('animals', [
            'id' => $context['animal']->id,
            'operational_status' => 'active',
            'version' => 3,
        ]);
    }

    public function test_status_rejects_stale_future_same_and_archived_changes_without_partial_history(): void
    {
        $context = $this->context();
        $headers = $this->bearer($this->loginToken());
        $payload = [
            'new_status' => 'inactive',
            'effective_at' => now()->subMinute()->toISOString(),
            'reason' => 'Temporarily unavailable for operations.',
            'version' => 1,
        ];
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/status-changes",
            [...$payload, 'effective_at' => now()->addMinute()->toISOString()],
            $headers,
        )->assertUnprocessable();
        $context['animal']->forceFill(['version' => 2])->save();
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/status-changes",
            $payload,
            $headers + ['Idempotency-Key' => 'status-stale'],
        )->assertStatus(412)->assertJsonPath('error.code', 'STALE_VERSION');
        $this->assertDatabaseCount('animal_status_histories', 0);

        $context['animal']->delete();
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/status-changes",
            [...$payload, 'version' => 2],
            $headers,
        )->assertUnprocessable();
        $this->assertDatabaseCount('animal_status_histories', 0);
    }

    public function test_weight_and_status_permissions_tenant_and_historical_farm_scope_are_enforced(): void
    {
        $context = $this->context();
        $headers = $this->bearer($this->loginToken());
        $weightId = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/weights",
            $this->weightPayload(),
            $headers + ['Idempotency-Key' => 'scoped-weight'],
        )->assertCreated()->json('data.id');
        AnimalStatusChange::create([
            'organization_id' => $context['organization']->id,
            'farm_id' => $context['farm']->id,
            'animal_id' => $context['animal']->id,
            'previous_status' => 'active',
            'new_status' => 'inactive',
            'effective_at' => now()->subDay(),
            'reason' => 'Historical farm-scope record.',
            'changed_by' => $context['user']->id,
            'sequence' => 1,
        ]);

        $this->getJson("/api/v1/animals/{$context['animal']->id}/weights")->assertUnauthorized();
        $this->getJson("/api/v1/animals/{$context['animal']->id}/status-history")->assertUnauthorized();

        $destinationFarm = Farm::create([
            'organization_id' => $context['organization']->id,
            'name' => 'Destination Farm',
            'code' => 'DEST-SCOPE',
            'timezone' => 'UTC',
        ]);
        $destinationShed = Shed::create([
            'organization_id' => $context['organization']->id,
            'farm_id' => $destinationFarm->id,
            'name' => 'Destination Shed',
            'code' => 'DEST-SCOPE',
        ]);
        $context['animal']->forceFill([
            'current_farm_id' => $destinationFarm->id,
            'current_shed_id' => $destinationShed->id,
            'current_animal_group_id' => null,
        ])->save();
        $context['membership']->forceFill(['all_farms' => false])->save();
        $context['membership']->farms()->sync([
            $destinationFarm->id => ['organization_id' => $context['organization']->id],
        ]);

        $this->getJson("/api/v1/animals/{$context['animal']->id}", $headers)->assertOk();
        $this->getJson(
            "/api/v1/animals/{$context['animal']->id}/weights",
            $headers,
        )->assertOk()->assertJsonCount(0, 'data');
        $this->getJson(
            "/api/v1/animals/{$context['animal']->id}/status-history",
            $headers,
        )->assertOk()->assertJsonCount(0, 'data');
        $this->getJson("/api/v1/animal-weights/{$weightId}", $headers)->assertNotFound();

        $foreign = $this->foreignAnimal();
        $this->getJson(
            "/api/v1/animals/{$foreign->id}/weights",
            $headers,
        )->assertNotFound();
        $this->getJson(
            "/api/v1/animals/{$foreign->id}/status-history",
            $headers,
        )->assertNotFound();

        foreach ([
            'animals.record_weight',
            'animals.correct_weight',
            'animals.view_weight_history',
            'animals.change_status',
            'animals.view_status_history',
        ] as $permission) {
            $context['role']->permissions()->detach(
                Permission::query()->where('name', $permission)->value('id'),
            );
        }
        $this->getJson(
            "/api/v1/animals/{$context['animal']->id}/weights",
            $headers,
        )->assertForbidden();
        $this->getJson(
            "/api/v1/animals/{$context['animal']->id}/status-history",
            $headers,
        )->assertForbidden();
    }

    public function test_sync_bootstrap_incremental_corrections_status_and_permission_removal_are_safe(): void
    {
        $context = $this->context();
        $headers = $this->bearer($this->loginToken());
        $weight = $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/weights",
            $this->weightPayload(),
            $headers + ['Idempotency-Key' => 'sync-weight'],
        )->assertCreated();
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/status-changes",
            [
                'new_status' => 'inactive',
                'effective_at' => now()->subMinute()->toISOString(),
                'reason' => 'Synchronization status test.',
                'version' => 1,
            ],
            $headers + ['Idempotency-Key' => 'sync-status'],
        )->assertCreated();
        $bootstrap = $this->getJson('/api/v1/sync/bootstrap', $headers)->assertOk();
        $this->assertTrue($bootstrap->json('data.animal_weights_authorized'));
        $this->assertTrue($bootstrap->json('data.animal_status_changes_authorized'));
        $this->assertSame($weight->json('data.id'), $bootstrap->json('data.animal_weights.0.id'));
        $this->assertSame('inactive', $bootstrap->json('data.animal_status_changes.0.new_status'));

        $correction = $this->postJson(
            "/api/v1/animal-weights/{$weight->json('data.id')}/correct",
            [
                'value' => '501.000000',
                'unit' => 'kg',
                'correction_reason' => 'Sync correction test.',
            ],
            $headers + ['Idempotency-Key' => 'sync-weight-correction'],
        )->assertCreated();
        $this->postJson(
            "/api/v1/animals/{$context['animal']->id}/status-changes",
            [
                'new_status' => 'missing',
                'effective_at' => now()->toISOString(),
                'reason' => 'Synchronization second status test.',
                'version' => 2,
            ],
            $headers + ['Idempotency-Key' => 'sync-status-two'],
        )->assertCreated();
        $changes = $this->getJson(
            '/api/v1/sync/changes?cursor='.urlencode($bootstrap->json('data.next_cursor')),
            $headers,
        )->assertOk();
        $weightRows = collect($changes->json('data.animal_weights'));
        $this->assertNotNull($weightRows->firstWhere('id', $weight->json('data.id')));
        $this->assertNotNull($weightRows->firstWhere('id', $correction->json('data.id')));
        $this->assertSame(
            'missing',
            collect($changes->json('data.animal_status_changes'))->sortByDesc('sequence')->first()['new_status'],
        );

        foreach (['animals.view_weight_history', 'animals.view_status_history'] as $permission) {
            $context['role']->permissions()->detach(
                Permission::query()->where('name', $permission)->value('id'),
            );
        }
        $withoutPermissions = $this->getJson('/api/v1/sync/bootstrap', $headers)->assertOk();
        $this->assertFalse($withoutPermissions->json('data.animal_weights_authorized'));
        $this->assertFalse($withoutPermissions->json('data.animal_status_changes_authorized'));
        $this->assertCount(0, $withoutPermissions->json('data.animal_weights'));
        $this->assertCount(0, $withoutPermissions->json('data.animal_status_changes'));
    }

    private function context(): array
    {
        $foundation = $this->foundation($this->permissions);
        $references = $this->animalRegistryReferences($foundation);
        $animal = Animal::create([
            'organization_id' => $foundation['organization']->id,
            'animal_number' => 'AN-WEIGHT-001',
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
        $this->weightFarmId = $foundation['farm']->id;

        return [...$foundation, 'references' => $references, 'animal' => $animal];
    }

    private function weightPayload(array $overrides = []): array
    {
        return [
            'farm_id' => $this->weightFarmId,
            'value' => '500.000000',
            'unit' => 'kg',
            'observed_at' => now()->subHour()->toISOString(),
            'source' => 'scale',
            'notes' => 'Routine weight.',
            ...$overrides,
        ];
    }

    private function foreignAnimal(): Animal
    {
        $organization = Organization::create(['name' => 'Foreign Status Dairy '.Str::random(5)]);
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

        return Animal::create([
            'organization_id' => $organization->id,
            'animal_number' => 'AN-FOREIGN-WEIGHT',
            'species_id' => $breed->species_id,
            'breed_id' => $breed->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'current_farm_id' => $farm->id,
            'current_shed_id' => $shed->id,
            'origin' => 'other',
        ]);
    }
}

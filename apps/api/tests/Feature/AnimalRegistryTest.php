<?php

namespace Tests\Feature;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Domain\AnimalRegistry\Models\AnimalSpecies;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\Permission;
use App\Models\Shed;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class AnimalRegistryTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    private array $permissions = [
        'animals.view',
        'animals.create',
        'animals.update',
        'animals.archive',
        'animals.restore',
        'animals.manage_identifiers',
        'animal_breeds.view',
        'animal_breeds.manage',
        'animal_groups.view',
        'animal_groups.manage',
    ];

    public function test_species_listing_and_breed_lifecycle_are_tenant_scoped_audited_and_versioned(): void
    {
        $data = $this->foundation($this->permissions);
        $references = $this->animalRegistryReferences($data);
        AnimalSpecies::create(['code' => 'BUFFALO', 'name' => 'Buffalo']);
        $loginResponse = $this->postJson('/api/v1/auth/login', ['email' => 'owner@example.test', 'password' => 'Correct-Horse-2026']);
        $this->assertSame(200, $loginResponse->status(), json_encode($loginResponse->json()));
        $headers = $this->bearer($loginResponse->json('data.access_token'));

        $speciesResponse = $this->getJson('/api/v1/animal-species', $headers);
        $this->assertSame(200, $speciesResponse->status(), json_encode($speciesResponse->json()));
        $speciesResponse->assertJsonCount(2, 'data');

        $created = $this->postJson('/api/v1/animal-breeds', [
            'species_id' => $references['species']->id,
            'code' => '  red sindhi ',
            'name' => '  Red   Sindhi ',
            'description' => 'Local cattle breed',
        ], $headers + ['Idempotency-Key' => 'breed-red-sindhi']);
        $this->assertSame(201, $created->status(), json_encode($created->json()));
        $breedId = $created->json('data.id');
        $this->assertSame('RED-SINDHI', $created->json('data.code'));
        $this->assertSame('Red   Sindhi', $created->json('data.name'));

        $updated = $this->patchJson('/api/v1/animal-breeds/'.$breedId, [
            'description' => 'Updated description',
            'version' => 1,
        ], $headers);
        $this->assertSame(200, $updated->status(), json_encode($updated->json()));
        $this->assertSame(2, $updated->json('data.version'));

        $archived = $this->deleteJson('/api/v1/animal-breeds/'.$breedId, ['version' => 2], $headers);
        $this->assertSame(200, $archived->status(), json_encode($archived->json()));
        $archived->assertJsonPath('data.is_archived', true);
        $this->assertSoftDeleted('animal_breeds', ['id' => $breedId]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'animal_breed.created', 'entity_id' => $breedId]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'animal_breed.updated', 'entity_id' => $breedId]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'animal_breed.archived', 'entity_id' => $breedId]);

        $foreign = Organization::create(['name' => 'Foreign Dairy']);
        $foreignBreed = AnimalBreed::create([
            'organization_id' => $foreign->id,
            'species_id' => $references['species']->id,
            'code' => 'FOREIGN',
            'name' => 'Foreign',
            'normalized_name' => 'foreign',
        ]);
        $this->getJson('/api/v1/animal-breeds/'.$foreignBreed->id, $headers)->assertNotFound();
    }

    public function test_group_lifecycle_rejects_cross_farm_sheds_and_does_not_archive_animals(): void
    {
        $data = $this->foundation($this->permissions);
        $references = $this->animalRegistryReferences($data);
        $otherFarm = Farm::create([
            'organization_id' => $data['organization']->id,
            'name' => 'South Farm',
            'code' => 'SOUTH',
            'timezone' => 'UTC',
        ]);
        $otherShed = Shed::create([
            'organization_id' => $data['organization']->id,
            'farm_id' => $otherFarm->id,
            'name' => 'South Shed',
            'code' => 'SOUTH',
        ]);
        $headers = $this->bearer($this->loginToken());

        $this->postJson('/api/v1/animal-groups', [
            'farm_id' => $data['farm']->id,
            'default_shed_id' => $otherShed->id,
            'code' => 'INVALID',
            'name' => 'Invalid Group',
        ], $headers)->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['default_shed_id']]]);

        $created = $this->postJson('/api/v1/animal-groups', [
            'farm_id' => $data['farm']->id,
            'default_shed_id' => $data['shed']->id,
            'code' => ' OBSERVATION ',
            'name' => ' Observation Group ',
        ], $headers + ['Idempotency-Key' => 'group-observation'])->assertCreated();
        $groupId = $created->json('data.id');
        $updated = $this->patchJson('/api/v1/animal-groups/'.$groupId, [
            'description' => 'Monitored animals',
            'version' => 1,
        ], $headers)->assertOk();
        $animal = $this->createAnimalModel($data, $references, ['current_animal_group_id' => $groupId]);

        $this->deleteJson('/api/v1/animal-groups/'.$groupId, ['version' => $updated->json('data.version')], $headers)->assertOk();
        $this->assertNotSoftDeleted('animals', ['id' => $animal->id]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'animal_group.archived', 'entity_id' => $groupId]);
    }

    public function test_animal_create_generates_consecutive_numbers_normalizes_identifiers_and_is_idempotent(): void
    {
        $data = $this->foundation($this->permissions);
        $references = $this->animalRegistryReferences($data);
        $headers = $this->bearer($this->loginToken());
        $payload = $this->animalPayload($data, $references, [
            'ear_tag_number' => ' gv / n - 001 ',
            'rfid_number' => 'ab-cd 1234',
        ]);

        $first = $this->postJson('/api/v1/animals', $payload, $headers + ['Idempotency-Key' => 'animal-create-1']);
        $this->assertSame(201, $first->status(), json_encode($first->json()));
        $replay = $this->postJson('/api/v1/animals', $payload, $headers + ['Idempotency-Key' => 'animal-create-1'])->assertCreated();
        $second = $this->postJson('/api/v1/animals', [
            ...$this->animalPayload($data, $references),
            'ear_tag_number' => 'GV-N-002',
            'rfid_number' => 'ABCD5678',
        ], $headers + ['Idempotency-Key' => 'animal-create-2'])->assertCreated();

        $this->assertSame('AN-000001', $first->json('data.animal_number'));
        $this->assertSame('AN-000002', $second->json('data.animal_number'));
        $this->assertSame('GV/N-001', $first->json('data.ear_tag_number'));
        $this->assertSame('ABCD1234', $first->json('data.rfid_number'));
        $this->assertSame($first->json('data.id'), $replay->json('data.id'));
        $this->assertDatabaseCount('animals', 2);
        $this->assertDatabaseHas('audit_logs', ['action' => 'animal.created', 'entity_id' => $first->json('data.id')]);
    }

    public function test_user_supplied_numbers_require_permission_and_identifier_uniqueness_is_per_tenant(): void
    {
        $data = $this->foundation(array_values(array_diff($this->permissions, ['animals.manage_identifiers'])));
        $references = $this->animalRegistryReferences($data);
        $headers = $this->bearer($this->loginToken());
        $this->postJson('/api/v1/animals', $this->animalPayload($data, $references, [
            'animal_number' => 'custom 001',
        ]), $headers)->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['animal_number']]]);

        $data['role']->permissions()->attach(Permission::firstOrCreate(['name' => 'animals.manage_identifiers'])->id);
        $created = $this->postJson('/api/v1/animals', $this->animalPayload($data, $references, [
            'animal_number' => 'custom 001',
            'ear_tag_number' => 'TAG-1',
            'rfid_number' => 'RFID1',
        ]), $headers)->assertCreated();
        $this->assertSame('CUSTOM-001', $created->json('data.animal_number'));

        foreach ([
            ['animal_number' => 'CUSTOM-001', 'ear_tag_number' => 'TAG-2', 'rfid_number' => 'RFID2', 'field' => 'animal_number'],
            ['animal_number' => 'CUSTOM-002', 'ear_tag_number' => 'TAG-1', 'rfid_number' => 'RFID3', 'field' => 'ear_tag_number'],
            ['animal_number' => 'CUSTOM-003', 'ear_tag_number' => 'TAG-3', 'rfid_number' => 'RFID1', 'field' => 'rfid_number'],
        ] as $case) {
            $field = $case['field'];
            unset($case['field']);
            $this->postJson('/api/v1/animals', $this->animalPayload($data, $references, $case), $headers)
                ->assertUnprocessable()
                ->assertJsonStructure(['error' => ['fields' => [$field]]]);
        }

        $foreign = $this->foreignRegistry($references['species']);
        $foreignAnimal = $this->createAnimalModel($foreign['foundation'], $foreign['references'], [
            'animal_number' => 'CUSTOM-001',
            'ear_tag_number' => 'TAG-1',
            'rfid_number' => 'RFID1',
        ]);
        $this->assertSame('CUSTOM-001', $foreignAnimal->animal_number);
    }

    public function test_classification_location_and_cross_tenant_references_are_rejected_without_exposure(): void
    {
        $data = $this->foundation($this->permissions, false);
        $references = $this->animalRegistryReferences($data);
        $headers = $this->bearer($this->loginToken());
        $foreign = $this->foreignRegistry($references['species']);

        $this->postJson('/api/v1/animals', $this->animalPayload($data, $references, [
            'breed_id' => $foreign['references']['breed']->id,
        ]), $headers)->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['breed_id']]]);

        $this->postJson('/api/v1/animals', $this->animalPayload($data, $references, [
            'current_farm_id' => $foreign['foundation']['farm']->id,
            'current_shed_id' => $foreign['foundation']['shed']->id,
        ]), $headers)->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['current_farm_id']]]);

        $otherFarm = Farm::create([
            'organization_id' => $data['organization']->id,
            'name' => 'Hidden Farm',
            'code' => 'HIDDEN',
            'timezone' => 'UTC',
        ]);
        $otherShed = Shed::create([
            'organization_id' => $data['organization']->id,
            'farm_id' => $otherFarm->id,
            'name' => 'Hidden Shed',
            'code' => 'HIDDEN',
        ]);
        $this->postJson('/api/v1/animals', $this->animalPayload($data, $references, [
            'current_farm_id' => $otherFarm->id,
            'current_shed_id' => $otherShed->id,
        ]), $headers)->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['current_farm_id']]]);
    }

    public function test_parentage_rules_reject_wrong_sex_age_self_cross_tenant_and_cycles(): void
    {
        $data = $this->foundation($this->permissions);
        $references = $this->animalRegistryReferences($data);
        $headers = $this->bearer($this->loginToken());
        $mother = $this->createAnimalModel($data, $references, ['animal_number' => 'AN-MOTHER', 'sex' => 'female', 'date_of_birth' => '2020-01-01']);
        $father = $this->createAnimalModel($data, $references, ['animal_number' => 'AN-FATHER', 'sex' => 'male', 'date_of_birth' => '2019-01-01']);
        $youngFemale = $this->createAnimalModel($data, $references, ['animal_number' => 'AN-YOUNG', 'sex' => 'female', 'date_of_birth' => '2025-01-01']);

        $this->postJson('/api/v1/animals', $this->animalPayload($data, $references, [
            'mother_animal_id' => $father->id,
        ]), $headers)->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['mother_animal_id']]]);
        $this->postJson('/api/v1/animals', $this->animalPayload($data, $references, [
            'father_animal_id' => $mother->id,
        ]), $headers)->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['father_animal_id']]]);
        $this->postJson('/api/v1/animals', $this->animalPayload($data, $references, [
            'mother_animal_id' => $youngFemale->id,
            'date_of_birth' => '2024-01-01',
        ]), $headers)->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['mother_animal_id']]]);

        $selfId = (string) Str::uuid7();
        $this->postJson('/api/v1/animals', $this->animalPayload($data, $references, [
            'id' => $selfId,
            'mother_animal_id' => $selfId,
        ]), $headers)->assertUnprocessable();

        $foreign = $this->foreignRegistry($references['species']);
        $foreignMother = $this->createAnimalModel($foreign['foundation'], $foreign['references'], ['animal_number' => 'FOREIGN-MOTHER', 'sex' => 'female']);
        $this->postJson('/api/v1/animals', $this->animalPayload($data, $references, [
            'mother_animal_id' => $foreignMother->id,
        ]), $headers)->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['mother_animal_id']]]);

        $child = $this->createAnimalModel($data, $references, [
            'animal_number' => 'AN-CHILD',
            'mother_animal_id' => $mother->id,
            'date_of_birth' => null,
        ]);
        $cycleResponse = $this->patchJson('/api/v1/animals/'.$mother->id, [
            'mother_animal_id' => $child->id,
            'version' => $mother->fresh()->version,
        ], $headers);
        $this->assertSame(422, $cycleResponse->status(), json_encode($cycleResponse->json()));
        $this->assertArrayHasKey('parentage', $cycleResponse->json('error.fields'), json_encode($cycleResponse->json()));
    }

    public function test_profile_update_blocks_location_changes_enforces_permissions_and_stale_versions(): void
    {
        $data = $this->foundation($this->permissions);
        $references = $this->animalRegistryReferences($data);
        $animal = $this->createAnimalModel($data, $references);
        $headers = $this->bearer($this->loginToken());

        $this->patchJson('/api/v1/animals/'.$animal->id, [
            'current_farm_id' => (string) Str::uuid7(),
            'current_shed_id' => (string) Str::uuid7(),
            'current_animal_group_id' => (string) Str::uuid7(),
            'version' => 1,
        ], $headers)->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => [
            'current_farm_id',
            'current_shed_id',
            'current_animal_group_id',
        ]]]);
        $this->assertDatabaseHas('animals', [
            'id' => $animal->id,
            'current_farm_id' => $data['farm']->id,
            'current_shed_id' => $data['shed']->id,
            'current_animal_group_id' => $references['group']->id,
        ]);

        $updated = $this->patchJson('/api/v1/animals/'.$animal->id, [
            'name' => 'Updated Name',
            'version' => 1,
        ], $headers)->assertOk();
        $this->assertSame(2, $updated->json('data.version'));
        $this->assertSame('active', $updated->json('data.operational_status'));
        $this->patchJson('/api/v1/animals/'.$animal->id, [
            'name' => 'Stale Name',
            'version' => 1,
        ], $headers)->assertStatus(412)->assertJsonPath('error.code', 'STALE_VERSION');

        $data['role']->permissions()->detach(Permission::where('name', 'animals.update')->value('id'));
        $this->patchJson('/api/v1/animals/'.$animal->id, [
            'name' => 'Forbidden',
            'version' => 2,
        ], $headers)->assertForbidden();
    }

    public function test_opaque_session_animal_policy_regression_covers_auth_permission_and_scope_boundaries(): void
    {
        $data = $this->foundation($this->permissions, false);
        $references = $this->animalRegistryReferences($data);
        $animal = $this->createAnimalModel($data, $references);
        $headers = $this->bearer($this->loginToken());

        $this->getJson('/api/v1/animals/'.$animal->id)->assertUnauthorized();
        $this->getJson('/api/v1/animals/'.$animal->id, $headers)
            ->assertOk()
            ->assertJsonPath('data.id', $animal->id);

        $viewPermission = Permission::where('name', 'animals.view')->firstOrFail();
        $data['role']->permissions()->detach($viewPermission->id);
        $this->getJson('/api/v1/animals/'.$animal->id, $headers)->assertForbidden();
        $data['role']->permissions()->attach($viewPermission->id);

        $foreign = $this->foreignRegistry($references['species']);
        $foreignAnimal = $this->createAnimalModel($foreign['foundation'], $foreign['references']);
        $this->getJson('/api/v1/animals/'.$foreignAnimal->id, $headers)->assertNotFound();

        $hiddenFarm = Farm::create([
            'organization_id' => $data['organization']->id,
            'name' => 'Policy Hidden Farm',
            'code' => 'POLICY-HIDDEN',
            'timezone' => 'UTC',
        ]);
        $hiddenShed = Shed::create([
            'organization_id' => $data['organization']->id,
            'farm_id' => $hiddenFarm->id,
            'name' => 'Policy Hidden Shed',
            'code' => 'POLICY-HIDDEN',
        ]);
        $hiddenAnimal = $this->createAnimalModel($data, $references, [
            'current_farm_id' => $hiddenFarm->id,
            'current_shed_id' => $hiddenShed->id,
            'current_animal_group_id' => null,
        ]);
        $this->getJson('/api/v1/animals/'.$hiddenAnimal->id, $headers)->assertNotFound();
    }

    public function test_archive_restore_search_filters_pagination_and_farm_scoping_work(): void
    {
        $data = $this->foundation($this->permissions, false);
        $references = $this->animalRegistryReferences($data);
        $female = $this->createAnimalModel($data, $references, ['animal_number' => 'AN-SEARCH-1', 'name' => 'Noor', 'sex' => 'female']);
        $this->createAnimalModel($data, $references, ['animal_number' => 'AN-SEARCH-2', 'name' => 'Sultan', 'sex' => 'male']);
        $headers = $this->bearer($this->loginToken());

        $list = $this->getJson('/api/v1/animals?filter[search]=Noor&filter[sex]=female&page[size]=1', $headers)->assertOk();
        $this->assertSame([$female->id], collect($list->json('data'))->pluck('id')->all());
        $this->assertSame(1, $list->json('meta.pagination.page_size'));

        $archived = $this->deleteJson('/api/v1/animals/'.$female->id, ['version' => 1], $headers)->assertOk();
        $this->assertTrue($archived->json('data.is_archived'));
        $restored = $this->postJson('/api/v1/animals/'.$female->id.'/restore', [
            'version' => $archived->json('data.version'),
        ], $headers)->assertOk();
        $this->assertFalse($restored->json('data.is_archived'));
        $this->assertDatabaseHas('audit_logs', ['action' => 'animal.restored', 'entity_id' => $female->id]);

        $hiddenFarm = Farm::create([
            'organization_id' => $data['organization']->id,
            'name' => 'Hidden',
            'code' => 'HIDDEN',
            'timezone' => 'UTC',
        ]);
        $hiddenShed = Shed::create([
            'organization_id' => $data['organization']->id,
            'farm_id' => $hiddenFarm->id,
            'name' => 'Hidden',
            'code' => 'HIDDEN',
        ]);
        $hiddenGroup = AnimalGroup::create([
            'organization_id' => $data['organization']->id,
            'farm_id' => $hiddenFarm->id,
            'default_shed_id' => $hiddenShed->id,
            'code' => 'HIDDEN',
            'name' => 'Hidden',
            'normalized_name' => 'hidden',
        ]);
        $hidden = $this->createAnimalModel($data, $references, [
            'animal_number' => 'AN-HIDDEN',
            'current_farm_id' => $hiddenFarm->id,
            'current_shed_id' => $hiddenShed->id,
            'current_animal_group_id' => $hiddenGroup->id,
        ]);
        $ids = collect($this->getJson('/api/v1/animals', $headers)->assertOk()->json('data'))->pluck('id');
        $this->assertFalse($ids->contains($hidden->id));
        $this->getJson('/api/v1/animals/'.$hidden->id, $headers)->assertNotFound();
    }

    public function test_sync_bootstrap_incremental_tombstones_and_reference_visibility_work(): void
    {
        $data = $this->foundation($this->permissions);
        $references = $this->animalRegistryReferences($data);
        $animal = $this->createAnimalModel($data, $references);
        $headers = $this->bearer($this->loginToken());

        $bootstrap = $this->getJson('/api/v1/sync/bootstrap', $headers)->assertOk();
        $this->assertCount(1, $bootstrap->json('data.animal_species'));
        $this->assertCount(1, $bootstrap->json('data.animal_breeds'));
        $this->assertCount(1, $bootstrap->json('data.animal_groups'));
        $this->assertCount(1, $bootstrap->json('data.animals'));

        $this->deleteJson('/api/v1/animals/'.$animal->id, ['version' => 1], $headers)->assertOk();
        $changes = $this->getJson('/api/v1/sync/changes?cursor='.urlencode($bootstrap->json('data.next_cursor')), $headers)->assertOk();
        $tombstone = collect($changes->json('data.animals'))->firstWhere('id', $animal->id);
        $this->assertTrue($tombstone['is_archived']);

        $data['role']->permissions()->detach();
        $withoutRegistryPermission = $this->getJson('/api/v1/sync/bootstrap', $headers)->assertOk();
        $this->assertCount(0, $withoutRegistryPermission->json('data.animal_species'));
        $this->assertCount(0, $withoutRegistryPermission->json('data.animal_breeds'));
        $this->assertCount(0, $withoutRegistryPermission->json('data.animal_groups'));
        $this->assertCount(0, $withoutRegistryPermission->json('data.animals'));
    }

    private function animalPayload(array $data, array $references, array $overrides = []): array
    {
        return [
            'species_id' => $references['species']->id,
            'breed_id' => $references['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'date_of_birth' => '2022-01-01',
            'current_farm_id' => $data['farm']->id,
            'current_shed_id' => $data['shed']->id,
            'current_animal_group_id' => $references['group']->id,
            'origin' => 'born_on_farm',
            ...$overrides,
        ];
    }

    private function createAnimalModel(array $data, array $references, array $overrides = []): Animal
    {
        static $counter = 100;
        $counter++;

        return Animal::create([
            'organization_id' => $data['organization']->id,
            'animal_number' => "AN-MODEL-{$counter}",
            'species_id' => $references['species']->id,
            'breed_id' => $references['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'date_of_birth' => '2021-01-01',
            'current_farm_id' => $data['farm']->id,
            'current_shed_id' => $data['shed']->id,
            'current_animal_group_id' => $references['group']->id,
            'origin' => 'born_on_farm',
            'operational_status' => 'active',
            'created_by' => $data['user']->id,
            'updated_by' => $data['user']->id,
            ...$overrides,
        ]);
    }

    private function foreignRegistry(AnimalSpecies $species): array
    {
        $organization = Organization::create(['name' => 'Foreign Dairy '.Str::random(8)]);
        $farm = Farm::create([
            'organization_id' => $organization->id,
            'name' => 'Foreign Farm',
            'code' => 'FOREIGN-'.Str::random(5),
            'timezone' => 'UTC',
        ]);
        $shed = Shed::create([
            'organization_id' => $organization->id,
            'farm_id' => $farm->id,
            'name' => 'Foreign Shed',
            'code' => 'FOREIGN-'.Str::random(5),
        ]);
        $user = User::factory()->create();
        $foundation = compact('organization', 'farm', 'shed', 'user');
        $breed = AnimalBreed::create([
            'organization_id' => $organization->id,
            'species_id' => $species->id,
            'code' => 'FOREIGN-'.Str::random(5),
            'name' => 'Foreign Breed',
            'normalized_name' => 'foreign breed '.Str::random(5),
        ]);
        $group = AnimalGroup::create([
            'organization_id' => $organization->id,
            'farm_id' => $farm->id,
            'default_shed_id' => $shed->id,
            'code' => 'FOREIGN-'.Str::random(5),
            'name' => 'Foreign Group',
            'normalized_name' => 'foreign group '.Str::random(5),
        ]);

        return ['foundation' => $foundation, 'references' => compact('species', 'breed', 'group')];
    }
}

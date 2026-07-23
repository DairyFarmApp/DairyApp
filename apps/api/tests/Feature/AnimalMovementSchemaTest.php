<?php

namespace Tests\Feature;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\Shed;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Ramsey\Uuid\Uuid;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class AnimalMovementSchemaTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_movement_schema_has_uuid7_indexes_foreign_keys_and_rejects_cross_tenant_destination(): void
    {
        $data = $this->foundation();
        $references = $this->animalRegistryReferences($data);
        $animal = Animal::create([
            'organization_id' => $data['organization']->id,
            'animal_number' => 'AN-MOVEMENT-SCHEMA',
            'species_id' => $references['species']->id,
            'breed_id' => $references['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'current_farm_id' => $data['farm']->id,
            'current_shed_id' => $data['shed']->id,
            'current_animal_group_id' => $references['group']->id,
            'origin' => 'other',
        ]);
        $id = (string) Str::uuid7();
        $this->assertTrue(Schema::hasTable('animal_movements'));
        $this->assertContains(
            'animal_movements_org_animal_status_index',
            Schema::getIndexListing('animal_movements'),
        );
        $this->assertNotEmpty(Schema::getForeignKeys('animal_movements'));
        $this->assertSame(7, Uuid::fromString($id)->getVersion());

        $foreignOrganization = Organization::create(['name' => 'Foreign Movement Dairy']);
        $foreignFarm = Farm::create([
            'organization_id' => $foreignOrganization->id,
            'name' => 'Foreign Farm',
            'code' => 'FOREIGN-MOVE',
            'timezone' => 'UTC',
        ]);
        $foreignShed = Shed::create([
            'organization_id' => $foreignOrganization->id,
            'farm_id' => $foreignFarm->id,
            'name' => 'Foreign Shed',
            'code' => 'FOREIGN-MOVE',
        ]);

        try {
            DB::table('animal_movements')->insert([
                'id' => $id,
                'organization_id' => $data['organization']->id,
                'animal_id' => $animal->id,
                'source_farm_id' => $data['farm']->id,
                'source_shed_id' => $data['shed']->id,
                'source_animal_group_id' => $references['group']->id,
                'destination_farm_id' => $foreignFarm->id,
                'destination_shed_id' => $foreignShed->id,
                'requested_effective_at' => now(),
                'reason' => 'Invalid cross-tenant movement',
                'status' => 'pending',
                'approval_required' => true,
                'requested_by' => $data['user']->id,
                'version' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $this->fail('A cross-tenant movement unexpectedly passed database constraints.');
        } catch (QueryException) {
            $this->assertTrue(true);
        }
    }
}

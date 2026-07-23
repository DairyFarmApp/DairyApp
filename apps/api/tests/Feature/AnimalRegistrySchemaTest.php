<?php

namespace Tests\Feature;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalBreed;
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

class AnimalRegistrySchemaTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_animal_registry_schema_has_required_tables_keys_indexes_and_uuid7(): void
    {
        $data = $this->foundation();
        $references = $this->animalRegistryReferences($data);
        $animal = Animal::create([
            'organization_id' => $data['organization']->id,
            'animal_number' => 'AN-000001',
            'species_id' => $references['species']->id,
            'breed_id' => $references['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'current_farm_id' => $data['farm']->id,
            'current_shed_id' => $data['shed']->id,
            'current_animal_group_id' => $references['group']->id,
            'origin' => 'born_on_farm',
        ]);

        foreach (['animal_species', 'animal_breeds', 'animal_groups', 'animals', 'organization_sequences'] as $table) {
            $this->assertTrue(Schema::hasTable($table));
        }
        $this->assertSame(7, Uuid::fromString($animal->id)->getVersion());
        $this->assertContains('animals_org_number_unique', Schema::getIndexListing('animals'));
        $this->assertContains('animals_org_ear_tag_unique', Schema::getIndexListing('animals'));
        $this->assertContains('animals_org_rfid_unique', Schema::getIndexListing('animals'));
        $this->assertNotEmpty(Schema::getForeignKeys('animals'));
        $this->assertNotEmpty(Schema::getForeignKeys('animal_groups'));
    }

    public function test_database_rejects_cross_tenant_relationships_and_duplicate_identifiers(): void
    {
        $data = $this->foundation();
        $references = $this->animalRegistryReferences($data);
        $foreignOrganization = Organization::create(['name' => 'Foreign Dairy']);
        $foreignFarm = Farm::create([
            'organization_id' => $foreignOrganization->id,
            'name' => 'Foreign Farm',
            'code' => 'FOREIGN',
            'timezone' => 'UTC',
        ]);
        $foreignShed = Shed::create([
            'organization_id' => $foreignOrganization->id,
            'farm_id' => $foreignFarm->id,
            'name' => 'Foreign Shed',
            'code' => 'FOREIGN',
        ]);
        $foreignBreed = AnimalBreed::create([
            'organization_id' => $foreignOrganization->id,
            'species_id' => $references['species']->id,
            'code' => 'FOREIGN',
            'name' => 'Foreign',
            'normalized_name' => 'foreign',
        ]);

        foreach ([
            [
                'id' => (string) Str::uuid7(),
                'organization_id' => $data['organization']->id,
                'animal_number' => 'AN-CROSS-BREED',
                'species_id' => $references['species']->id,
                'breed_id' => $foreignBreed->id,
                'sex' => 'female',
                'life_stage' => 'adult',
                'current_farm_id' => $data['farm']->id,
                'current_shed_id' => $data['shed']->id,
                'origin' => 'other',
                'operational_status' => 'active',
                'version' => 1,
            ],
            [
                'id' => (string) Str::uuid7(),
                'organization_id' => $data['organization']->id,
                'animal_number' => 'AN-CROSS-LOCATION',
                'species_id' => $references['species']->id,
                'breed_id' => $references['breed']->id,
                'sex' => 'female',
                'life_stage' => 'adult',
                'current_farm_id' => $foreignFarm->id,
                'current_shed_id' => $foreignShed->id,
                'origin' => 'other',
                'operational_status' => 'active',
                'version' => 1,
            ],
        ] as $values) {
            try {
                DB::table('animals')->insert($values);
                $this->fail('A cross-tenant animal row unexpectedly succeeded.');
            } catch (QueryException) {
                $this->assertTrue(true);
            }
        }

        $base = [
            'organization_id' => $data['organization']->id,
            'species_id' => $references['species']->id,
            'breed_id' => $references['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'current_farm_id' => $data['farm']->id,
            'current_shed_id' => $data['shed']->id,
            'origin' => 'other',
            'operational_status' => 'active',
            'version' => 1,
        ];
        DB::table('animals')->insert([
            ...$base,
            'id' => (string) Str::uuid7(),
            'animal_number' => 'AN-UNIQUE',
            'ear_tag_number' => 'TAG-UNIQUE',
            'rfid_number' => 'RFIDUNIQUE',
        ]);
        foreach ([
            ['animal_number' => 'AN-UNIQUE', 'ear_tag_number' => 'TAG-2', 'rfid_number' => 'RFID2'],
            ['animal_number' => 'AN-2', 'ear_tag_number' => 'TAG-UNIQUE', 'rfid_number' => 'RFID3'],
            ['animal_number' => 'AN-3', 'ear_tag_number' => 'TAG-3', 'rfid_number' => 'RFIDUNIQUE'],
        ] as $identifiers) {
            try {
                DB::table('animals')->insert([
                    ...$base,
                    ...$identifiers,
                    'id' => (string) Str::uuid7(),
                ]);
                $this->fail('A duplicate animal identifier unexpectedly succeeded.');
            } catch (QueryException) {
                $this->assertTrue(true);
            }
        }
    }
}

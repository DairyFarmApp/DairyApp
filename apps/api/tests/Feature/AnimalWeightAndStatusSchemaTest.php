<?php

namespace Tests\Feature;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalStatuses\Models\AnimalStatusChange;
use App\Domain\AnimalWeights\Models\AnimalWeight;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\Shed;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Ramsey\Uuid\Uuid;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class AnimalWeightAndStatusSchemaTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_weight_and_status_schema_has_decimal_uuid_indexes_and_foreign_keys(): void
    {
        $data = $this->foundation();
        $references = $this->animalRegistryReferences($data);
        $animal = $this->animal($data, $references);
        $weight = AnimalWeight::create([
            'organization_id' => $data['organization']->id,
            'farm_id' => $data['farm']->id,
            'animal_id' => $animal->id,
            'entered_value' => '450.125000',
            'entered_unit' => 'kg',
            'normalized_kg' => '450.125000',
            'observed_at' => now()->subHour(),
            'source' => 'scale',
            'recorded_by' => $data['user']->id,
        ]);
        $status = AnimalStatusChange::create([
            'organization_id' => $data['organization']->id,
            'farm_id' => $data['farm']->id,
            'animal_id' => $animal->id,
            'previous_status' => 'active',
            'new_status' => 'inactive',
            'effective_at' => now()->subHour(),
            'reason' => 'Schema test transition.',
            'changed_by' => $data['user']->id,
            'sequence' => 1,
        ]);

        $this->assertTrue(Schema::hasTable('animal_weights'));
        $this->assertTrue(Schema::hasTable('animal_status_histories'));
        $this->assertContains(
            Schema::getColumnType('animal_weights', 'entered_value'),
            ['decimal', 'numeric'],
        );
        $this->assertContains(
            Schema::getColumnType('animal_weights', 'normalized_kg'),
            ['decimal', 'numeric'],
        );
        $this->assertContains('animal_weights_org_animal_latest_index', Schema::getIndexListing('animal_weights'));
        $this->assertContains(
            'animal_status_histories_org_animal_effective_index',
            Schema::getIndexListing('animal_status_histories'),
        );
        $this->assertNotEmpty(Schema::getForeignKeys('animal_weights'));
        $this->assertNotEmpty(Schema::getForeignKeys('animal_status_histories'));
        $this->assertSame(7, Uuid::fromString($weight->id)->getVersion());
        $this->assertSame(7, Uuid::fromString($status->id)->getVersion());
    }

    public function test_composite_constraints_reject_cross_tenant_farm_and_animal_links(): void
    {
        $data = $this->foundation();
        $references = $this->animalRegistryReferences($data);
        $animal = $this->animal($data, $references);
        $foreignOrganization = Organization::create(['name' => 'Foreign measurement dairy']);
        $foreignFarm = Farm::create([
            'organization_id' => $foreignOrganization->id,
            'name' => 'Foreign Farm',
            'code' => 'FOREIGN-MEASURE',
            'timezone' => 'UTC',
        ]);
        Shed::create([
            'organization_id' => $foreignOrganization->id,
            'farm_id' => $foreignFarm->id,
            'name' => 'Foreign Shed',
            'code' => 'FOREIGN-MEASURE',
        ]);

        foreach (['animal_weights', 'animal_status_histories'] as $table) {
            try {
                $common = [
                    'id' => fake()->uuid(),
                    'organization_id' => $data['organization']->id,
                    'farm_id' => $foreignFarm->id,
                    'animal_id' => $animal->id,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
                DB::table($table)->insert($table === 'animal_weights'
                    ? [
                        ...$common,
                        'entered_value' => '100.000000',
                        'entered_unit' => 'kg',
                        'normalized_kg' => '100.000000',
                        'observed_at' => now(),
                        'source' => 'manual',
                        'recorded_by' => $data['user']->id,
                        'is_superseded' => false,
                    ]
                    : [
                        ...$common,
                        'previous_status' => 'active',
                        'new_status' => 'missing',
                        'effective_at' => now(),
                        'reason' => 'Invalid tenant context.',
                        'changed_by' => $data['user']->id,
                        'sequence' => 1,
                    ]);
                $this->fail("A cross-tenant {$table} row unexpectedly passed database constraints.");
            } catch (QueryException) {
                $this->assertTrue(true);
            }
        }
    }

    private function animal(array $data, array $references): Animal
    {
        return Animal::create([
            'organization_id' => $data['organization']->id,
            'animal_number' => 'AN-WEIGHT-SCHEMA',
            'species_id' => $references['species']->id,
            'breed_id' => $references['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'current_farm_id' => $data['farm']->id,
            'current_shed_id' => $data['shed']->id,
            'current_animal_group_id' => $references['group']->id,
            'origin' => 'other',
        ]);
    }
}

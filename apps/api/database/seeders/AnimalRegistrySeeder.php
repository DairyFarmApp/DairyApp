<?php

namespace Database\Seeders;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Domain\AnimalRegistry\Models\AnimalSpecies;
use App\Domain\AnimalRegistry\Support\AnimalRegistryNormalizer;
use App\Domain\AnimalStatuses\Models\AnimalStatusChange;
use App\Domain\AnimalWeights\Models\AnimalWeight;
use App\Domain\AnimalWeights\Support\AnimalWeightConverter;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\Shed;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AnimalRegistrySeeder extends Seeder
{
    public function run(): void
    {
        $organization = Organization::query()->where('name', 'Green Valley Dairy Cooperative')->firstOrFail();
        $actor = User::query()->where('email', 'owner@dairycare.local')->firstOrFail();
        $normalizer = app(AnimalRegistryNormalizer::class);

        DB::transaction(function () use ($organization, $actor, $normalizer): void {
            $species = collect([
                'CATTLE' => 'Cattle',
                'BUFFALO' => 'Buffalo',
            ])->mapWithKeys(function (string $name, string $code) {
                $model = AnimalSpecies::query()->updateOrCreate(
                    ['code' => $code],
                    ['name' => $name, 'is_active' => true],
                );

                return [$code => $model];
            });

            $breedDefinitions = [
                ['CATTLE', 'HOLSTEIN-FRIESIAN', 'Holstein Friesian'],
                ['CATTLE', 'JERSEY', 'Jersey'],
                ['CATTLE', 'SAHIWAL', 'Sahiwal'],
                ['CATTLE', 'RED-SINDHI', 'Red Sindhi'],
                ['BUFFALO', 'NILI-RAVI', 'Nili-Ravi'],
                ['BUFFALO', 'KUNDI', 'Kundi'],
            ];
            $breeds = collect($breedDefinitions)->mapWithKeys(function (array $definition) use ($organization, $actor, $normalizer, $species) {
                [$speciesCode, $code, $name] = $definition;
                $model = AnimalBreed::withTrashed()->updateOrCreate(
                    [
                        'organization_id' => $organization->id,
                        'species_id' => $species[$speciesCode]->id,
                        'code' => $code,
                    ],
                    [
                        'name' => $name,
                        'normalized_name' => $normalizer->name($name),
                        'description' => "Development reference breed: {$name}.",
                        'is_active' => true,
                        'created_by' => $actor->id,
                        'updated_by' => $actor->id,
                    ],
                );

                return [$code => $model];
            });

            $north = Farm::query()->where('organization_id', $organization->id)->where('code', 'NORTH')->firstOrFail();
            $riverside = Farm::query()->where('organization_id', $organization->id)->where('code', 'RIVER')->firstOrFail();
            $sheds = Shed::query()->where('organization_id', $organization->id)->get()->keyBy('code');
            $groupDefinitions = [
                [$north, $sheds['N-LACT'], 'MAIN-HERD', 'Main Herd'],
                [$north, $sheds['N-CALF'], 'YOUNG-STOCK', 'Young Stock'],
                [$riverside, $sheds['R-MAIN'], 'NEW-ARRIVALS', 'New Arrivals'],
                [$riverside, $sheds['R-QUAR'], 'OBSERVATION', 'Observation Group'],
            ];
            $groups = collect($groupDefinitions)->mapWithKeys(function (array $definition) use ($organization, $actor, $normalizer) {
                [$farm, $shed, $code, $name] = $definition;
                $model = AnimalGroup::withTrashed()->updateOrCreate(
                    ['organization_id' => $organization->id, 'farm_id' => $farm->id, 'code' => $code],
                    [
                        'default_shed_id' => $shed->id,
                        'name' => $name,
                        'normalized_name' => $normalizer->name($name),
                        'description' => "Development group for {$name}.",
                        'is_active' => true,
                        'created_by' => $actor->id,
                        'updated_by' => $actor->id,
                    ],
                );

                return [$code => $model];
            });

            $records = [
                ['AN-000001', 'GV-N-001', 'PK840001', 'Noor', 'CATTLE', 'HOLSTEIN-FRIESIAN', 'female', 'adult', '2020-02-12', $north, $sheds['N-LACT'], $groups['MAIN-HERD'], null, null, 'born_on_farm', 'active'],
                ['AN-000002', 'GV-N-002', 'PK840002', 'Sultan', 'CATTLE', 'SAHIWAL', 'male', 'adult', '2019-01-08', $north, $sheds['N-LACT'], $groups['MAIN-HERD'], null, null, 'purchased', 'active'],
                ['AN-000003', 'GV-N-003', 'PK840003', 'Chandni', 'CATTLE', 'JERSEY', 'female', 'adult', '2021-03-18', $north, $sheds['N-LACT'], $groups['MAIN-HERD'], null, null, 'purchased', 'active'],
                ['AN-000004', 'GV-N-004', 'PK840004', 'Badal', 'CATTLE', 'HOLSTEIN-FRIESIAN', 'male', 'adult', '2020-05-20', $north, $sheds['N-LACT'], $groups['MAIN-HERD'], null, null, 'transferred_in', 'inactive'],
                ['AN-000005', 'GV-R-001', 'PK850001', 'Rani', 'BUFFALO', 'NILI-RAVI', 'female', 'adult', '2018-08-10', $riverside, $sheds['R-MAIN'], $groups['NEW-ARRIVALS'], null, null, 'purchased', 'active'],
                ['AN-000006', 'GV-R-002', 'PK850002', 'Shera', 'BUFFALO', 'NILI-RAVI', 'male', 'adult', '2017-06-11', $riverside, $sheds['R-MAIN'], $groups['NEW-ARRIVALS'], null, null, 'purchased', 'active'],
                ['AN-000007', 'GV-R-003', 'PK850003', 'Kali', 'BUFFALO', 'KUNDI', 'female', 'adult', '2020-10-09', $riverside, $sheds['R-MAIN'], $groups['NEW-ARRIVALS'], null, null, 'transferred_in', 'active'],
                ['AN-000008', 'GV-R-004', 'PK850004', 'Raja', 'BUFFALO', 'KUNDI', 'male', 'adult', '2019-09-14', $riverside, $sheds['R-MAIN'], $groups['NEW-ARRIVALS'], null, null, 'purchased', 'active'],
                ['AN-000009', 'GV-N-005', 'PK840005', 'Gulabo', 'CATTLE', 'RED-SINDHI', 'female', 'adult', '2020-11-04', $north, $sheds['N-LACT'], $groups['MAIN-HERD'], null, null, 'purchased', 'missing'],
                ['AN-000010', 'GV-N-006', 'PK840006', 'Mehak', 'CATTLE', 'SAHIWAL', 'female', 'adult', '2021-01-22', $north, $sheds['N-LACT'], $groups['MAIN-HERD'], null, null, 'born_on_farm', 'active'],
                ['AN-000011', 'GV-N-011', 'PK841011', 'Sitara', 'CATTLE', 'HOLSTEIN-FRIESIAN', 'female', 'juvenile', '2023-02-01', $north, $sheds['N-CALF'], $groups['YOUNG-STOCK'], 'AN-000001', 'AN-000004', 'born_on_farm', 'active'],
                ['AN-000012', 'GV-N-012', 'PK841012', 'Roshan', 'CATTLE', 'SAHIWAL', 'male', 'juvenile', '2023-04-15', $north, $sheds['N-CALF'], $groups['YOUNG-STOCK'], 'AN-000010', 'AN-000002', 'born_on_farm', 'active'],
                ['AN-000013', 'GV-R-013', 'PK851013', 'Heer', 'BUFFALO', 'NILI-RAVI', 'female', 'juvenile', '2023-03-12', $riverside, $sheds['R-QUAR'], $groups['OBSERVATION'], 'AN-000005', 'AN-000006', 'born_on_farm', 'active'],
                ['AN-000014', 'GV-R-014', 'PK851014', 'Moti', 'BUFFALO', 'KUNDI', 'male', 'juvenile', '2023-07-07', $riverside, $sheds['R-QUAR'], $groups['OBSERVATION'], 'AN-000007', 'AN-000008', 'born_on_farm', 'inactive'],
                ['AN-000015', 'GV-N-015', 'PK842015', 'Ujala', 'CATTLE', 'HOLSTEIN-FRIESIAN', 'female', 'calf', '2025-10-01', $north, $sheds['N-CALF'], $groups['YOUNG-STOCK'], 'AN-000001', 'AN-000004', 'born_on_farm', 'active'],
                ['AN-000016', 'GV-N-016', 'PK842016', 'Jugnu', 'CATTLE', 'JERSEY', 'male', 'calf', '2025-11-09', $north, $sheds['N-CALF'], $groups['YOUNG-STOCK'], 'AN-000003', 'AN-000002', 'born_on_farm', 'active'],
                ['AN-000017', 'GV-N-017', 'PK842017', 'Sona', 'CATTLE', 'RED-SINDHI', 'female', 'calf', '2026-01-14', $north, $sheds['N-CALF'], $groups['YOUNG-STOCK'], 'AN-000009', 'AN-000002', 'born_on_farm', 'active'],
                ['AN-000018', 'GV-R-018', 'PK852018', 'Neeli', 'BUFFALO', 'NILI-RAVI', 'female', 'calf', '2025-12-22', $riverside, $sheds['R-QUAR'], $groups['OBSERVATION'], 'AN-000005', 'AN-000006', 'born_on_farm', 'active'],
                ['AN-000019', 'GV-R-019', 'PK852019', 'Kaalu', 'BUFFALO', 'KUNDI', 'male', 'calf', '2026-02-05', $riverside, $sheds['R-QUAR'], $groups['OBSERVATION'], 'AN-000007', 'AN-000008', 'born_on_farm', 'missing'],
                ['AN-000020', 'GV-R-020', 'PK852020', 'Chameli', 'BUFFALO', 'NILI-RAVI', 'female', 'calf', '2026-03-17', $riverside, $sheds['R-QUAR'], $groups['OBSERVATION'], 'AN-000005', 'AN-000006', 'born_on_farm', 'active'],
            ];

            $animals = [];
            foreach ($records as $record) {
                [$number, $earTag, $rfid, $name, $speciesCode, $breedCode, $sex, $lifeStage, $dateOfBirth, $farm, $shed, $group, $motherNumber, $fatherNumber, $origin, $status] = $record;
                $animal = Animal::withTrashed()->updateOrCreate(
                    ['organization_id' => $organization->id, 'animal_number' => $number],
                    [
                        'ear_tag_number' => $earTag,
                        'rfid_number' => $rfid,
                        'name' => $name,
                        'species_id' => $species[$speciesCode]->id,
                        'breed_id' => $breeds[$breedCode]->id,
                        'sex' => $sex,
                        'life_stage' => $lifeStage,
                        'date_of_birth' => $dateOfBirth,
                        'is_date_of_birth_estimated' => false,
                        'colour' => $speciesCode === 'BUFFALO' ? 'Black' : 'Brown and white',
                        'current_farm_id' => $farm->id,
                        'current_shed_id' => $shed->id,
                        'current_animal_group_id' => $group->id,
                        'mother_animal_id' => $motherNumber ? $animals[$motherNumber]->id : null,
                        'father_animal_id' => $fatherNumber ? $animals[$fatherNumber]->id : null,
                        'origin' => $origin,
                        'operational_status' => $status,
                        'created_by' => $actor->id,
                        'updated_by' => $actor->id,
                    ],
                );
                $animals[$number] = $animal;
            }

            DB::table('organization_sequences')->updateOrInsert(
                ['organization_id' => $organization->id, 'sequence_key' => 'animal_number'],
                ['next_value' => 21, 'created_at' => now(), 'updated_at' => now()],
            );

            $weightConverter = app(AnimalWeightConverter::class);
            foreach ([
                ['AN-000001', '2026-05-15 06:30:00', '498.250000', 'kg', 'scale', 'Morning platform scale.'],
                ['AN-000001', '2026-06-15 06:35:00', '507.800000', 'kg', 'scale', null],
                ['AN-000003', '2026-06-10 07:00:00', '915.000000', 'lb', 'manual', 'Handheld scale entry.'],
                ['AN-000005', '2026-06-20 08:15:00', '612.400000', 'kg', 'scale', null],
            ] as [$animalNumber, $observedAt, $value, $unit, $source, $notes]) {
                $animal = $animals[$animalNumber];
                AnimalWeight::query()->updateOrCreate(
                    [
                        'organization_id' => $organization->id,
                        'animal_id' => $animal->id,
                        'observed_at' => $observedAt,
                    ],
                    [
                        'farm_id' => $animal->current_farm_id,
                        'entered_value' => $value,
                        'entered_unit' => $unit,
                        'normalized_kg' => $weightConverter->normalize($value, $unit),
                        'source' => $source,
                        'notes' => $notes,
                        'recorded_by' => $actor->id,
                    ],
                );
            }
            $incorrectWeight = AnimalWeight::query()->updateOrCreate(
                [
                    'organization_id' => $organization->id,
                    'animal_id' => $animals['AN-000001']->id,
                    'observed_at' => '2026-07-10 06:40:00',
                ],
                [
                    'farm_id' => $animals['AN-000001']->current_farm_id,
                    'entered_value' => '1100.000000',
                    'entered_unit' => 'lb',
                    'normalized_kg' => $weightConverter->normalize('1100.000000', 'lb'),
                    'source' => 'manual',
                    'notes' => 'Original entry later found to contain a transposition.',
                    'recorded_by' => $actor->id,
                ],
            );
            $correctedWeight = AnimalWeight::query()->updateOrCreate(
                ['supersedes_weight_id' => $incorrectWeight->id],
                [
                    'organization_id' => $organization->id,
                    'farm_id' => $incorrectWeight->farm_id,
                    'animal_id' => $incorrectWeight->animal_id,
                    'entered_value' => '1120.000000',
                    'entered_unit' => 'lb',
                    'normalized_kg' => $weightConverter->normalize('1120.000000', 'lb'),
                    'observed_at' => $incorrectWeight->observed_at,
                    'source' => $incorrectWeight->source,
                    'notes' => 'Verified against the paper scale log.',
                    'recorded_by' => $actor->id,
                    'correction_reason' => 'Original pounds value was transposed during entry.',
                ],
            );
            $incorrectWeight->forceFill([
                'is_superseded' => true,
                'superseded_by_weight_id' => $correctedWeight->id,
            ])->save();

            foreach ([
                ['AN-000004', 1, 'active', 'inactive', '2026-05-01 09:00:00', 'Temporarily removed from operational herd work.'],
                ['AN-000009', 1, 'active', 'missing', '2026-06-12 18:30:00', 'Animal was not located during evening headcount.'],
                ['AN-000010', 1, 'active', 'inactive', '2026-05-20 08:00:00', 'Held inactive for administrative review.'],
                ['AN-000010', 2, 'inactive', 'active', '2026-05-22 08:00:00', 'Administrative review completed and animal restored to active status.'],
                ['AN-000014', 1, 'active', 'inactive', '2026-06-01 10:00:00', 'Temporarily inactive during observation.'],
                ['AN-000019', 1, 'active', 'missing', '2026-07-01 19:00:00', 'Missing from the assigned observation group.'],
            ] as [$animalNumber, $sequence, $previous, $new, $effectiveAt, $reason]) {
                $animal = $animals[$animalNumber];
                AnimalStatusChange::query()->updateOrCreate(
                    [
                        'organization_id' => $organization->id,
                        'animal_id' => $animal->id,
                        'sequence' => $sequence,
                    ],
                    [
                        'farm_id' => $animal->current_farm_id,
                        'previous_status' => $previous,
                        'new_status' => $new,
                        'effective_at' => $effectiveAt,
                        'reason' => $reason,
                        'changed_by' => $actor->id,
                    ],
                );
            }
        });
    }
}

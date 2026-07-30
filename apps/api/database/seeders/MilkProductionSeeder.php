<?php

namespace Database\Seeders;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\MilkProduction\Models\MilkEntry;
use App\Domain\MilkProduction\Models\MilkProductionSlot;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MilkProductionSeeder extends Seeder
{
    public function run(): void
    {
        $organization = Organization::query()
            ->where('name', 'Green Valley Dairy Cooperative')
            ->firstOrFail();
        $actor = User::query()->where('email', 'owner@dairycare.local')->firstOrFail();
        $animals = Animal::query()
            ->where('organization_id', $organization->id)
            ->where('sex', 'female')
            ->where('life_stage', 'adult')
            ->where('operational_status', 'active')
            ->orderBy('animal_number')
            ->get();

        DB::transaction(function () use ($organization, $actor, $animals): void {
            foreach (range(0, 29) as $daysAgo) {
                $date = today()->subDays($daysAgo);
                foreach ($animals as $animalIndex => $animal) {
                    foreach (['morning', 'evening'] as $sessionIndex => $session) {
                        $slot = MilkProductionSlot::query()->firstOrCreate(
                            [
                                'organization_id' => $organization->id,
                                'animal_id' => $animal->id,
                                'production_date' => $date->toDateString(),
                                'session' => $session,
                            ],
                            [
                                'farm_id' => $animal->current_farm_id,
                                'shed_id' => $animal->current_shed_id,
                                'version' => 1,
                                'created_by' => $actor->id,
                            ],
                        );
                        $quantity = 7.5
                            + ($animalIndex * 0.85)
                            + ($sessionIndex === 0 ? 2.25 : 0)
                            + (($daysAgo % 5) * 0.12);
                        $rejected = ($daysAgo + $animalIndex + $sessionIndex) % 17 === 0
                            ? 0.5
                            : 0.0;
                        MilkEntry::query()->firstOrCreate(
                            [
                                'milk_production_slot_id' => $slot->id,
                                'revision' => 1,
                            ],
                            [
                                'organization_id' => $organization->id,
                                'farm_id' => $animal->current_farm_id,
                                'animal_id' => $animal->id,
                                'quantity_litres' => number_format($quantity, 3, '.', ''),
                                'rejected_quantity_litres' => number_format($rejected, 3, '.', ''),
                                'rejection_reason' => $rejected > 0
                                    ? 'Development quality-control sample.'
                                    : null,
                                'notes' => 'Realistic development milk history.',
                                'entry_source' => 'manual',
                                'is_current' => true,
                                'recorded_by' => $actor->id,
                            ],
                        );
                    }
                }
            }
        });
    }
}

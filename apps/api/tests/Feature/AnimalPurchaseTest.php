<?php

namespace Tests\Feature;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\Finance\Models\ExpenseRecord;
use App\Domain\Finance\Models\IncomeRecord;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class AnimalPurchaseTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_purchase_uses_sequential_animal_number_and_requires_photos_for_operations(): void
    {
        $foundation = $this->foundation(['animals.view', 'animals.create', 'animals.update']);
        $references = $this->animalRegistryReferences($foundation);
        $headers = $this->bearer($this->loginToken());
        $payload = [
            'purchase_date' => now()->toDateString(),
            'purchase_price' => 100000,
            'transportation_cost' => 5000,
            'veterinary_cost' => 2000,
            'species_id' => $references['species']->id,
            'breed_id' => $references['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'shed_id' => $foundation['shed']->id,
        ];

        $first = $this->postJson('/api/v1/animal-purchases', $payload, $headers)
            ->assertCreated()
            ->assertJsonPath('data.animal_number', 'AN-000001');
        $second = $this->postJson('/api/v1/animal-purchases', $payload, $headers)
            ->assertCreated()
            ->assertJsonPath('data.animal_number', 'AN-000002');

        $animal = Animal::query()->findOrFail($first->json('data.animal_id'));
        $this->assertFalse($animal->photo_requirement_exempt);
        $this->assertFalse($animal->hasRequiredPhotos());
        $this->assertDatabaseCount('expense_records', 2);
        $expense = ExpenseRecord::query()->firstOrFail();
        $this->assertSame('107000.00', $expense->amount);
        $this->assertNotNull($expense->journal_entry_id);

        $this->postJson('/api/v1/animal-sales', [
            'animal_id' => $animal->id,
            'sale_date' => now()->toDateString(),
            'sale_price' => 125000,
            'commission' => 3000,
            'transportation_cost' => 2000,
        ], $headers)->assertCreated();
        $this->assertSame('sold', $animal->fresh()->operational_status);
        $this->assertSame(2, $animal->fresh()->version);
        $income = IncomeRecord::query()->sole();
        $this->assertSame('120000.00', $income->amount);
        $this->assertNotNull($income->journal_entry_id);
        $activeIds = collect(
            $this->getJson(
                '/api/v1/animals?filter[operational_status]=active',
                $headers,
            )->assertOk()->json('data'),
        )->pluck('id');
        $this->assertFalse($activeIds->contains($animal->id));
        $this->assertTrue($activeIds->contains($second->json('data.animal_id')));
        $this->getJson('/api/v1/animals/'.$animal->id, $headers)
            ->assertOk()
            ->assertJsonPath('data.operational_status', 'sold');
        $this->getJson('/api/v1/animal-sales', $headers)
            ->assertOk()
            ->assertJsonPath('meta.pagination.total', 1);

        $this->postJson(
            '/api/v1/animal-purchases',
            [...$payload, 'animal_number' => 'MANUAL-1'],
            $headers,
        )->assertUnprocessable()->assertJsonStructure(['error' => ['fields' => ['animal_number']]]);
    }
}

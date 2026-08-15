<?php

namespace Tests\Feature;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\Inventory\Models\InventoryBatch;
use App\Domain\Inventory\Models\InventoryItem;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class FeedManagementTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_ration_plan_and_daily_issue_use_the_active_farm_end_to_end(): void
    {
        $foundation = $this->foundation(['inventory.view', 'inventory.manage']);
        $references = $this->animalRegistryReferences($foundation);
        $headers = $this->bearer($this->loginToken());
        $item = InventoryItem::query()->create([
            'organization_id' => $foundation['organization']->id,
            'farm_id' => $foundation['farm']->id,
            'kind' => 'feed',
            'item_code' => 'FEED-001',
            'name' => 'Lactation concentrate',
            'category' => 'Concentrate',
            'unit' => 'kg',
            'minimum_stock' => '10.000',
            'is_active' => true,
            'created_by' => $foundation['user']->id,
            'updated_by' => $foundation['user']->id,
        ]);
        InventoryBatch::query()->create(['organization_id' => $item->organization_id, 'farm_id' => $item->farm_id, 'inventory_item_id' => $item->id, 'batch_number' => 'FEED-ISSUE-B1', 'expiry_date' => today()->addYear(), 'unit_cost' => 100, 'current_quantity' => 100]);

        $plan = $this->postJson('/api/v1/feed-ration-plans', [
            'name' => 'Morning lactation ration',
            'animal_group_id' => $references['group']->id,
            'production_stage' => 'lactating',
            'effective_date' => today()->toDateString(),
            'feeding_frequency' => 2,
            'ingredients' => [[
                'inventory_item_id' => $item->id,
                'quantity_per_animal' => '4.500',
                'unit' => 'kg',
            ]],
        ], [...$headers, 'Idempotency-Key' => (string) Str::uuid()])
            ->assertCreated()
            ->assertJsonPath('data.name', 'Morning lactation ration')
            ->assertJsonPath('data.ingredients.0.inventory_item_id', $item->id);

        $this->getJson('/api/v1/feed-ration-plans/'.$plan->json('data.id'), $headers)
            ->assertOk()
            ->assertJsonPath('data.feeding_frequency', 2);

        $issue = $this->postJson('/api/v1/daily-feed-issues', [
            'shed_id' => $foundation['shed']->id,
            'animal_group_id' => $references['group']->id,
            'date' => today()->toDateString(),
            'inventory_item_id' => $item->id,
            'planned_quantity' => '50.000',
            'issued_quantity' => '48.000',
            'consumed_quantity' => '45.000',
            'wasted_quantity' => '2.000',
            'returned_quantity' => '1.000',
            'notes' => 'Morning shed issue',
        ], [...$headers, 'Idempotency-Key' => (string) Str::uuid()])
            ->assertCreated()
            ->assertJsonPath('data.inventory_item_id', $item->id)
            ->assertJsonPath('data.issued_quantity', '48.000')
            ->assertJsonPath('data.inventory_posted', true)
            ->assertJsonPath('data.inventory_net_quantity', '47.000');

        $this->assertDatabaseHas('inventory_batches', ['inventory_item_id' => $item->id, 'current_quantity' => '53.000']);
        $this->assertDatabaseHas('stock_movements', ['reference_type' => 'daily_feed_issue', 'reference_id' => $issue->json('data.id'), 'movement_type' => 'issue', 'quantity_change' => '-48.000']);
        $this->assertDatabaseHas('stock_movements', ['reference_type' => 'daily_feed_issue', 'reference_id' => $issue->json('data.id'), 'movement_type' => 'return', 'quantity_change' => '1.000']);

        $this->getJson('/api/v1/daily-feed-issues', $headers)
            ->assertOk()
            ->assertJsonPath('data.0.id', $issue->json('data.id'));
        $this->assertDatabaseHas('audit_logs', ['action' => 'feed_ration_plan.created']);
        $this->assertDatabaseHas('audit_logs', ['action' => 'daily_feed_issue.created']);
    }

    public function test_animal_feed_history_accepts_only_active_photo_ready_animals(): void
    {
        $foundation = $this->foundation(['inventory.view', 'inventory.manage']);
        $references = $this->animalRegistryReferences($foundation);
        $headers = $this->bearer($this->loginToken());
        $item = InventoryItem::query()->create([
            'organization_id' => $foundation['organization']->id,
            'farm_id' => $foundation['farm']->id,
            'kind' => 'feed',
            'item_code' => 'FEED-002',
            'name' => 'Green fodder',
            'category' => 'Fodder',
            'unit' => 'kg',
            'minimum_stock' => '10.000',
            'is_active' => true,
            'created_by' => $foundation['user']->id,
            'updated_by' => $foundation['user']->id,
        ]);
        $animal = Animal::query()->create([
            'organization_id' => $foundation['organization']->id,
            'animal_number' => 'AN-000001',
            'species_id' => $references['species']->id,
            'breed_id' => $references['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'current_farm_id' => $foundation['farm']->id,
            'current_shed_id' => $foundation['shed']->id,
            'origin' => 'born_on_farm',
            'operational_status' => 'active',
            'photo_requirement_exempt' => true,
            'created_by' => $foundation['user']->id,
            'updated_by' => $foundation['user']->id,
        ]);

        $this->postJson("/api/v1/animals/{$animal->id}/feed-consumptions", [
            'inventory_item_id' => $item->id,
            'date' => today()->toDateString(),
            'session' => 'morning',
            'quantity' => '6.500',
            'unit' => 'kg',
            'notes' => 'Individual morning allocation',
        ], $headers)->assertCreated()
            ->assertJsonPath('data.animal_id', $animal->id)
            ->assertJsonPath('data.quantity', '6.500');

        $this->getJson("/api/v1/animals/{$animal->id}/feed-consumptions", $headers)
            ->assertOk()
            ->assertJsonPath('data.0.quantity', '6.500')
            ->assertJsonPath('meta.total', 1);

        $animal->forceFill(['operational_status' => 'sold'])->save();
        $this->postJson("/api/v1/animals/{$animal->id}/feed-consumptions", [
            'inventory_item_id' => $item->id,
            'date' => today()->toDateString(),
            'session' => 'evening',
            'quantity' => '1.000',
            'unit' => 'kg',
        ], $headers)->assertUnprocessable()
            ->assertJsonPath('error.code', 'ANIMAL_NOT_ACTIVE');
    }

    public function test_feed_analysis_calculates_nutrition_cost_wastage_and_variance(): void
    {
        $foundation = $this->foundation(['inventory.view', 'inventory.manage']);
        $refs = $this->animalRegistryReferences($foundation);
        $headers = $this->bearer($this->loginToken());
        $item = InventoryItem::query()->create(['organization_id' => $foundation['organization']->id, 'farm_id' => $foundation['farm']->id, 'kind' => 'feed', 'item_code' => 'NUT-001', 'name' => 'Balanced feed', 'category' => 'Concentrate', 'unit' => 'kg', 'minimum_stock' => 0, 'dry_matter_percent' => 90, 'crude_protein_percent' => 20, 'metabolizable_energy_mj_per_kg' => 12, 'is_active' => true, 'created_by' => $foundation['user']->id, 'updated_by' => $foundation['user']->id]);
        InventoryBatch::query()->create(['organization_id' => $item->organization_id, 'farm_id' => $item->farm_id, 'inventory_item_id' => $item->id, 'batch_number' => 'NUT-B1', 'unit_cost' => 100, 'current_quantity' => 100]);
        $this->postJson('/api/v1/feed-ration-plans', ['name' => 'Nutrition plan', 'animal_group_id' => $refs['group']->id, 'production_stage' => 'lactating', 'effective_date' => today()->toDateString(), 'feeding_frequency' => 2, 'ingredients' => [['inventory_item_id' => $item->id, 'quantity_per_animal' => 5, 'unit' => 'kg']]], [...$headers, 'Idempotency-Key' => (string) Str::uuid()])->assertCreated()->assertJsonPath('data.ingredients.0.estimated_cost', '500.0000');
        $this->postJson('/api/v1/daily-feed-issues', ['shed_id' => $foundation['shed']->id, 'animal_group_id' => $refs['group']->id, 'date' => today()->toDateString(), 'inventory_item_id' => $item->id, 'planned_quantity' => 50, 'issued_quantity' => 48, 'consumed_quantity' => 45, 'wasted_quantity' => 2, 'returned_quantity' => 1], [...$headers, 'Idempotency-Key' => (string) Str::uuid()])->assertCreated();
        $this->getJson('/api/v1/feed-analysis', $headers)->assertOk()->assertJsonPath('data.planned_quantity', 50)->assertJsonPath('data.variance_quantity', -2)->assertJsonPath('data.wastage_percent', 4.17)->assertJsonPath('data.estimated_feed_cost_pkr', 4500)->assertJsonPath('data.ration_nutrition_per_animal.dry_matter_kg', 4.5)->assertJsonPath('data.ration_nutrition_per_animal.crude_protein_kg', 1)->assertJsonPath('data.ration_nutrition_per_animal.energy_mj', 60);
    }

    public function test_feed_issue_rejects_unbalanced_or_insufficient_stock_without_partial_ledger(): void
    {
        $foundation = $this->foundation(['inventory.view', 'inventory.manage']);
        $headers = $this->bearer($this->loginToken());
        $item = InventoryItem::query()->create(['organization_id' => $foundation['organization']->id, 'farm_id' => $foundation['farm']->id, 'kind' => 'feed', 'item_code' => 'SMALL', 'name' => 'Small stock', 'category' => 'Feed', 'unit' => 'kg', 'minimum_stock' => 0, 'is_active' => true, 'created_by' => $foundation['user']->id, 'updated_by' => $foundation['user']->id]);
        InventoryBatch::query()->create(['organization_id' => $item->organization_id, 'farm_id' => $item->farm_id, 'inventory_item_id' => $item->id, 'batch_number' => 'SMALL-B1', 'expiry_date' => today()->addDay(), 'unit_cost' => 10, 'current_quantity' => 5]);
        $base = ['date' => today()->toDateString(), 'inventory_item_id' => $item->id, 'planned_quantity' => 10, 'issued_quantity' => 6, 'consumed_quantity' => 5, 'wasted_quantity' => 0, 'returned_quantity' => 0];
        $this->postJson('/api/v1/daily-feed-issues', $base, [...$headers, 'Idempotency-Key' => (string) Str::uuid()])->assertUnprocessable();
        $base['consumed_quantity'] = 6;
        $this->postJson('/api/v1/daily-feed-issues', $base, [...$headers, 'Idempotency-Key' => (string) Str::uuid()])->assertUnprocessable()->assertJsonPath('error.code', 'INSUFFICIENT_OR_EXPIRED_FEED');
        $this->assertDatabaseCount('daily_feed_issues', 0);
        $this->assertDatabaseCount('stock_movements', 0);
        $this->assertDatabaseHas('inventory_batches', ['inventory_item_id' => $item->id, 'current_quantity' => '5.000']);
    }
}

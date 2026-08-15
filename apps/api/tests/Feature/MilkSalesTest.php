<?php

namespace Tests\Feature;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\Commerce\Models\Customer;
use App\Domain\MilkProduction\Models\MilkEntry;
use App\Domain\MilkProduction\Models\MilkProductionSlot;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class MilkSalesTest extends TestCase
{
    use CreatesFoundationData,RefreshDatabase;

    public function test_confirm_payment_and_cancellation_control_milk_stock_and_customer_ledger(): void
    {
        $f = $this->foundation(['milk_sales.view', 'milk_sales.manage', 'milk_sales.confirm', 'milk_sales.cancel', 'customer_payments.manage']);
        $h = $this->bearer($this->loginToken());
        $refs = $this->animalRegistryReferences($f);
        $a = Animal::create(['organization_id' => $f['organization']->id, 'species_id' => $refs['species']->id, 'breed_id' => $refs['breed']->id, 'animal_group_id' => $refs['group']->id, 'current_farm_id' => $f['farm']->id, 'current_shed_id' => $f['shed']->id, 'animal_number' => 'A-1', 'origin' => 'born_on_farm', 'sex' => 'female', 'life_stage' => 'adult', 'operational_status' => 'active', 'photo_requirement_exempt' => true, 'created_by' => $f['user']->id, 'updated_by' => $f['user']->id]);
        $slot = MilkProductionSlot::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'shed_id' => $f['shed']->id, 'animal_id' => $a->id, 'production_date' => '2026-08-12', 'session' => 'morning']);
        MilkEntry::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'milk_production_slot_id' => $slot->id, 'animal_id' => $a->id, 'quantity_litres' => 25, 'rejected_quantity_litres' => 5, 'recorded_by' => $f['user']->id]);
        $c = Customer::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'code' => 'CUS-1', 'name' => 'Milk Shop', 'customer_type' => 'shop']);
        $payload = ['customer_id' => $c->id, 'sold_at' => '2026-08-12 10:00:00', 'milk_batch_date' => '2026-08-12', 'quantity_litres' => 12, 'base_rate' => 200, 'fat_adjustment' => 5, 'discount' => 60, 'delivery_charges' => 100];
        $sale = $this->postJson('/api/v1/milk-sales', $payload, [...$h, 'Idempotency-Key' => 'sale-1'])->assertCreated()->assertJsonPath('data.total_amount', '2500.00')->assertJsonPath('data.status', 'draft');
        $id = $sale->json('data.id');
        $this->postJson("/api/v1/milk-sales/$id/confirm", [], $h)->assertOk()->assertJsonPath('data.status', 'confirmed');
        $this->getJson('/api/v1/milk-sales', $h)->assertOk()->assertJsonPath('data.available_batches.0.available_sellable_litres', '8.000');
        $this->assertDatabaseHas('customers', ['id' => $c->id, 'current_balance' => '2500.00']);
        $this->postJson("/api/v1/milk-sales/$id/payments", ['payment_date' => '2026-08-12', 'amount' => 1000, 'payment_method' => 'cash'], [...$h, 'Idempotency-Key' => 'cpay-1'])->assertCreated()->assertJsonPath('data.balance_amount', '1500.00');
        $this->postJson("/api/v1/milk-sales/$id/cancel", ['reason' => 'Wrong customer'], $h)->assertStatus(409);
        $draft = $this->postJson('/api/v1/milk-sales', [...$payload, 'quantity_litres' => 8], [...$h, 'Idempotency-Key' => 'sale-2'])->assertCreated();
        $this->postJson("/api/v1/milk-sales/{$draft->json('data.id')}/confirm", [], $h)->assertOk();
        $this->postJson("/api/v1/milk-sales/{$draft->json('data.id')}/cancel", ['reason' => 'Delivery cancelled'], $h)->assertOk()->assertJsonPath('data.status', 'cancelled');
        $this->getJson('/api/v1/milk-sales', $h)->assertJsonPath('data.available_batches.0.available_sellable_litres', '8.000');
        $this->assertDatabaseCount('milk_stock_movements', 3);
        $this->assertDatabaseCount('commercial_ledger_entries', 4);
    }

    public function test_sale_cannot_exceed_sellable_or_include_rejected_milk(): void
    {
        $f = $this->foundation(['milk_sales.manage', 'milk_sales.confirm']);
        $h = $this->bearer($this->loginToken());
        $c = Customer::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'code' => 'C', 'name' => 'Buyer', 'customer_type' => 'shop']);
        $sale = $this->postJson('/api/v1/milk-sales', ['customer_id' => $c->id, 'sold_at' => '2026-08-12', 'milk_batch_date' => '2026-08-12', 'quantity_litres' => 1, 'base_rate' => 200], [...$h, 'Idempotency-Key' => 'empty'])->assertCreated();
        $this->postJson("/api/v1/milk-sales/{$sale->json('data.id')}/confirm", [], $h)->assertUnprocessable()->assertJsonPath('error.code', 'INSUFFICIENT_SELLABLE_MILK');
        $this->assertDatabaseCount('milk_stock_movements', 0);
        $this->assertDatabaseHas('customers', ['id' => $c->id, 'current_balance' => '0.00']);
    }
}

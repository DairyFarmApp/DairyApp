<?php

namespace Tests\Feature;

use App\Domain\Commerce\Models\Supplier;
use App\Models\Farm;
use App\Models\Organization;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class CommercialPartiesTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    private function context(string $email = 'owner@example.test'): array
    {
        $foundation = $this->foundation(['suppliers.view', 'suppliers.manage', 'customers.view', 'customers.manage', 'commercial_ledgers.view']);
        $token = $this->loginToken($email);

        return [$foundation, $this->bearer($token)];
    }

    public function test_supplier_codes_are_sequential_and_opening_balance_creates_a_payable_ledger(): void
    {
        [$foundation, $headers] = $this->context();
        $payload = ['farm_id' => $foundation['farm']->id, 'name' => 'Punjab Feed Supply', 'categories' => ['Feed'], 'opening_balance' => '24000.00', 'credit_limit' => '100000.00', 'payment_terms_days' => 30];
        $first = $this->postJson('/api/v1/suppliers', $payload, [...$headers, 'Idempotency-Key' => 'supplier-one'])->assertCreated()->assertJsonPath('data.code', 'SUP-00001')->assertJsonPath('data.currency', 'PKR')->assertJsonPath('data.current_balance', '24000.00');
        $this->postJson('/api/v1/suppliers', [...$payload, 'name' => 'Second Supplier', 'opening_balance' => 0], [...$headers, 'Idempotency-Key' => 'supplier-two'])->assertCreated()->assertJsonPath('data.code', 'SUP-00002');
        $this->getJson('/api/v1/suppliers/'.$first->json('data.id').'/ledger', $headers)->assertOk()->assertJsonPath('data.0.entry_type', 'opening_balance')->assertJsonPath('data.0.credit', '24000.00')->assertJsonPath('data.0.debit', '0.00');
        $this->assertDatabaseCount('commercial_ledger_entries', 1);
    }

    public function test_customer_creation_is_idempotent_and_opening_receivable_is_immutable(): void
    {
        [$foundation, $headers] = $this->context();
        $payload = ['farm_id' => $foundation['farm']->id, 'name' => 'Al Madina Milk Shop', 'customer_type' => 'shop', 'opening_balance' => '12500.00', 'default_milk_rate' => '220.00', 'quality_based_pricing' => true];
        $first = $this->postJson('/api/v1/customers', $payload, [...$headers, 'Idempotency-Key' => 'customer-one'])->assertCreated()->assertJsonPath('data.code', 'CUS-00001');
        $this->postJson('/api/v1/customers', $payload, [...$headers, 'Idempotency-Key' => 'customer-one'])->assertStatus($first->status())->assertExactJson($first->json());
        $this->assertDatabaseCount('customers', 1);
        $this->assertDatabaseCount('commercial_ledger_entries', 1);
        $this->patchJson('/api/v1/customers/'.$first->json('data.id'), ['opening_balance' => 0, 'version' => 1], $headers)->assertUnprocessable();
        $this->getJson('/api/v1/customers/'.$first->json('data.id').'/ledger', $headers)->assertOk()->assertJsonPath('data.0.debit', '12500.00')->assertJsonPath('data.0.balance_after', '12500.00');
    }

    public function test_updates_use_versions_and_archive_does_not_erase_ledger_history(): void
    {
        [$foundation, $headers] = $this->context();
        $created = $this->postJson('/api/v1/customers', ['farm_id' => $foundation['farm']->id, 'name' => 'Factory Buyer', 'customer_type' => 'factory', 'opening_balance' => 500], [...$headers, 'Idempotency-Key' => 'archive-customer'])->assertCreated();
        $id = $created->json('data.id');
        $this->patchJson("/api/v1/customers/$id", ['name' => 'Updated Factory Buyer', 'version' => 1], $headers)->assertOk()->assertJsonPath('data.version', 2);
        $this->patchJson("/api/v1/customers/$id", ['name' => 'Stale Name', 'version' => 1], $headers)->assertStatus(412)->assertJsonPath('error.code', 'STALE_VERSION');
        $this->deleteJson("/api/v1/customers/$id", [], $headers)->assertOk()->assertJsonPath('data.archived', true);
        $this->getJson('/api/v1/customers', $headers)->assertOk()->assertJsonCount(0, 'data');
        $this->getJson("/api/v1/customers/$id/ledger", $headers)->assertOk()->assertJsonCount(1, 'data');
        $this->assertSoftDeleted('customers', ['id' => $id]);
    }

    public function test_party_lists_are_tenant_and_farm_scoped_and_values_are_validated(): void
    {
        [$foundation, $headers] = $this->context();
        $this->postJson('/api/v1/customers', ['farm_id' => $foundation['farm']->id, 'name' => 'Invalid', 'customer_type' => 'unknown', 'credit_limit' => -1], [...$headers, 'Idempotency-Key' => 'invalid'])->assertUnprocessable();
        $this->postJson('/api/v1/suppliers', ['farm_id' => $foundation['farm']->id, 'name' => 'Visible Supplier'], [...$headers, 'Idempotency-Key' => 'visible'])->assertCreated();

        $otherOrganization = Organization::create(['name' => 'Other Dairy', 'timezone' => 'Asia/Karachi', 'locale' => 'en']);
        $otherFarm = Farm::create(['organization_id' => $otherOrganization->id, 'name' => 'Other Farm', 'code' => 'OTHER', 'timezone' => 'Asia/Karachi']);
        Supplier::create(['organization_id' => $otherOrganization->id, 'farm_id' => $otherFarm->id, 'code' => 'SUP-00001', 'name' => 'Hidden Supplier']);
        $this->getJson('/api/v1/suppliers', $headers)->assertOk()->assertJsonCount(1, 'data')->assertJsonPath('data.0.name', 'Visible Supplier');
    }
}

<?php

namespace Tests\Feature;

use App\Domain\Commerce\Models\Customer;
use App\Domain\Commerce\Models\MilkSale;
use App\Domain\Commerce\Models\MilkStockMovement;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class DeliveryManagementTest extends TestCase
{
    use CreatesFoundationData,RefreshDatabase;

    public function test_route_manifest_dispatch_and_partial_delivery_preserve_quantities(): void
    {
        $f = $this->foundation(['deliveries.view', 'deliveries.manage', 'deliveries.dispatch', 'deliveries.complete', 'customer_refunds.manage']);
        $h = $this->bearer($this->loginToken());
        $c1 = Customer::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'code' => 'C1', 'name' => 'Shop One', 'customer_type' => 'shop']);
        $c2 = Customer::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'code' => 'C2', 'name' => 'Shop Two', 'customer_type' => 'shop']);
        $route = $this->postJson('/api/v1/delivery-routes', ['name' => 'City Route', 'stops' => [['customer_id' => $c1->id], ['customer_id' => $c2->id]]], [...$h, 'Idempotency-Key' => 'route'])->assertCreated();
        $vehicle = $this->postJson('/api/v1/delivery-vehicles', ['registration_number' => 'LEA-123', 'capacity_litres' => 50], $h)->assertCreated();
        $driver = $this->postJson('/api/v1/delivery-drivers', ['name' => 'Ali Driver', 'phone' => '03001234567'], $h)->assertCreated();
        $s1 = $this->sale($f, $c1, 10, 'MS-1');
        $s2 = $this->sale($f, $c2, 8, 'MS-2');
        $manifest = $this->postJson('/api/v1/delivery-manifests', ['delivery_route_id' => $route->json('data.id'), 'delivery_vehicle_id' => $vehicle->json('data.id'), 'delivery_driver_id' => $driver->json('data.id'), 'delivery_date' => '2026-08-12', 'milk_sale_ids' => [$s1->id, $s2->id]], [...$h, 'Idempotency-Key' => 'manifest'])->assertCreated()->assertJsonPath('data.planned_quantity', '18.000')->assertJsonPath('data.status', 'scheduled');
        $id = $manifest->json('data.id');
        $stops = $manifest->json('data.stops');
        $this->postJson("/api/v1/delivery-manifests/$id/dispatch", ['loaded_quantity' => 18], $h)->assertOk()->assertJsonPath('data.status', 'dispatched');
        $this->postJson("/api/v1/delivery-manifests/$id/stops/{$stops[0]['id']}/complete", ['status' => 'delivered', 'delivered_quantity' => 10, 'acknowledged_by' => 'Shopkeeper'], $h)->assertOk();
        $this->postJson("/api/v1/delivery-manifests/$id/stops/{$stops[1]['id']}/complete", ['status' => 'partially_delivered', 'delivered_quantity' => 6, 'returned_quantity' => 2, 'rejected_quantity' => 0, 'restocked_quantity' => 2, 'return_reason' => 'Customer needed less milk', 'notes' => 'Sealed milk returned'], $h)->assertOk()->assertJsonPath('data.status', 'partially_delivered')->assertJsonPath('data.delivered_quantity', '16.000')->assertJsonPath('data.returned_quantity', '2.000');
        $this->assertDatabaseHas('milk_sales', ['id' => $s1->id, 'delivery_status' => 'delivered']);
        $this->assertDatabaseHas('milk_sales', ['id' => $s2->id, 'delivery_status' => 'partially_delivered']);
        $this->assertDatabaseHas('milk_sale_returns', ['milk_sale_id' => $s2->id, 'returned_quantity' => 2, 'restocked_quantity' => 2, 'credit_amount' => 400]);
        $this->assertDatabaseHas('milk_stock_movements', ['milk_sale_id' => $s2->id, 'movement_type' => 'sale_return', 'quantity_change' => 2]);
        $this->assertDatabaseHas('commercial_ledger_entries', ['party_id' => $c2->id, 'entry_type' => 'milk_sale_return', 'credit' => 400]);
    }

    public function test_return_requires_disposition_and_proof_is_private(): void
    {
        Storage::fake('local');
        $f = $this->foundation(['deliveries.view', 'deliveries.manage', 'deliveries.dispatch', 'deliveries.complete', 'customer_refunds.manage']);
        $h = $this->bearer($this->loginToken());
        $c = Customer::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'code' => 'C', 'name' => 'Shop', 'customer_type' => 'shop']);
        $route = $this->postJson('/api/v1/delivery-routes', ['name' => 'Route', 'stops' => [['customer_id' => $c->id]]], [...$h, 'Idempotency-Key' => 'proof-route'])->json('data.id');
        $vehicle = $this->postJson('/api/v1/delivery-vehicles', ['registration_number' => 'PROOF-1', 'capacity_litres' => 10], $h)->json('data.id');
        $driver = $this->postJson('/api/v1/delivery-drivers', ['name' => 'Driver'], $h)->json('data.id');
        $sale = $this->sale($f, $c, 5, 'MS-P');
        $manifest = $this->postJson('/api/v1/delivery-manifests', ['delivery_route_id' => $route, 'delivery_vehicle_id' => $vehicle, 'delivery_driver_id' => $driver, 'delivery_date' => '2026-08-12', 'milk_sale_ids' => [$sale->id]], [...$h, 'Idempotency-Key' => 'proof-manifest'])->json('data');
        $stop = $manifest['stops'][0]['id'];
        $this->postJson("/api/v1/delivery-manifests/{$manifest['id']}/dispatch", ['loaded_quantity' => 5], $h)->assertOk();
        $this->postJson("/api/v1/delivery-manifests/{$manifest['id']}/stops/$stop/complete", ['status' => 'partially_delivered', 'delivered_quantity' => 4, 'returned_quantity' => 1, 'restocked_quantity' => 1], $h)->assertUnprocessable()->assertJsonPath('error.code', 'INVALID_RETURN_DISPOSITION');
        $sale->update(['paid_amount' => 1000, 'balance_amount' => 0, 'payment_status' => 'paid']);
        $this->postJson("/api/v1/delivery-manifests/{$manifest['id']}/stops/$stop/complete", ['status' => 'partially_delivered', 'delivered_quantity' => 4, 'returned_quantity' => 1, 'restocked_quantity' => 1, 'return_reason' => 'Shop closed early'], $h)->assertOk();
        $this->assertDatabaseHas('milk_sale_returns', ['milk_sale_id' => $sale->id, 'refund_due' => 200, 'refund_status' => 'pending']);
        $refundUrl = "/api/v1/delivery-manifests/{$manifest['id']}/stops/$stop/refunds";
        $this->postJson($refundUrl, ['amount' => 201, 'refund_date' => '2026-08-12', 'payment_method' => 'cash'], [...$h, 'Idempotency-Key' => 'too-much'])->assertUnprocessable();
        $refund = $this->postJson($refundUrl, ['amount' => 200, 'refund_date' => '2026-08-12', 'payment_method' => 'cash'], [...$h, 'Idempotency-Key' => 'refund'])->assertCreated();
        $this->assertDatabaseHas('milk_sale_returns', ['milk_sale_id' => $sale->id, 'refunded_amount' => 200, 'refund_status' => 'refunded']);
        $this->assertDatabaseHas('customer_refunds', ['milk_sale_id' => $sale->id, 'amount' => 200]);
        $this->get("/api/v1/delivery-manifests/{$manifest['id']}/delivery-note.pdf", $h)->assertOk()->assertHeader('content-type', 'application/pdf');
        $this->get('/api/v1/customer-refunds/'.$refund->json('data.id').'/receipt.pdf', $h)->assertOk()->assertHeader('content-type', 'application/pdf');
        $xlsx = $this->get('/api/v1/deliveries/export.xlsx?from_date=2026-08-01&to_date=2026-08-31&status=partially_delivered', $h)->assertOk()->assertHeader('content-type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        $this->assertStringStartsWith('PK', $xlsx->getContent());
        $this->get('/api/v1/deliveries/export.xlsx?from_date=2026-09-01&to_date=2026-08-01', $h)->assertUnprocessable();
        $this->post("/api/v1/delivery-manifests/{$manifest['id']}/stops/$stop/proof", ['proof' => UploadedFile::fake()->createWithContent('delivery.png', base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='))], $h)->assertCreated();
        $this->get("/api/v1/delivery-manifests/{$manifest['id']}/stops/$stop/proof")->assertUnauthorized();
        $this->get("/api/v1/delivery-manifests/{$manifest['id']}/stops/$stop/proof", $h)->assertOk();
    }

    public function test_capacity_and_quantity_mismatch_are_blocked(): void
    {
        $f = $this->foundation(['deliveries.manage', 'deliveries.dispatch', 'deliveries.complete']);
        $h = $this->bearer($this->loginToken());
        $c = Customer::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'code' => 'C', 'name' => 'Shop', 'customer_type' => 'shop']);
        $route = $this->postJson('/api/v1/delivery-routes', ['name' => 'Route', 'stops' => [['customer_id' => $c->id]]], [...$h, 'Idempotency-Key' => 'r'])->assertCreated();
        $vehicle = $this->postJson('/api/v1/delivery-vehicles', ['registration_number' => 'SMALL', 'capacity_litres' => 5], $h)->assertCreated();
        $driver = $this->postJson('/api/v1/delivery-drivers', ['name' => 'Driver'], $h)->assertCreated();
        $sale = $this->sale($f, $c, 8, 'MS-X');
        $this->postJson('/api/v1/delivery-manifests', ['delivery_route_id' => $route->json('data.id'), 'delivery_vehicle_id' => $vehicle->json('data.id'), 'delivery_driver_id' => $driver->json('data.id'), 'delivery_date' => '2026-08-12', 'milk_sale_ids' => [$sale->id]], [...$h, 'Idempotency-Key' => 'too-big'])->assertUnprocessable();
        $this->assertDatabaseCount('delivery_manifests', 0);
    }

    private function sale(array $f, Customer $c, float $q, string $n): MilkSale
    {
        return MilkSale::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'customer_id' => $c->id, 'invoice_number' => $n, 'sold_at' => '2026-08-12', 'milk_batch_date' => '2026-08-12', 'quantity_litres' => $q, 'base_rate' => 200, 'total_amount' => $q * 200, 'balance_amount' => $q * 200, 'payment_status' => 'unpaid', 'status' => 'confirmed', 'delivery_status' => 'pending', 'created_by' => $f['user']->id]);
    }
}

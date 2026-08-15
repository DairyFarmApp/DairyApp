<?php

namespace Tests\Feature;

use App\Domain\Commerce\Models\Supplier;
use App\Domain\Inventory\Models\InventoryItem;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class PurchaseOrderTest extends TestCase
{
    use CreatesFoundationData,RefreshDatabase;

    public function test_approved_purchase_order_supports_partial_and_full_receipts_with_stock_history(): void
    {
        $f = $this->foundation(['purchases.view', 'purchases.manage', 'purchases.approve', 'purchases.receive']);
        $h = $this->bearer($this->loginToken());
        $supplier = Supplier::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'code' => 'SUP-00001', 'name' => 'Feed Supplier']);
        $item = InventoryItem::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'kind' => 'feed', 'item_code' => 'FEED-1', 'name' => 'Cotton seed cake', 'category' => 'Concentrate', 'unit' => 'kg', 'minimum_stock' => 0, 'maximum_stock' => 1000, 'created_by' => $f['user']->id, 'updated_by' => $f['user']->id]);
        $created = $this->postJson('/api/v1/purchase-orders', ['farm_id' => $f['farm']->id, 'supplier_id' => $supplier->id, 'purchase_date' => '2026-08-12', 'transport_cost' => '500', 'items' => [['inventory_item_id' => $item->id, 'quantity' => '24', 'unit_rate' => '100']]], [...$h, 'Idempotency-Key' => 'po-1'])->assertCreated()->assertJsonPath('data.purchase_number', 'PO-000001')->assertJsonPath('data.total', '2900.00')->assertJsonPath('data.status', 'draft');
        $id = $created->json('data.id');
        $line = $created->json('data.items.0.id');
        $this->postJson("/api/v1/purchase-orders/$id/receipts", ['quality_status' => 'accepted', 'items' => [['purchase_order_item_id' => $line, 'batch_number' => 'B-1', 'quantity' => 10]]], [...$h, 'Idempotency-Key' => 'early'])->assertStatus(409);
        $this->postJson("/api/v1/purchase-orders/$id/approve", [], $h)->assertOk()->assertJsonPath('data.status', 'approved');
        $firstReceipt = ['quality_status' => 'accepted', 'items' => [['purchase_order_item_id' => $line, 'batch_number' => 'B-1', 'expiry_date' => '2027-08-12', 'quantity' => 10]]];
        $first = $this->postJson("/api/v1/purchase-orders/$id/receipts", $firstReceipt, [...$h, 'Idempotency-Key' => 'grn-1'])->assertCreated()->assertJsonPath('data.receipt_number', 'GRN-000001')->assertJsonPath('data.purchase_order.status', 'partially_received');
        $this->postJson("/api/v1/purchase-orders/$id/receipts", $firstReceipt, [...$h, 'Idempotency-Key' => 'grn-1'])->assertStatus($first->status())->assertExactJson($first->json());
        $this->postJson("/api/v1/purchase-orders/$id/receipts", ['quality_status' => 'conditionally_accepted', 'notes' => 'Minor packaging damage', 'items' => [['purchase_order_item_id' => $line, 'batch_number' => 'B-1', 'quantity' => 14]]], [...$h, 'Idempotency-Key' => 'grn-2'])->assertCreated()->assertJsonPath('data.purchase_order.status', 'received')->assertJsonPath('data.purchase_order.items.0.received_quantity', '24.000');
        $this->assertDatabaseCount('goods_receipts', 2);
        $this->assertDatabaseCount('stock_movements', 2);
        $this->assertDatabaseHas('inventory_batches', ['inventory_item_id' => $item->id, 'current_quantity' => '24.000']);
        $this->assertDatabaseHas('stock_movements', ['movement_type' => 'purchase_receipt', 'reference_type' => 'goods_receipt']);
    }

    public function test_receipt_rejects_over_delivery_and_rejected_quality(): void
    {
        $f = $this->foundation(['purchases.view', 'purchases.manage', 'purchases.approve', 'purchases.receive']);
        $h = $this->bearer($this->loginToken());
        $s = Supplier::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'code' => 'SUP-00001', 'name' => 'Vet Supplier']);
        $i = InventoryItem::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'kind' => 'medicine', 'item_code' => 'MED-1', 'name' => 'Medicine', 'category' => 'Injection', 'unit' => 'vial', 'minimum_stock' => 0, 'maximum_stock' => 100, 'created_by' => $f['user']->id, 'updated_by' => $f['user']->id]);
        $o = $this->postJson('/api/v1/purchase-orders', ['farm_id' => $f['farm']->id, 'supplier_id' => $s->id, 'purchase_date' => '2026-08-12', 'items' => [['inventory_item_id' => $i->id, 'quantity' => 5, 'unit_rate' => 200]]], [...$h, 'Idempotency-Key' => 'po-2'])->assertCreated();
        $id = $o->json('data.id');
        $line = $o->json('data.items.0.id');
        $this->postJson("/api/v1/purchase-orders/$id/approve", [], $h)->assertOk();
        $this->postJson("/api/v1/purchase-orders/$id/receipts", ['quality_status' => 'rejected', 'items' => [['purchase_order_item_id' => $line, 'batch_number' => 'X', 'quantity' => 5]]], [...$h, 'Idempotency-Key' => 'reject'])->assertUnprocessable()->assertJsonPath('error.code', 'QUALITY_REJECTED');
        $this->postJson("/api/v1/purchase-orders/$id/receipts", ['quality_status' => 'accepted', 'items' => [['purchase_order_item_id' => $line, 'batch_number' => 'X', 'quantity' => 6]]], [...$h, 'Idempotency-Key' => 'over'])->assertUnprocessable();
        $this->assertDatabaseCount('stock_movements', 0);
    }
}

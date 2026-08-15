<?php

namespace Tests\Feature;

use App\Domain\Commerce\Models\PurchaseOrder;
use App\Domain\Commerce\Models\Supplier;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class SupplierInvoiceTest extends TestCase
{
    use CreatesFoundationData,RefreshDatabase;

    public function test_invoice_and_partial_full_payments_update_supplier_ledger_and_preserve_history(): void
    {
        $f = $this->foundation(['supplier_invoices.view', 'supplier_invoices.manage', 'supplier_payments.manage', 'commercial_ledgers.view']);
        $h = $this->bearer($this->loginToken());
        $s = Supplier::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'code' => 'SUP-00001', 'name' => 'Feed Supplier', 'opening_balance' => 1000, 'current_balance' => 1000]);
        $po = PurchaseOrder::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'supplier_id' => $s->id, 'purchase_number' => 'PO-000001', 'purchase_date' => '2026-08-12', 'status' => 'received', 'subtotal' => 2400, 'total' => 2500, 'created_by' => $f['user']->id, 'updated_by' => $f['user']->id]);
        $invoicePayload = ['purchase_order_id' => $po->id, 'supplier_invoice_number' => 'FS-7788', 'invoice_date' => '2026-08-12', 'due_date' => '2026-09-11'];
        $created = $this->postJson('/api/v1/supplier-invoices', $invoicePayload, [...$h, 'Idempotency-Key' => 'inv-1'])->assertCreated()->assertJsonPath('data.invoice_number', 'SINV-000001')->assertJsonPath('data.balance_amount', '2500.00')->assertJsonPath('data.payment_status', 'unpaid');
        $this->postJson('/api/v1/supplier-invoices', $invoicePayload, [...$h, 'Idempotency-Key' => 'inv-1'])->assertStatus($created->status())->assertExactJson($created->json());
        $id = $created->json('data.id');
        $this->assertDatabaseHas('suppliers', ['id' => $s->id, 'current_balance' => '3500.00']);
        $first = ['payment_date' => '2026-08-13', 'amount' => 1000, 'payment_method' => 'bank_transfer', 'reference' => 'TX-1'];
        $this->postJson("/api/v1/supplier-invoices/$id/payments", $first, [...$h, 'Idempotency-Key' => 'pay-1'])->assertCreated()->assertJsonPath('data.payment_status', 'partially_paid')->assertJsonPath('data.balance_amount', '1500.00');
        $this->postJson("/api/v1/supplier-invoices/$id/payments", ['payment_date' => '2026-08-14', 'amount' => 1500, 'payment_method' => 'cash'], [...$h, 'Idempotency-Key' => 'pay-2'])->assertCreated()->assertJsonPath('data.payment_status', 'paid')->assertJsonPath('data.balance_amount', '0.00')->assertJsonCount(2, 'data.payments');
        $this->assertDatabaseHas('suppliers', ['id' => $s->id, 'current_balance' => '1000.00']);
        $this->assertDatabaseCount('supplier_payments', 2);
        $this->assertDatabaseCount('commercial_ledger_entries', 3);
        $this->assertDatabaseHas('commercial_ledger_entries', ['entry_type' => 'supplier_invoice', 'credit' => '2500.00']);
        $this->assertDatabaseHas('commercial_ledger_entries', ['entry_type' => 'supplier_payment', 'debit' => '1500.00']);
    }

    public function test_invoice_rules_block_draft_duplicate_and_overpayment(): void
    {
        $f = $this->foundation(['supplier_invoices.view', 'supplier_invoices.manage', 'supplier_payments.manage']);
        $h = $this->bearer($this->loginToken());
        $s = Supplier::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'code' => 'SUP-00001', 'name' => 'Supplier']);
        $po = PurchaseOrder::create(['organization_id' => $f['organization']->id, 'farm_id' => $f['farm']->id, 'supplier_id' => $s->id, 'purchase_number' => 'PO-1', 'purchase_date' => '2026-08-12', 'status' => 'draft', 'subtotal' => 500, 'total' => 500, 'created_by' => $f['user']->id, 'updated_by' => $f['user']->id]);
        $payload = ['purchase_order_id' => $po->id, 'supplier_invoice_number' => 'EXT-1', 'invoice_date' => '2026-08-12', 'due_date' => '2026-08-12'];
        $this->postJson('/api/v1/supplier-invoices', $payload, [...$h, 'Idempotency-Key' => 'draft'])->assertStatus(409);
        $po->update(['status' => 'approved']);
        $invoice = $this->postJson('/api/v1/supplier-invoices', $payload, [...$h, 'Idempotency-Key' => 'valid'])->assertCreated();
        $this->postJson("/api/v1/supplier-invoices/{$invoice->json('data.id')}/payments", ['payment_date' => '2026-08-12', 'amount' => 501, 'payment_method' => 'cash'], [...$h, 'Idempotency-Key' => 'over'])->assertUnprocessable()->assertJsonPath('error.code', 'PAYMENT_EXCEEDS_BALANCE');
        $this->assertDatabaseCount('supplier_payments',0);
        $this->assertDatabaseHas('suppliers',['id' => $s->id, 'current_balance' => '500.00']);
    }
}

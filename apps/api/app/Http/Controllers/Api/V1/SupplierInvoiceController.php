<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Commerce\Models\CommercialLedgerEntry;
use App\Domain\Commerce\Models\PurchaseOrder;
use App\Domain\Commerce\Models\Supplier;
use App\Domain\Commerce\Models\SupplierInvoice;
use App\Domain\Commerce\Models\SupplierPayment;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\SupplierInvoiceRequest;
use App\Http\Requests\Api\V1\SupplierPaymentRequest;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SupplierInvoiceController extends Controller
{
    public function __construct(private IdempotencyService $idempotency, private AuditService $audit) {}

    public function index(Request $r): JsonResponse
    {
        $rows = SupplierInvoice::with(['supplier', 'purchaseOrder', 'payments'])->where('organization_id', $r->attributes->get('organization_id'))->where('farm_id', $r->attributes->get('api_session')->farm_id)->latest('invoice_date')->get();

        return ApiResponse::success($r, $rows->map(fn ($i) => $this->payload($i)));
    }

    public function store(SupplierInvoiceRequest $r): JsonResponse
    {
        return $this->idempotency->execute($r, function () use ($r) {
            $d = $r->validated();
            $order = PurchaseOrder::with('supplier')->where('organization_id', $r->attributes->get('organization_id'))->where('farm_id', $r->attributes->get('api_session')->farm_id)->findOrFail($d['purchase_order_id']);
            if (! in_array($order->status, ['approved', 'partially_received', 'received'], true)) {
                return ApiResponse::error($r, 'INVALID_PURCHASE_STATUS', 'Approve the purchase order before creating its supplier invoice.', 409);
            }$invoice = DB::transaction(function () use ($r, $d, $order) {
                $supplier = Supplier::lockForUpdate()->findOrFail($order->supplier_id);
                $number = sprintf('SINV-%06d', SupplierInvoice::where('organization_id', $order->organization_id)->lockForUpdate()->count() + 1);
                $invoice = SupplierInvoice::create([...$d, 'organization_id' => $order->organization_id, 'farm_id' => $order->farm_id, 'supplier_id' => $supplier->id, 'invoice_number' => $number, 'total_amount' => $order->total, 'paid_amount' => 0, 'balance_amount' => $order->total, 'payment_status' => 'unpaid', 'created_by' => $r->user()->id]);
                $balance = (float) $supplier->current_balance + (float) $order->total;
                $supplier->forceFill(['current_balance' => $balance, 'version' => $supplier->version + 1, 'updated_by' => $r->user()->id])->save();
                CommercialLedgerEntry::create(['organization_id' => $order->organization_id, 'farm_id' => $order->farm_id, 'party_type' => 'supplier', 'party_id' => $supplier->id, 'occurred_at' => $d['invoice_date'], 'entry_type' => 'supplier_invoice', 'debit' => 0, 'credit' => $order->total, 'balance_after' => $balance, 'reference_type' => 'supplier_invoice', 'reference_id' => $invoice->id, 'description' => 'Supplier invoice '.$number, 'created_by' => $r->user()->id]);
                $this->audit->record($r, 'supplier_invoice.created', 'supplier_invoice', $invoice->id, null, ['invoice_number' => $number, 'amount' => $order->total]);

                return $invoice;
            });

            return ApiResponse::success($r, $this->payload($invoice->load(['supplier', 'purchaseOrder', 'payments'])), 201);
        });
    }

    public function pay(SupplierPaymentRequest $r, string $invoice): JsonResponse
    {
        return $this->idempotency->execute($r, function () use ($r, $invoice) {
            $d = $r->validated();
            $result = DB::transaction(function () use ($r, $invoice, $d) {
                $i = SupplierInvoice::with(['supplier', 'purchaseOrder', 'payments'])->where('organization_id', $r->attributes->get('organization_id'))->where('farm_id', $r->attributes->get('api_session')->farm_id)->lockForUpdate()->findOrFail($invoice);
                if ((float) $d['amount'] > (float) $i->balance_amount + 0.001) {
                    return null;
                }$supplier = Supplier::lockForUpdate()->findOrFail($i->supplier_id);
                $number = sprintf('SPAY-%06d', SupplierPayment::where('organization_id', $i->organization_id)->lockForUpdate()->count() + 1);
                $payment = SupplierPayment::create([...$d, 'organization_id' => $i->organization_id, 'farm_id' => $i->farm_id, 'supplier_id' => $i->supplier_id, 'supplier_invoice_id' => $i->id, 'payment_number' => $number, 'created_by' => $r->user()->id]);
                $paid = (float) $i->paid_amount + (float) $d['amount'];
                $remaining = (float) $i->total_amount - $paid;
                $i->forceFill(['paid_amount' => $paid, 'balance_amount' => $remaining, 'payment_status' => $remaining < 0.005 ? 'paid' : 'partially_paid'])->save();
                $balance = max(0, (float) $supplier->current_balance - (float) $d['amount']);
                $supplier->forceFill(['current_balance' => $balance, 'version' => $supplier->version + 1, 'updated_by' => $r->user()->id])->save();
                CommercialLedgerEntry::create(['organization_id' => $i->organization_id, 'farm_id' => $i->farm_id, 'party_type' => 'supplier', 'party_id' => $supplier->id, 'occurred_at' => $d['payment_date'], 'entry_type' => 'supplier_payment', 'debit' => $d['amount'], 'credit' => 0, 'balance_after' => $balance, 'reference_type' => 'supplier_payment', 'reference_id' => $payment->id, 'description' => 'Supplier payment '.$number, 'created_by' => $r->user()->id]);
                $this->audit->record($r, 'supplier_payment.created', 'supplier_payment', $payment->id, null, ['payment_number' => $number, 'amount' => $d['amount']]);

                return $i->fresh(['supplier', 'purchaseOrder', 'payments']);
            });
            if ($result === null) {
                return ApiResponse::error($r, 'PAYMENT_EXCEEDS_BALANCE', 'Payment cannot exceed the outstanding invoice balance.', 422);
            }

            return ApiResponse::success($r, $this->payload($result), 201);
        });
    }

    private function payload(SupplierInvoice $i): array
    {
        return ['id' => $i->id, 'invoice_number' => $i->invoice_number, 'supplier_invoice_number' => $i->supplier_invoice_number, 'supplier' => ['id' => $i->supplier->id, 'code' => $i->supplier->code, 'name' => $i->supplier->name], 'purchase_order' => ['id' => $i->purchaseOrder->id, 'purchase_number' => $i->purchaseOrder->purchase_number], 'invoice_date' => $i->invoice_date->toDateString(), 'due_date' => $i->due_date->toDateString(), 'total_amount' => $i->total_amount, 'paid_amount' => $i->paid_amount, 'balance_amount' => $i->balance_amount, 'payment_status' => $i->payment_status, 'currency' => 'PKR', 'notes' => $i->notes, 'payments' => $i->payments->map(fn ($p) => ['id' => $p->id, 'payment_number' => $p->payment_number, 'payment_date' => $p->payment_date->toDateString(), 'amount' => $p->amount, 'payment_method' => $p->payment_method, 'reference' => $p->reference])];
    }
}

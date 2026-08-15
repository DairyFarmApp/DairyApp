<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Commerce\Models\CommercialLedgerEntry;
use App\Domain\Commerce\Models\Customer;
use App\Domain\Commerce\Models\CustomerPayment;
use App\Domain\Commerce\Models\MilkSale;
use App\Domain\Commerce\Models\MilkStockMovement;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\CustomerPaymentRequest;
use App\Http\Requests\Api\V1\MilkSaleRequest;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MilkSaleController extends Controller
{
    public function __construct(private IdempotencyService $idempotency, private AuditService $audit) {}

    public function index(Request $r): JsonResponse
    {
        $rows = MilkSale::with(['customer', 'payments'])->where('organization_id', $r->attributes->get('organization_id'))->where('farm_id', $r->attributes->get('api_session')->farm_id)->latest('sold_at')->get();

        return ApiResponse::success($r, ['available_batches' => $this->batches($r), 'sales' => $rows->map(fn ($s) => $this->payload($s))]);
    }

    public function store(MilkSaleRequest $r): JsonResponse
    {
        return $this->idempotency->execute($r, function () use ($r) {
            $d = $r->validated();
            $customer = Customer::where('organization_id', $r->attributes->get('organization_id'))->where('farm_id', $r->attributes->get('api_session')->farm_id)->where('is_active', true)->findOrFail($d['customer_id']);
            $subtotal = (float) $d['quantity_litres'] * ((float) $d['base_rate'] + (float) ($d['fat_adjustment'] ?? 0) + (float) ($d['snf_adjustment'] ?? 0) + (float) ($d['quality_adjustment'] ?? 0));
            $total = max(0, $subtotal - (float) ($d['discount'] ?? 0) + (float) ($d['tax'] ?? 0) + (float) ($d['delivery_charges'] ?? 0));
            $sale = MilkSale::create([...$d, 'organization_id' => $customer->organization_id, 'farm_id' => $customer->farm_id, 'invoice_number' => sprintf('MS-%06d', MilkSale::where('organization_id', $customer->organization_id)->count() + 1), 'total_amount' => $total, 'paid_amount' => 0, 'balance_amount' => $total, 'payment_status' => 'unpaid', 'status' => 'draft', 'created_by' => $r->user()->id]);
            $this->audit->record($r, 'milk_sale.draft_created', 'milk_sale', $sale->id, null, ['total' => $total]);

            return ApiResponse::success($r, $this->payload($sale->load(['customer', 'payments'])), 201);
        });
    }

    public function confirm(Request $r, string $sale): JsonResponse
    {
        $model = $this->sale($r, $sale);
        if ($model->status !== 'draft') {
            return ApiResponse::error($r, 'INVALID_SALE_STATUS', 'Only draft sales can be confirmed.', 409);
        }$result = DB::transaction(function () use ($r, $model) {
            $locked = MilkSale::with('customer')->lockForUpdate()->findOrFail($model->id);
            $available = $this->available($locked->organization_id, $locked->farm_id, $locked->milk_batch_date->toDateString());
            if ((float) $locked->quantity_litres > $available + 0.000001) {
                return null;
            }$customer = Customer::lockForUpdate()->findOrFail($locked->customer_id);
            MilkStockMovement::create(['organization_id' => $locked->organization_id, 'farm_id' => $locked->farm_id, 'milk_batch_date' => $locked->milk_batch_date, 'milk_sale_id' => $locked->id, 'movement_type' => 'sale', 'quantity_change' => -(float) $locked->quantity_litres, 'occurred_at' => now(), 'reason' => 'Confirmed milk sale '.$locked->invoice_number, 'created_by' => $r->user()->id]);
            $balance = (float) $customer->current_balance + (float) $locked->balance_amount;
            $customer->forceFill(['current_balance' => $balance, 'version' => $customer->version + 1, 'updated_by' => $r->user()->id])->save();
            CommercialLedgerEntry::create(['organization_id' => $locked->organization_id, 'farm_id' => $locked->farm_id, 'party_type' => 'customer', 'party_id' => $customer->id, 'occurred_at' => $locked->sold_at, 'entry_type' => 'milk_sale', 'debit' => $locked->balance_amount, 'credit' => 0, 'balance_after' => $balance, 'reference_type' => 'milk_sale', 'reference_id' => $locked->id, 'description' => 'Milk invoice '.$locked->invoice_number, 'created_by' => $r->user()->id]);
            $locked->forceFill(['status' => 'confirmed', 'confirmed_by' => $r->user()->id, 'confirmed_at' => now()])->save();

            return $locked->fresh(['customer', 'payments']);
        });
        if ($result === null) {
            return ApiResponse::error($r, 'INSUFFICIENT_SELLABLE_MILK', 'Sale quantity exceeds available sellable milk for this batch date.', 422);
        }

return ApiResponse::success($r, $this->payload($result));
    }

    public function pay(CustomerPaymentRequest $r, string $sale): JsonResponse
    {
        return $this->idempotency->execute($r, function () use ($r, $sale) {
            $d = $r->validated();
            $result = DB::transaction(function () use ($r, $sale, $d) {
                $s = MilkSale::with(['customer', 'payments'])->where('organization_id', $r->attributes->get('organization_id'))->where('farm_id', $r->attributes->get('api_session')->farm_id)->lockForUpdate()->findOrFail($sale);
                if (! in_array($s->status, ['confirmed', 'dispatched', 'delivered', 'partially_delivered'], true) || (float) $d['amount'] > (float) $s->balance_amount + 0.001) {
                    return null;
                }$c = Customer::lockForUpdate()->findOrFail($s->customer_id);
                $number = sprintf('CPAY-%06d', CustomerPayment::where('organization_id', $s->organization_id)->count() + 1);
                $p = CustomerPayment::create([...$d, 'organization_id' => $s->organization_id, 'farm_id' => $s->farm_id, 'customer_id' => $c->id, 'milk_sale_id' => $s->id, 'payment_number' => $number, 'created_by' => $r->user()->id]);
                $paid = (float) $s->paid_amount + (float) $d['amount'];
                $remaining = (float) $s->total_amount - $paid;
                $s->forceFill(['paid_amount' => $paid, 'balance_amount' => $remaining, 'payment_status' => $remaining < 0.005 ? 'paid' : 'partially_paid', 'payment_method' => $d['payment_method']])->save();
                $balance = max(0, (float) $c->current_balance - (float) $d['amount']);
                $c->forceFill(['current_balance' => $balance, 'version' => $c->version + 1, 'updated_by' => $r->user()->id])->save();
                CommercialLedgerEntry::create(['organization_id' => $s->organization_id, 'farm_id' => $s->farm_id, 'party_type' => 'customer', 'party_id' => $c->id, 'occurred_at' => $d['payment_date'], 'entry_type' => 'customer_payment', 'debit' => 0, 'credit' => $d['amount'], 'balance_after' => $balance, 'reference_type' => 'customer_payment', 'reference_id' => $p->id, 'description' => 'Customer payment '.$number, 'created_by' => $r->user()->id]);

                return $s->fresh(['customer', 'payments']);
            });
            if ($result === null) {
                return ApiResponse::error($r, 'INVALID_CUSTOMER_PAYMENT', 'Confirm the sale and do not pay more than its outstanding balance.', 422);
            }

return ApiResponse::success($r, $this->payload($result), 201);
        });
    }

    public function cancel(Request $r, string $sale): JsonResponse
    {
        $r->validate(['reason' => ['required', 'string', 'max:500']]);
        $model = $this->sale($r, $sale);
        if ($model->status !== 'confirmed' || (float) $model->paid_amount > 0) {
            return ApiResponse::error($r, 'SALE_CANNOT_BE_CANCELLED', 'Only unpaid confirmed sales can be cancelled.', 409);
        }$result = DB::transaction(function () use ($r, $model) {
            $s = MilkSale::with('customer')->lockForUpdate()->findOrFail($model->id);
            $c = Customer::lockForUpdate()->findOrFail($s->customer_id);
            MilkStockMovement::create(['organization_id' => $s->organization_id, 'farm_id' => $s->farm_id, 'milk_batch_date' => $s->milk_batch_date, 'milk_sale_id' => $s->id, 'movement_type' => 'sale_cancellation', 'quantity_change' => $s->quantity_litres, 'occurred_at' => now(), 'reason' => 'Cancelled milk sale '.$s->invoice_number, 'created_by' => $r->user()->id]);
            $balance = max(0, (float) $c->current_balance - (float) $s->balance_amount);
            $c->forceFill(['current_balance' => $balance, 'version' => $c->version + 1, 'updated_by' => $r->user()->id])->save();
            CommercialLedgerEntry::create(['organization_id' => $s->organization_id, 'farm_id' => $s->farm_id, 'party_type' => 'customer', 'party_id' => $c->id, 'occurred_at' => now(), 'entry_type' => 'milk_sale_cancellation', 'debit' => 0, 'credit' => $s->balance_amount, 'balance_after' => $balance, 'reference_type' => 'milk_sale', 'reference_id' => $s->id, 'description' => 'Cancelled milk invoice '.$s->invoice_number, 'created_by' => $r->user()->id]);
            $s->forceFill(['status' => 'cancelled', 'cancelled_by' => $r->user()->id, 'cancelled_at' => now(), 'cancellation_reason' => $r->input('reason')])->save();

            return $s->fresh(['customer', 'payments']);
        });

        return ApiResponse::success($r, $this->payload($result));
    }

    private function batches(Request $r): array
    {
        $dates = DB::table('milk_entries')->join('milk_production_slots', 'milk_production_slots.id', '=', 'milk_entries.milk_production_slot_id')->where('milk_entries.organization_id', $r->attributes->get('organization_id'))->where('milk_entries.farm_id', $r->attributes->get('api_session')->farm_id)->where('milk_entries.is_current', true)->select('milk_production_slots.production_date')->distinct()->orderByDesc('production_date')->limit(60)->pluck('production_date');

        return $dates->map(fn ($d) => ['date' => $d, 'available_sellable_litres' => number_format($this->available($r->attributes->get('organization_id'), $r->attributes->get('api_session')->farm_id, $d), 3, '.', '')])->all();
    }

    private function available(string $org, string $farm, string $date): float
    {
        $production = (float) DB::table('milk_entries')->join('milk_production_slots', 'milk_production_slots.id', '=', 'milk_entries.milk_production_slot_id')->where('milk_entries.organization_id', $org)->where('milk_entries.farm_id', $farm)->where('milk_entries.is_current', true)->whereDate('milk_production_slots.production_date', $date)->selectRaw('COALESCE(SUM(quantity_litres-rejected_quantity_litres),0) total')->value('total');
        $moves = (float) MilkStockMovement::where('organization_id', $org)->where('farm_id', $farm)->whereDate('milk_batch_date', $date)->sum('quantity_change');

        return $production + $moves;
    }

    private function sale(Request $r, string $id): MilkSale
    {
        return MilkSale::with(['customer', 'payments'])->where('organization_id', $r->attributes->get('organization_id'))->where('farm_id', $r->attributes->get('api_session')->farm_id)->findOrFail($id);
    }

    private function payload(MilkSale $s): array
    {
        return ['id' => $s->id, 'invoice_number' => $s->invoice_number, 'customer' => ['id' => $s->customer->id, 'code' => $s->customer->code, 'name' => $s->customer->name], 'sold_at' => $s->sold_at, 'milk_batch_date' => $s->milk_batch_date->toDateString(), 'quantity_litres' => $s->quantity_litres, 'base_rate' => $s->base_rate, 'total_amount' => $s->total_amount, 'paid_amount' => $s->paid_amount, 'balance_amount' => $s->balance_amount, 'payment_status' => $s->payment_status, 'status' => $s->status, 'delivery_status' => $s->delivery_status, 'currency' => 'PKR', 'payments' => $s->payments];
    }
}

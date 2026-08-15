<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Commerce\Models\GoodsReceipt;
use App\Domain\Commerce\Models\GoodsReceiptItem;
use App\Domain\Commerce\Models\PurchaseOrder;
use App\Domain\Commerce\Models\PurchaseOrderItem;
use App\Domain\Commerce\Models\Supplier;
use App\Domain\Inventory\Models\InventoryBatch;
use App\Domain\Inventory\Models\InventoryItem;
use App\Domain\Inventory\Models\StockMovement;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\GoodsReceiptRequest;
use App\Http\Requests\Api\V1\PurchaseOrderRequest;
use App\Models\Farm;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PurchaseOrderController extends Controller
{
    public function __construct(private AuditService $audit, private IdempotencyService $idempotency) {}

    public function index(Request $r): JsonResponse
    {
        $q = PurchaseOrder::with(['supplier', 'items.inventoryItem', 'receipts.items'])->where('organization_id', $r->attributes->get('organization_id'))->where('farm_id', $r->attributes->get('api_session')->farm_id);
        if ($r->filled('status')) {
            $q->where('status', $r->string('status'));
        }

        return ApiResponse::success($r, $q->latest('purchase_date')->get()->map(fn ($o) => $this->payload($o)));
    }

    public function store(PurchaseOrderRequest $r): JsonResponse
    {
        return $this->idempotency->execute($r, function () use ($r) {
            $d = $r->validated();
            $farm = $this->farm($r, $d['farm_id']);
            $supplier = Supplier::where('organization_id', $farm->organization_id)->where('farm_id', $farm->id)->where('is_active', true)->findOrFail($d['supplier_id']);
            $items = InventoryItem::where('organization_id', $farm->organization_id)->where('farm_id', $farm->id)->whereIn('id', collect($d['items'])->pluck('inventory_item_id'))->get()->keyBy('id');
            abort_unless($items->count() === count($d['items']), 422);
            $order = DB::transaction(function () use ($d, $farm, $r) {
                $subtotal = collect($d['items'])->sum(fn ($i) => (float) $i['quantity'] * (float) $i['unit_rate']);
                $total = max(0, $subtotal - (float) ($d['discount'] ?? 0) + (float) ($d['tax'] ?? 0) + (float) ($d['transport_cost'] ?? 0) + (float) ($d['other_cost'] ?? 0));
                $seq = PurchaseOrder::withTrashed()->where('organization_id', $farm->organization_id)->lockForUpdate()->count() + 1;
                $o = PurchaseOrder::create([...collect($d)->except('items')->all(), 'organization_id' => $farm->organization_id, 'purchase_number' => sprintf('PO-%06d', $seq), 'status' => 'draft', 'subtotal' => $subtotal, 'total' => $total, 'created_by' => $r->user()->id, 'updated_by' => $r->user()->id]);
                foreach ($d['items'] as $i) {
                    PurchaseOrderItem::create(['purchase_order_id' => $o->id, 'inventory_item_id' => $i['inventory_item_id'], 'ordered_quantity' => $i['quantity'], 'unit_rate' => $i['unit_rate'], 'line_total' => (float) $i['quantity'] * (float) $i['unit_rate']]);
                }$this->audit->record($r, 'purchase_order.created', 'purchase_order', $o->id, null, ['purchase_number' => $o->purchase_number, 'total' => $total]);

                return $o;
            });

            return ApiResponse::success($r, $this->payload($order->load(['supplier', 'items.inventoryItem', 'receipts.items'])), 201);
        });
    }

    public function approve(Request $r, string $order): JsonResponse
    {
        $o = $this->order($r, $order);
        if ($o->status !== 'draft') {
            return ApiResponse::error($r, 'INVALID_PURCHASE_STATUS', 'Only draft purchase orders can be approved.', 409);
        }$o->forceFill(['status' => 'approved', 'approved_by' => $r->user()->id, 'approved_at' => now(), 'version' => $o->version + 1, 'updated_by' => $r->user()->id])->save();
        $this->audit->record($r, 'purchase_order.approved', 'purchase_order', $o->id, ['status' => 'draft'], ['status' => 'approved']);

        return ApiResponse::success($r, $this->payload($o->load(['supplier', 'items.inventoryItem', 'receipts.items'])));
    }

    public function receive(GoodsReceiptRequest $r, string $order): JsonResponse
    {
        $o = $this->order($r, $order);

        return $this->idempotency->execute($r, function () use ($r, $o) {
            if (! in_array($o->status, ['approved', 'partially_received'], true)) {
                return ApiResponse::error($r, 'INVALID_PURCHASE_STATUS', 'Approve the purchase order before receiving goods.', 409);
            }$d = $r->validated();
            if ($d['quality_status'] === 'rejected') {
                return ApiResponse::error($r, 'QUALITY_REJECTED', 'Rejected goods cannot be added to inventory.', 422);
            }$receipt = DB::transaction(function () use ($r, $o, $d) {
                $locked = PurchaseOrder::lockForUpdate()->findOrFail($o->id);
                $lines = PurchaseOrderItem::where('purchase_order_id', $locked->id)->whereIn('id', collect($d['items'])->pluck('purchase_order_item_id'))->lockForUpdate()->get()->keyBy('id');
                abort_unless($lines->count() === count($d['items']), 422);
                $number = sprintf('GRN-%06d', GoodsReceipt::where('organization_id', $locked->organization_id)->lockForUpdate()->count() + 1);
                $gr = GoodsReceipt::create(['organization_id' => $locked->organization_id, 'farm_id' => $locked->farm_id, 'purchase_order_id' => $locked->id, 'receipt_number' => $number, 'received_at' => $d['received_at'] ?? now(), 'quality_status' => $d['quality_status'], 'notes' => $d['notes'] ?? null, 'received_by' => $r->user()->id]);
                foreach ($d['items'] as $input) {
                    $line = $lines[$input['purchase_order_item_id']];
                    $remaining = (float) $line->ordered_quantity - (float) $line->received_quantity;
                    abort_if((float) $input['quantity'] > $remaining + 0.000001, 422, 'Received quantity exceeds the outstanding purchase quantity.');
                    $item = InventoryItem::lockForUpdate()->findOrFail($line->inventory_item_id);
                    $batch = InventoryBatch::where('inventory_item_id', $item->id)->where('batch_number', $input['batch_number'])->lockForUpdate()->first() ?? InventoryBatch::create(['organization_id' => $item->organization_id, 'farm_id' => $item->farm_id, 'inventory_item_id' => $item->id, 'batch_number' => $input['batch_number'], 'supplier' => $locked->supplier->name, 'purchase_date' => $locked->purchase_date, 'expiry_date' => $input['expiry_date'] ?? null, 'unit_cost' => $line->unit_rate, 'current_quantity' => 0]);
                    $batch->forceFill(['supplier' => $locked->supplier->name, 'purchase_date' => $locked->purchase_date, 'expiry_date' => $input['expiry_date'] ?? $batch->expiry_date, 'unit_cost' => $line->unit_rate, 'current_quantity' => (float) $batch->current_quantity + (float) $input['quantity'], 'version' => $batch->version + 1])->save();
                    $line->forceFill(['received_quantity' => (float) $line->received_quantity + (float) $input['quantity']])->save();
                    $item->forceFill(['version' => $item->version + 1, 'updated_by' => $r->user()->id])->save();
                    $movement = StockMovement::create(['organization_id' => $item->organization_id, 'farm_id' => $item->farm_id, 'inventory_item_id' => $item->id, 'inventory_batch_id' => $batch->id, 'movement_type' => 'purchase_receipt', 'quantity_change' => $input['quantity'], 'unit_cost' => $line->unit_rate, 'occurred_at' => $gr->received_at, 'reason' => 'Goods receipt '.$number, 'reference_type' => 'goods_receipt', 'reference_id' => $gr->id, 'created_by' => $r->user()->id]);
                    GoodsReceiptItem::create(['goods_receipt_id' => $gr->id, 'purchase_order_item_id' => $line->id, 'inventory_batch_id' => $batch->id, 'stock_movement_id' => $movement->id, 'batch_number' => $input['batch_number'], 'expiry_date' => $input['expiry_date'] ?? null, 'quantity' => $input['quantity'], 'unit_cost' => $line->unit_rate]);
                }$complete = ! PurchaseOrderItem::where('purchase_order_id', $locked->id)->whereColumn('received_quantity', '<', 'ordered_quantity')->exists();
                $locked->forceFill(['status' => $complete ? 'received' : 'partially_received', 'version' => $locked->version + 1, 'updated_by' => $r->user()->id])->save();
                $this->audit->record($r, 'purchase_order.goods_received', 'goods_receipt', $gr->id, null, ['purchase_order_id' => $locked->id, 'receipt_number' => $number]);

                return $gr;
            });

            return ApiResponse::success($r, ['receipt_number' => $receipt->receipt_number, 'purchase_order' => $this->payload($receipt->purchaseOrder->load(['supplier', 'items.inventoryItem', 'receipts.items']))], 201);
        });
    }

    private function payload(PurchaseOrder $o): array
    {
        return ['id' => $o->id, 'purchase_number' => $o->purchase_number, 'farm_id' => $o->farm_id, 'supplier' => ['id' => $o->supplier->id, 'code' => $o->supplier->code, 'name' => $o->supplier->name], 'purchase_date' => $o->purchase_date->toDateString(), 'expected_date' => $o->expected_date?->toDateString(), 'status' => $o->status, 'subtotal' => $o->subtotal, 'discount' => $o->discount, 'tax' => $o->tax, 'transport_cost' => $o->transport_cost, 'other_cost' => $o->other_cost, 'total' => $o->total, 'currency' => 'PKR', 'notes' => $o->notes, 'version' => $o->version, 'items' => $o->items->map(fn ($i) => ['id' => $i->id, 'inventory_item_id' => $i->inventory_item_id, 'item_name' => $i->inventoryItem->name, 'unit' => $i->inventoryItem->unit, 'ordered_quantity' => $i->ordered_quantity, 'received_quantity' => $i->received_quantity, 'unit_rate' => $i->unit_rate, 'line_total' => $i->line_total]), 'receipts' => $o->receipts->map(fn ($g) => ['id' => $g->id, 'receipt_number' => $g->receipt_number, 'received_at' => $g->received_at, 'quality_status' => $g->quality_status])];
    }

    private function farm(Request $r, string $id): Farm
    {
        $f = Farm::where('organization_id', $r->attributes->get('organization_id'))->findOrFail($id);
        abort_unless($r->attributes->get('membership')->canAccessFarm($id), 404);

        return $f;
    }

    private function order(Request $r, string $id): PurchaseOrder
    {
        $o = PurchaseOrder::with('supplier')->where('organization_id', $r->attributes->get('organization_id'))->findOrFail($id);
        abort_unless($r->attributes->get('membership')->canAccessFarm($o->farm_id), 404);

        return $o;
    }
}

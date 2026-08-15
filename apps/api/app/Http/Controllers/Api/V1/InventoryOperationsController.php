<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Inventory\Models\InventoryBatch;
use App\Domain\Inventory\Models\InventoryItem;
use App\Domain\Inventory\Models\InventoryTransfer;
use App\Domain\Inventory\Models\StockMovement;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\InventoryAdjustmentRequest;
use App\Http\Requests\Api\V1\InventoryTransferRequest;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class InventoryOperationsController extends Controller
{
    public function __construct(private readonly IdempotencyService $idempotency, private readonly AuditService $audit) {}

    public function adjustments(InventoryAdjustmentRequest $r, string $item): JsonResponse
    {
        $model = $this->item($r, $item);

        return $this->idempotency->execute($r, function () use ($r, $model) {
            $d = $r->validated();
            $movement = DB::transaction(function () use ($r, $model, $d) {
                $batch = InventoryBatch::where('inventory_item_id', $model->id)->lockForUpdate()->findOrFail($d['batch_id']);
                $qty = (float) $d['quantity'];
                $negative = $d['adjustment_type'] !== 'increase';
                if ($negative && (float) $batch->current_quantity + .000001 < $qty) {
                    return null;
                }$change = $negative ? -$qty : $qty;
                $batch->forceFill(['current_quantity' => (float) $batch->current_quantity + $change, 'version' => $batch->version + 1])->save();
                $model->increment('version');
                $type = match ($d['adjustment_type']) {
                    'damage' => 'damage','expiry' => 'expiry',default => 'adjustment'
                };
                $m = StockMovement::create(['organization_id' => $model->organization_id, 'farm_id' => $model->farm_id, 'inventory_item_id' => $model->id, 'inventory_batch_id' => $batch->id, 'movement_type' => $type, 'quantity_change' => $change, 'unit_cost' => $batch->unit_cost, 'occurred_at' => $d['occurred_at'], 'reason' => $d['reason'], 'created_by' => $r->user()->id]);
                $this->audit->record($r, 'inventory.stock_adjusted', 'stock_movement', $m->id, null, ['item_id' => $model->id, 'batch_id' => $batch->id, 'change' => $change, 'reason' => $d['reason']]);

                return $m;
            });

            return $movement ? ApiResponse::success($r, $movement, 201) : ApiResponse::error($r, 'INSUFFICIENT_STOCK', 'Adjustment would create negative stock.', 422);
        });
    }

    public function transfers(InventoryTransferRequest $r, string $item): JsonResponse
    {
        $source = $this->item($r, $item);
        abort_unless($r->attributes->get('membership')->canAccessFarm($r->validated('destination_farm_id')), 404);

        return $this->idempotency->execute($r, function () use ($r, $source) {
            $d = $r->validated();
            $org = $source->organization_id;
            $destination = InventoryItem::withTrashed()->where('organization_id', $org)->where('farm_id', $d['destination_farm_id'])->where('kind', $source->kind)->where('item_code', $source->item_code)->first();
            if (! $destination) {
                return ApiResponse::error($r, 'DESTINATION_ITEM_REQUIRED', 'Create the same item code at the destination farm first.', 422);
            }$qty = (float) $d['quantity'];
            $result = DB::transaction(function () use ($r, $source, $destination, $d, $qty, $org) {
                $batches = InventoryBatch::where('inventory_item_id', $source->id)->where('current_quantity', '>', 0)->orderByRaw('CASE WHEN expiry_date IS NULL THEN 1 ELSE 0 END')->orderBy('expiry_date')->lockForUpdate()->get();
                if ($batches->sum(fn ($b) => (float) $b->current_quantity) + .000001 < $qty) {
                    return null;
                }$number = 'TF-'.str_pad((string) (InventoryTransfer::where('organization_id', $org)->lockForUpdate()->count() + 1), 6, '0', STR_PAD_LEFT);
                $left = $qty;
                foreach ($batches as $b) {
                    if ($left <= 0) {
                        break;
                    }$moved = min($left, (float) $b->current_quantity);
                    $b->decrement('current_quantity', $moved);
                    $db = InventoryBatch::firstOrCreate(['inventory_item_id' => $destination->id, 'batch_number' => $b->batch_number], ['organization_id' => $org, 'farm_id' => $destination->farm_id, 'supplier' => $b->supplier, 'purchase_date' => $b->purchase_date, 'expiry_date' => $b->expiry_date, 'unit_cost' => $b->unit_cost, 'current_quantity' => 0]);
                    $db->increment('current_quantity', $moved);
                    foreach ([[$source, $b, 'issue', -$moved], [$destination, $db, 'return', $moved]] as [$i,$batch,$type,$change]) {
                        StockMovement::create(['organization_id' => $org, 'farm_id' => $i->farm_id, 'inventory_item_id' => $i->id, 'inventory_batch_id' => $batch->id, 'movement_type' => $type, 'quantity_change' => $change, 'unit_cost' => $b->unit_cost, 'occurred_at' => $d['transferred_at'], 'reason' => "Transfer $number: {$d['reason']}", 'created_by' => $r->user()->id]);
                    }$left -= $moved;
                }$t = InventoryTransfer::create(['organization_id' => $org, 'source_farm_id' => $source->farm_id, 'destination_farm_id' => $destination->farm_id, 'source_item_id' => $source->id, 'destination_item_id' => $destination->id, 'transfer_number' => $number, 'quantity' => $qty, 'unit' => $source->unit, 'transferred_at' => $d['transferred_at'], 'reason' => $d['reason'], 'created_by' => $r->user()->id]);
                $this->audit->record($r, 'inventory.stock_transferred', 'inventory_transfer', $t->id, null, $t->toArray());

                return $t;
            });

            return $result ? ApiResponse::success($r, $result, 201) : ApiResponse::error($r, 'INSUFFICIENT_STOCK', 'Transfer would create negative stock.', 422);
        });
    }

    private function item(Request $r, string $id): InventoryItem
    {
        return InventoryItem::where('organization_id', $r->attributes->get('organization_id'))->where('farm_id', $r->attributes->get('api_session')->farm_id)->findOrFail($id);
    }
}

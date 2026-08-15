<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Commerce\Models\Customer;
use App\Domain\Commerce\Models\CustomerRefund;
use App\Domain\Commerce\Models\DeliveryDriver;
use App\Domain\Commerce\Models\DeliveryManifest;
use App\Domain\Commerce\Models\DeliveryManifestStop;
use App\Domain\Commerce\Models\DeliveryRoute;
use App\Domain\Commerce\Models\DeliveryRouteStop;
use App\Domain\Commerce\Models\DeliveryVehicle;
use App\Domain\Commerce\Models\MilkSale;
use App\Domain\Commerce\Models\MilkSaleReturn;
use App\Domain\Commerce\Models\MilkStockMovement;
use App\Domain\Commerce\Models\CommercialLedgerEntry;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use App\Domain\Commerce\Support\DeliveryDocumentService;
use App\Models\Farm;
use App\Models\OrganizationMembership;
use App\Http\Requests\Api\V1\DeliveryExportRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Validation\Rule;

class DeliveryController extends Controller
{
    public function __construct(private IdempotencyService $idempotency, private AuditService $audit, private DeliveryDocumentService $documents) {}

    public function overview(Request $r): JsonResponse
    {
        $scope = ['organization_id' => $r->attributes->get('organization_id'), 'farm_id' => $r->attributes->get('api_session')->farm_id];
        $routes = DeliveryRoute::with('stops.customer')->where($scope)->where('is_active', true)->get();
        $vehicles = DeliveryVehicle::where($scope)->where('is_active', true)->get();
        $drivers = DeliveryDriver::where($scope)->where('is_active', true)->get();
        $manifests = DeliveryManifest::with(['route', 'vehicle', 'driver', 'stops.customer', 'stops.sale', 'stops.saleReturn'])->where($scope)->latest('delivery_date')->get();
        $sales = MilkSale::with('customer')->where($scope)->where('status', 'confirmed')->whereIn('delivery_status', ['pending', 'partially_delivered'])->whereDoesntHave('deliveryManifestStop')->get();

        return ApiResponse::success($r, ['routes' => $routes, 'vehicles' => $vehicles, 'drivers' => $drivers, 'eligible_sales' => $sales, 'manifests' => $manifests]);
    }

    public function routeStore(Request $r): JsonResponse
    {
        $d = $r->validate(['name' => ['required', 'string', 'max:160'], 'description' => ['nullable', 'string', 'max:2000'], 'stops' => ['required', 'array', 'min:1'], 'stops.*.customer_id' => ['required', 'uuid', 'distinct'], 'stops.*.delivery_address' => ['nullable', 'string', 'max:500'], 'stops.*.planned_time' => ['nullable', 'date_format:H:i']]);

        return $this->idempotency->execute($r, function () use ($r, $d) {
            $scope = ['organization_id' => $r->attributes->get('organization_id'), 'farm_id' => $r->attributes->get('api_session')->farm_id];
            $customers = Customer::where($scope)->whereIn('id', collect($d['stops'])->pluck('customer_id'))->get();
            abort_unless($customers->count() === count($d['stops']), 422);
            $route = DB::transaction(function () use ($d, $scope) {
                $route = DeliveryRoute::create([...$scope, 'code' => sprintf('RTE-%04d', DeliveryRoute::where('organization_id', $scope['organization_id'])->count() + 1), 'name' => $d['name'], 'description' => $d['description'] ?? null]);
                foreach ($d['stops'] as $i => $s) {
                    DeliveryRouteStop::create([...$s, 'delivery_route_id' => $route->id, 'stop_order' => $i + 1]);
                }

return $route;
            });

            return ApiResponse::success($r, $route->load('stops.customer'), 201);
        });
    }

    public function vehicleStore(Request $r): JsonResponse
    {
        $d = $r->validate(['registration_number' => ['required', 'string', 'max:80'], 'description' => ['nullable', 'string', 'max:160'], 'capacity_litres' => ['required', 'numeric', 'gt:0']]);
        $scope = ['organization_id' => $r->attributes->get('organization_id'), 'farm_id' => $r->attributes->get('api_session')->farm_id];
        $m = DeliveryVehicle::create([...$d, ...$scope, 'code' => sprintf('VEH-%04d', DeliveryVehicle::where('organization_id', $scope['organization_id'])->count() + 1)]);

        return ApiResponse::success($r, $m, 201);
    }

    public function driverStore(Request $r): JsonResponse
    {
        $d = $r->validate(['name' => ['required', 'string', 'max:160'], 'phone' => ['nullable', 'string', 'max:40'], 'license_number' => ['nullable', 'string', 'max:100']]);
        $scope = ['organization_id' => $r->attributes->get('organization_id'), 'farm_id' => $r->attributes->get('api_session')->farm_id];
        $m = DeliveryDriver::create([...$d, ...$scope, 'code' => sprintf('DRV-%04d', DeliveryDriver::where('organization_id', $scope['organization_id'])->count() + 1)]);

        return ApiResponse::success($r, $m, 201);
    }

    public function manifestStore(Request $r): JsonResponse
    {
        $d = $r->validate(['delivery_route_id' => ['required', 'uuid'], 'delivery_vehicle_id' => ['required', 'uuid'], 'delivery_driver_id' => ['required', 'uuid'], 'delivery_date' => ['required', 'date'], 'milk_sale_ids' => ['required', 'array', 'min:1'], 'milk_sale_ids.*' => ['uuid', 'distinct'], 'notes' => ['nullable', 'string', 'max:2000']]);

        return $this->idempotency->execute($r, function () use ($r, $d) {
            $scope = ['organization_id' => $r->attributes->get('organization_id'), 'farm_id' => $r->attributes->get('api_session')->farm_id];
            $route = DeliveryRoute::with('stops')->where($scope)->findOrFail($d['delivery_route_id']);
            $vehicle = DeliveryVehicle::where($scope)->findOrFail($d['delivery_vehicle_id']);
            DeliveryDriver::where($scope)->findOrFail($d['delivery_driver_id']);
            $sales = MilkSale::where($scope)->whereIn('id', $d['milk_sale_ids'])->where('status', 'confirmed')->where('delivery_status', 'pending')->get();
            abort_unless($sales->count() === count($d['milk_sale_ids']), 422);
            $stops = $route->stops->keyBy('customer_id');
            abort_unless($sales->every(fn ($s) => $stops->has($s->customer_id)), 422);
            $planned = $sales->sum('quantity_litres');
            abort_if($planned > (float) $vehicle->capacity_litres, 422, 'Planned milk exceeds vehicle capacity.');
            $m = DB::transaction(function () use ($r, $d, $scope, $sales, $stops, $planned) {
                $m = DeliveryManifest::create([...$scope, ...collect($d)->except('milk_sale_ids')->all(), 'delivery_number' => sprintf('DEL-%06d', DeliveryManifest::where('organization_id', $scope['organization_id'])->count() + 1), 'planned_quantity' => $planned, 'created_by' => $r->user()->id]);
                foreach ($sales as $s) {
                    $stop = $stops[$s->customer_id];
                    DeliveryManifestStop::create(['delivery_manifest_id' => $m->id, 'delivery_route_stop_id' => $stop->id, 'milk_sale_id' => $s->id, 'customer_id' => $s->customer_id, 'stop_order' => $stop->stop_order, 'planned_quantity' => $s->quantity_litres]);
                }

return $m;
            });

            return ApiResponse::success($r, $this->manifest($m), 201);
        });
    }

    public function dispatch(Request $r, string $id): JsonResponse
    {
        $m = $this->find($r, $id);
        $d = $r->validate(['loaded_quantity' => ['required', 'numeric', 'gt:0']]);
        if ($m->status !== 'scheduled' || (float) $d['loaded_quantity'] > (float) $m->planned_quantity) {
            return ApiResponse::error($r, 'INVALID_DISPATCH', 'Only scheduled deliveries can be dispatched and loading cannot exceed planned milk.', 409);
        }$m->update(['status' => 'dispatched', 'loaded_quantity' => $d['loaded_quantity']]);
        $m->stops()->update(['status' => 'dispatched']);
        MilkSale::whereIn('id', $m->stops->pluck('milk_sale_id'))->update(['delivery_status' => 'dispatched']);

        return ApiResponse::success($r, $this->manifest($m));
    }

    public function completeStop(Request $r, string $id, string $stop): JsonResponse
    {
        $m = $this->find($r, $id);
        if ($m->status !== 'dispatched') {
            return ApiResponse::error($r, 'INVALID_DELIVERY_STATUS', 'Dispatch the manifest before completing stops.', 409);
        }$s = $m->stops()->whereKey($stop)->firstOrFail();
        $d = $r->validate(['status' => ['required', Rule::in(['delivered', 'partially_delivered', 'failed'])], 'delivered_quantity' => ['required', 'numeric', 'min:0'], 'returned_quantity' => ['sometimes', 'numeric', 'min:0'], 'rejected_quantity' => ['sometimes', 'numeric', 'min:0'], 'restocked_quantity' => ['sometimes', 'numeric', 'min:0'], 'return_reason' => ['nullable', 'string', 'max:500'], 'acknowledged_by' => ['nullable', 'string', 'max:160'], 'gps_latitude' => ['nullable', 'numeric', 'between:-90,90'], 'gps_longitude' => ['nullable', 'numeric', 'between:-180,180'], 'notes' => ['nullable', 'string', 'max:2000']]);
        $accounted = (float) $d['delivered_quantity'] + (float) ($d['returned_quantity'] ?? 0) + (float) ($d['rejected_quantity'] ?? 0);
        if (abs($accounted - (float) $s->planned_quantity) > 0.001) {
            return ApiResponse::error($r, 'DELIVERY_QUANTITY_MISMATCH', 'Delivered, returned, and rejected quantities must equal planned quantity.', 422);
        }$undelivered = (float) ($d['returned_quantity'] ?? 0) + (float) ($d['rejected_quantity'] ?? 0);
        $restocked = (float) ($d['restocked_quantity'] ?? 0);
        if ($restocked > (float) ($d['returned_quantity'] ?? 0) + 0.001 || ($undelivered > 0 && empty($d['return_reason']))) {
            return ApiResponse::error($r, 'INVALID_RETURN_DISPOSITION', 'A reason is required and only returned milk may be restored to sellable stock.', 422);
        }
        DB::transaction(function () use ($r, $s, $d, $undelivered, $restocked): void {
            $sale = MilkSale::with('customer')->lockForUpdate()->findOrFail($s->milk_sale_id);
            $stop = DeliveryManifestStop::lockForUpdate()->findOrFail($s->id);
            $stop->update([...collect($d)->except(['restocked_quantity', 'return_reason'])->all(), 'delivered_at' => now()]);
            if ($undelivered <= 0) return;
            $grossCredit = round($undelivered * (float) $sale->total_amount / (float) $sale->quantity_litres, 2);
            $credit = min($grossCredit, (float) $sale->balance_amount);
            $refundDue = max(0, $grossCredit - $credit);
            $customer = Customer::lockForUpdate()->findOrFail($sale->customer_id);
            $balance = max(0, (float) $customer->current_balance - $credit);
            $return = MilkSaleReturn::create(['organization_id' => $sale->organization_id, 'farm_id' => $sale->farm_id, 'milk_sale_id' => $sale->id, 'delivery_manifest_stop_id' => $stop->id, 'return_number' => sprintf('SRET-%06d', MilkSaleReturn::where('organization_id', $sale->organization_id)->count() + 1), 'returned_quantity' => $d['returned_quantity'] ?? 0, 'rejected_quantity' => $d['rejected_quantity'] ?? 0, 'restocked_quantity' => $restocked, 'disposed_quantity' => $undelivered - $restocked, 'credit_amount' => $grossCredit, 'refund_due' => $refundDue, 'refund_status' => $refundDue > 0 ? 'pending' : 'not_required', 'reason' => $d['return_reason'], 'created_by' => $r->user()->id]);
            if ($restocked > 0) MilkStockMovement::create(['organization_id' => $sale->organization_id, 'farm_id' => $sale->farm_id, 'milk_batch_date' => $sale->milk_batch_date, 'milk_sale_id' => $sale->id, 'movement_type' => 'sale_return', 'quantity_change' => $restocked, 'occurred_at' => now(), 'reason' => 'Reusable delivery return '.$return->return_number, 'created_by' => $r->user()->id]);
            $sale->forceFill(['balance_amount' => max(0, (float) $sale->balance_amount - $credit), 'total_amount' => max(0, (float) $sale->total_amount - $grossCredit), 'payment_status' => $refundDue > 0 ? 'refund_due' : ((float) $sale->balance_amount - $credit < .005 ? 'paid' : $sale->payment_status)])->save();
            $customer->forceFill(['current_balance' => $balance, 'version' => $customer->version + 1, 'updated_by' => $r->user()->id])->save();
            if ($credit > 0) CommercialLedgerEntry::create(['organization_id' => $sale->organization_id, 'farm_id' => $sale->farm_id, 'party_type' => 'customer', 'party_id' => $customer->id, 'occurred_at' => now(), 'entry_type' => 'milk_sale_return', 'debit' => 0, 'credit' => $credit, 'balance_after' => $balance, 'reference_type' => 'milk_sale_return', 'reference_id' => $return->id, 'description' => 'Delivery return '.$return->return_number, 'created_by' => $r->user()->id]);
        });
        $saleStatus = $d['status'] === 'delivered' ? 'delivered' : ($d['status'] === 'partially_delivered' ? 'partially_delivered' : 'failed');
        $s->sale()->update(['delivery_status' => $saleStatus]);
        $remaining = $m->stops()->whereIn('status', ['scheduled', 'dispatched'])->exists();
        if (! $remaining) {
            $m->update(['status' => $m->stops()->where('status', '!=', 'delivered')->exists() ? 'partially_delivered' : 'delivered', 'delivered_quantity' => $m->stops()->sum('delivered_quantity'), 'returned_quantity' => $m->stops()->sum('returned_quantity'), 'rejected_quantity' => $m->stops()->sum('rejected_quantity')]);
        }

return ApiResponse::success($r, $this->manifest($m));
    }

    public function uploadProof(Request $r, string $id, string $stop): JsonResponse
    {
        $m = $this->find($r, $id);
        $s = $m->stops()->whereKey($stop)->firstOrFail();
        $r->validate(['proof' => ['required', 'file', 'image', 'mimes:jpeg,jpg,png,webp', 'max:8192']]);
        $file = $r->file('proof');
        $path = $file->store("organizations/{$m->organization_id}/delivery-proofs", 'local');
        if ($s->proof_storage_path) Storage::disk('local')->delete($s->proof_storage_path);
        $s->update(['proof_storage_path' => $path, 'proof_original_name' => $file->getClientOriginalName(), 'proof_mime_type' => $file->getMimeType()]);
        return ApiResponse::success($r, ['has_proof' => true], 201);
    }

    public function proof(Request $r, string $id, string $stop): StreamedResponse
    {
        $s = $this->find($r, $id)->stops()->whereKey($stop)->firstOrFail();
        abort_unless($s->proof_storage_path && Storage::disk('local')->exists($s->proof_storage_path), 404);
        return Storage::disk('local')->download($s->proof_storage_path, $s->proof_original_name, ['Content-Type' => $s->proof_mime_type]);
    }

    public function refund(Request $r, string $id, string $stop): JsonResponse
    {
        $d = $r->validate(['amount' => ['required', 'numeric', 'gt:0'], 'refund_date' => ['required', 'date'], 'payment_method' => ['required', Rule::in(['cash', 'bank_transfer', 'cheque', 'mobile_wallet', 'other'])], 'reference' => ['nullable', 'string', 'max:160'], 'notes' => ['nullable', 'string', 'max:2000']]);
        return $this->idempotency->execute($r, function () use ($r, $id, $stop, $d) {
            $s = $this->find($r, $id)->stops()->whereKey($stop)->firstOrFail();
            $refund = DB::transaction(function () use ($r, $s, $d) {
                $return = MilkSaleReturn::lockForUpdate()->where('delivery_manifest_stop_id', $s->id)->firstOrFail();
                $remaining = (float) $return->refund_due - (float) $return->refunded_amount;
                abort_if((float) $d['amount'] > $remaining + .001, 422, 'Refund exceeds the outstanding return amount.');
                $sale = MilkSale::lockForUpdate()->findOrFail($return->milk_sale_id);
                $row = CustomerRefund::create([...$d, 'organization_id' => $return->organization_id, 'farm_id' => $return->farm_id, 'customer_id' => $sale->customer_id, 'milk_sale_id' => $sale->id, 'milk_sale_return_id' => $return->id, 'refund_number' => sprintf('CREF-%06d', CustomerRefund::where('organization_id', $return->organization_id)->count() + 1), 'created_by' => $r->user()->id]);
                $refunded = (float) $return->refunded_amount + (float) $d['amount'];
                $complete = $refunded >= (float) $return->refund_due - .005;
                $return->update(['refunded_amount' => $refunded, 'refund_status' => $complete ? 'refunded' : 'partially_refunded']);
                $sale->forceFill(['paid_amount' => max(0, (float) $sale->paid_amount - (float) $d['amount']), 'payment_status' => $complete ? 'paid' : 'refund_due'])->save();
                CommercialLedgerEntry::create(['organization_id' => $return->organization_id, 'farm_id' => $return->farm_id, 'party_type' => 'customer', 'party_id' => $sale->customer_id, 'occurred_at' => $d['refund_date'], 'entry_type' => 'customer_refund', 'debit' => 0, 'credit' => 0, 'balance_after' => $sale->customer()->value('current_balance'), 'reference_type' => 'customer_refund', 'reference_id' => $row->id, 'description' => 'Cash refund '.$row->refund_number.' PKR '.$row->amount, 'created_by' => $r->user()->id]);
                return $row;
            });
            return ApiResponse::success($r, $refund, 201);
        });
    }

    public function deliveryNote(Request $r, string $id): Response
    {
        $manifest = $this->find($r, $id)->load(['route', 'vehicle', 'driver', 'stops.customer', 'stops.sale']);
        [$farm, $owner] = $this->identity($r);
        $this->audit->record($r, 'delivery.note_downloaded', 'delivery_manifest', $manifest->id);
        return $this->pdf($this->documents->pdf('deliveries.document', ['title' => 'Milk delivery note', 'farm' => $farm, 'owner' => $owner, 'manifest' => $manifest, 'refund' => null]), $manifest->delivery_number.'-delivery-note.pdf');
    }

    public function refundReceipt(Request $r, string $refund): Response
    {
        [$farm, $owner] = $this->identity($r);
        $row = CustomerRefund::with(['customer', 'sale', 'saleReturn'])->where('organization_id', $farm->organization_id)->where('farm_id', $farm->id)->findOrFail($refund);
        $this->audit->record($r, 'customer_refund.receipt_downloaded', 'customer_refund', $row->id);
        return $this->pdf($this->documents->pdf('deliveries.document', ['title' => 'Customer refund receipt', 'farm' => $farm, 'owner' => $owner, 'manifest' => null, 'refund' => $row]), $row->refund_number.'-refund-receipt.pdf');
    }

    public function export(DeliveryExportRequest $r): Response
    {
        [$farm, $owner] = $this->identity($r);
        $d = $r->validated();
        $rows = DeliveryManifest::with(['route', 'vehicle', 'driver', 'stops.customer', 'stops.sale', 'stops.saleReturn.refunds'])
            ->where('organization_id', $farm->organization_id)->where('farm_id', $farm->id)
            ->when($d['from_date'] ?? null, fn ($q, $v) => $q->whereDate('delivery_date', '>=', $v))
            ->when($d['to_date'] ?? null, fn ($q, $v) => $q->whereDate('delivery_date', '<=', $v))
            ->when($d['status'] ?? null, fn ($q, $v) => $q->where('status', $v))
            ->orderBy('delivery_date')->orderBy('delivery_number')->get();
        $this->audit->record($r, 'delivery.history_exported', 'delivery_export', null, null, ['count' => $rows->count(), ...$d]);
        return response($this->documents->xlsx($farm, $owner, $rows, $d['from_date'] ?? null, $d['to_date'] ?? null, $d['status'] ?? null), 200, ['Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'Content-Disposition' => 'attachment; filename="dairycare-delivery-history.xlsx"']);
    }

    private function identity(Request $r): array
    {
        $farm = Farm::where('organization_id', $r->attributes->get('organization_id'))->findOrFail($r->attributes->get('api_session')->farm_id);
        $owner = OrganizationMembership::with('user')->where('organization_id', $farm->organization_id)->where('membership_type', 'primary_owner')->where('status', 'active')->first()?->user;
        return [$farm, $owner];
    }

    private function pdf(string $contents, string $name): Response
    {
        return response($contents, 200, ['Content-Type' => 'application/pdf', 'Content-Disposition' => 'attachment; filename="'.$name.'"']);
    }

    private function find(Request $r, string $id): DeliveryManifest
    {
        return DeliveryManifest::with('stops.sale')->where('organization_id', $r->attributes->get('organization_id'))->where('farm_id',$r->attributes->get('api_session')->farm_id)->findOrFail($id);
    }

    private function manifest(DeliveryManifest $m): array
    {
        return $m->fresh(['route', 'vehicle', 'driver', 'stops.customer', 'stops.sale', 'stops.saleReturn'])->toArray();
    }
}

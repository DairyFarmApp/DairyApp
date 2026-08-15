<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Commerce\Models\CommercialLedgerEntry;
use App\Domain\Commerce\Models\Supplier;
use App\Domain\Commerce\Support\CommercialPartyService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\SupplierRequest;
use App\Http\Resources\Api\V1\SupplierResource;
use App\Models\Farm;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SupplierController extends Controller
{
    public function __construct(private AuditService $audit, private IdempotencyService $idempotency, private CommercialPartyService $parties) {}

    public function index(Request $request): JsonResponse
    {
        $membership = $request->attributes->get('membership');
        $query = Supplier::query()->where('organization_id', $request->attributes->get('organization_id'));
        if (! $membership->all_farms) {
            $query->whereIn('farm_id', $membership->farms()->pluck('farms.id'));
        }
        if (! $request->boolean('include_inactive')) {
            $query->where('is_active', true);
        }
        if ($request->filled('search')) {
            $query->where(fn ($q) => $q->where('name', 'like', '%'.$request->string('search').'%')->orWhere('code', 'like', '%'.$request->string('search').'%'));
        }

        return ApiResponse::success($request, SupplierResource::collection($query->orderBy('name')->get())->resolve($request));
    }

    public function store(SupplierRequest $request): JsonResponse
    {
        return $this->idempotency->execute($request, function () use ($request): JsonResponse {
            $data = $request->validated();
            $farm = $this->farm($request, $data['farm_id']);
            $actor = $request->user()?->id;
            $supplier = DB::transaction(function () use ($data, $farm, $actor, $request): Supplier {
                $balance = $data['opening_balance'] ?? 0;
                $supplier = Supplier::create([...$data, 'organization_id' => $farm->organization_id, 'code' => $this->parties->nextCode(Supplier::class, $farm->organization_id, 'SUP'), 'opening_balance' => $balance, 'current_balance' => $balance, 'created_by' => $actor, 'updated_by' => $actor]);
                $this->parties->openingLedger($supplier, 'supplier', $actor);
                $this->audit->record($request, 'supplier.created', 'supplier', $supplier->id, null, $supplier->toArray());

                return $supplier;
            });

            return ApiResponse::success($request, (new SupplierResource($supplier))->resolve($request), 201);
        });
    }

    public function update(SupplierRequest $request, string $supplier): JsonResponse
    {
        $model = $this->party($request, $supplier);
        $data = $request->validated();
        if ((int) $data['version'] !== (int) $model->version) {
            return ApiResponse::error($request, 'STALE_VERSION', 'This supplier was changed by another user.', 412);
        }
        if (isset($data['farm_id'])) {
            $this->farm($request, $data['farm_id']);
        }
        $old = $model->toArray();
        unset($data['version']);
        $model->fill($data);
        $model->version++;
        $model->updated_by = $request->user()?->id;
        $model->save();
        $this->audit->record($request, 'supplier.updated', 'supplier', $model->id, $old, $model->toArray());

        return ApiResponse::success($request, (new SupplierResource($model))->resolve($request));
    }

    public function destroy(Request $request, string $supplier): JsonResponse
    {
        $model = $this->party($request, $supplier);
        $old = $model->toArray();
        $model->is_active = false;
        $model->save();
        $model->delete();
        $this->audit->record($request, 'supplier.archived', 'supplier', $model->id, $old, ['archived' => true]);

        return ApiResponse::success($request, ['archived' => true]);
    }

    public function ledger(Request $request, string $supplier): JsonResponse
    {
        $model = $this->party($request, $supplier, true);

        return ApiResponse::success($request, CommercialLedgerEntry::where('organization_id', $model->organization_id)->where('party_type', 'supplier')->where('party_id', $model->id)->orderBy('occurred_at')->get());
    }

    private function farm(Request $request, string $id): Farm
    {
        $farm = Farm::where('organization_id', $request->attributes->get('organization_id'))->findOrFail($id);
        abort_unless($request->attributes->get('membership')->canAccessFarm($id), 404);

        return $farm;
    }

    private function party(Request $request, string $id, bool $trashed = false): Supplier
    {
        $q = $trashed ? Supplier::withTrashed() : Supplier::query();
        $model = $q->where('organization_id', $request->attributes->get('organization_id'))->findOrFail($id);
        abort_unless($request->attributes->get('membership')->canAccessFarm($model->farm_id), 404);

        return $model;
    }
}

<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Commerce\Models\CommercialLedgerEntry;
use App\Domain\Commerce\Models\Customer;
use App\Domain\Commerce\Support\CommercialPartyService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\CustomerRequest;
use App\Http\Resources\Api\V1\CustomerResource;
use App\Models\Farm;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CustomerController extends Controller
{
    public function __construct(private AuditService $audit, private IdempotencyService $idempotency, private CommercialPartyService $parties) {}

    public function index(Request $request): JsonResponse
    {
        $membership = $request->attributes->get('membership');
        $query = Customer::query()->where('organization_id', $request->attributes->get('organization_id'));
        if (! $membership->all_farms) {
            $query->whereIn('farm_id', $membership->farms()->pluck('farms.id'));
        }
        if (! $request->boolean('include_inactive')) {
            $query->where('is_active', true);
        }
        if ($request->filled('search')) {
            $query->where(fn ($q) => $q->where('name', 'like', '%'.$request->string('search').'%')->orWhere('code', 'like', '%'.$request->string('search').'%'));
        }

        return ApiResponse::success($request, CustomerResource::collection($query->orderBy('name')->get())->resolve($request));
    }

    public function store(CustomerRequest $request): JsonResponse
    {
        return $this->idempotency->execute($request, function () use ($request): JsonResponse {
            $data = $request->validated();
            $farm = $this->farm($request, $data['farm_id']);
            $actor = $request->user()?->id;
            $customer = DB::transaction(function () use ($data, $farm, $actor, $request): Customer {
                $balance = $data['opening_balance'] ?? 0;
                $customer = Customer::create([...$data, 'organization_id' => $farm->organization_id, 'code' => $this->parties->nextCode(Customer::class, $farm->organization_id, 'CUS'), 'opening_balance' => $balance, 'current_balance' => $balance, 'created_by' => $actor, 'updated_by' => $actor]);
                $this->parties->openingLedger($customer, 'customer', $actor);
                $this->audit->record($request, 'customer.created', 'customer', $customer->id, null, $customer->toArray());

                return $customer;
            });

            return ApiResponse::success($request, (new CustomerResource($customer))->resolve($request), 201);
        });
    }

    public function update(CustomerRequest $request, string $customer): JsonResponse
    {
        $model = $this->party($request, $customer);
        $data = $request->validated();
        if ((int) $data['version'] !== (int) $model->version) {
            return ApiResponse::error($request, 'STALE_VERSION', 'This customer was changed by another user.', 412);
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
        $this->audit->record($request, 'customer.updated', 'customer', $model->id, $old, $model->toArray());

        return ApiResponse::success($request, (new CustomerResource($model))->resolve($request));
    }

    public function destroy(Request $request, string $customer): JsonResponse
    {
        $model = $this->party($request, $customer);
        $old = $model->toArray();
        $model->is_active = false;
        $model->save();
        $model->delete();
        $this->audit->record($request, 'customer.archived', 'customer', $model->id, $old, ['archived' => true]);

        return ApiResponse::success($request, ['archived' => true]);
    }

    public function ledger(Request $request, string $customer): JsonResponse
    {
        $model = $this->party($request, $customer, true);

        return ApiResponse::success($request, CommercialLedgerEntry::where('organization_id', $model->organization_id)->where('party_type', 'customer')->where('party_id', $model->id)->orderBy('occurred_at')->get());
    }

    private function farm(Request $request, string $id): Farm
    {
        $farm = Farm::where('organization_id', $request->attributes->get('organization_id'))->findOrFail($id);
        abort_unless($request->attributes->get('membership')->canAccessFarm($id), 404);

        return $farm;
    }

    private function party(Request $request, string $id, bool $trashed = false): Customer
    {
        $q = $trashed ? Customer::withTrashed() : Customer::query();
        $model = $q->where('organization_id', $request->attributes->get('organization_id'))->findOrFail($id);
        abort_unless($request->attributes->get('membership')->canAccessFarm($model->farm_id), 404);

        return $model;
    }
}

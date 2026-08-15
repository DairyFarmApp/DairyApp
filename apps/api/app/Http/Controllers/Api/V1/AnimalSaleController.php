<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalSale;
use App\Domain\Finance\Models\IncomeRecord;
use App\Domain\Finance\Support\FinancePostingService;
use App\Domain\Finance\Support\ScopedNumberGenerator;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class AnimalSaleController extends Controller
{
    public function __construct(
        private readonly ScopedNumberGenerator $numbers,
        private readonly FinancePostingService $posting,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $orgId = $request->attributes->get('organization_id');
        $farmId = $this->activeFarmId($request);

        $sales = AnimalSale::where('organization_id', $orgId)
            ->where('farm_id', $farmId)
            ->with('animal')
            ->orderByDesc('sale_date')
            ->paginate(15);

        return ApiResponse::success($request, $sales->items(), 200, [
            'pagination' => [
                'current_page' => $sales->currentPage(),
                'last_page' => $sales->lastPage(),
                'page_size' => $sales->perPage(),
                'total' => $sales->total(),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $orgId = $request->attributes->get('organization_id');
        $farmId = $this->activeFarmId($request);
        $userId = $request->user()->id;

        $validated = $request->validate([
            'animal_id' => ['required', 'uuid'],
            'sale_date' => ['required', 'date', 'before_or_equal:today'],
            'buyer' => 'nullable|string|max:180',
            'sale_price' => 'required|numeric|min:0',
            'commission' => 'required|numeric|min:0',
            'transportation_cost' => 'required|numeric|min:0',
            'reason' => 'nullable|string|max:160',
            'notes' => 'nullable|string',
        ]);

        return DB::transaction(function () use ($request, $validated, $orgId, $farmId, $userId) {
            $animal = Animal::where('organization_id', $orgId)
                ->where('current_farm_id', $farmId)
                ->findOrFail($validated['animal_id']);

            if ($animal->operational_status !== 'active') {
                return ApiResponse::error($request, 'ANIMAL_NOT_SALEABLE', 'Only active animals can be sold.', 422);
            }

            // Update animal status
            $animal->update([
                'operational_status' => 'sold',
                'version' => $animal->version + 1,
                'updated_by' => $userId,
            ]);

            $netRevenue = $validated['sale_price'] - $validated['commission'] - $validated['transportation_cost'];
            $saleNumber = $this->numbers->next($orgId, 'animal_sale', 'SAL-');
            $saleId = (string) Str::uuid7();
            $incomeId = null;

            if ($netRevenue > 0) {
                $journal = $this->posting->post(
                    $orgId,
                    $farmId,
                    'animal_sale',
                    $saleId,
                    $validated['sale_date'],
                    'Sale of Animal #'.$animal->animal_number,
                    $userId,
                    [
                        ['account' => 'FARM_FUNDS', 'debit' => $netRevenue],
                        ['account' => 'GENERAL_INCOME', 'credit' => $netRevenue],
                    ],
                );
                $income = IncomeRecord::create([
                    'organization_id' => $orgId,
                    'farm_id' => $farmId,
                    'income_number' => $this->numbers->next($orgId, 'income_number', 'INC-'),
                    'recorded_on' => $validated['sale_date'],
                    'category' => 'Animal Sales',
                    'payer' => $validated['buyer'] ?? null,
                    'amount' => $netRevenue,
                    'reference' => $saleNumber,
                    'description' => 'Sale of Animal #'.$animal->animal_number,
                    'journal_entry_id' => $journal->id,
                    'created_by' => $userId,
                ]);
                $incomeId = $income->id;
            }

            $sale = AnimalSale::create([
                'id' => $saleId,
                'organization_id' => $orgId,
                'farm_id' => $farmId,
                'animal_id' => $animal->id,
                'sale_number' => $saleNumber,
                'sale_date' => $validated['sale_date'],
                'buyer' => $validated['buyer'] ?? null,
                'sale_price' => $validated['sale_price'],
                'commission' => $validated['commission'],
                'transportation_cost' => $validated['transportation_cost'],
                'net_revenue' => $netRevenue,
                'reason' => $validated['reason'] ?? null,
                'notes' => $validated['notes'] ?? null,
                'income_record_id' => $incomeId,
                'created_by' => $userId,
            ]);

            return ApiResponse::success($request, ['id' => $sale->id], 201);
        });
    }

    private function activeFarmId(Request $request): string
    {
        $farmId = $request->attributes->get('api_session')?->farm_id;
        abort_unless(is_string($farmId) && $farmId !== '', 409, 'An active farm is required.');

        return $farmId;
    }
}

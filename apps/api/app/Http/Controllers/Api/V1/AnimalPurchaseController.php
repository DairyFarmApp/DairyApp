<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalPurchase;
use App\Domain\AnimalRegistry\Support\AnimalNumberGenerator;
use App\Domain\Finance\Models\ExpenseRecord;
use App\Domain\Finance\Support\FinancePostingService;
use App\Domain\Finance\Support\ScopedNumberGenerator;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class AnimalPurchaseController extends Controller
{
    public function __construct(
        private readonly AnimalNumberGenerator $animalNumbers,
        private readonly ScopedNumberGenerator $numbers,
        private readonly FinancePostingService $posting,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $orgId = $request->attributes->get('organization_id');
        $session = $request->attributes->get('api_session');
        $farmId = $session?->farm_id ?? $request->attributes->get('active_farm_id') ?? $request->header('X-Farm-Id');

        $purchases = AnimalPurchase::where('organization_id', $orgId)
            ->where('farm_id', $farmId)
            ->with('animal')
            ->orderByDesc('purchase_date')
            ->paginate(15);

        return ApiResponse::success($request, $purchases->items(), 200, [
            'pagination' => [
                'current_page' => $purchases->currentPage(),
                'last_page' => $purchases->lastPage(),
                'page_size' => $purchases->perPage(),
                'total' => $purchases->total(),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $orgId = $request->attributes->get('organization_id');
        $session = $request->attributes->get('api_session');
        $farmId = $session?->farm_id ?? $request->attributes->get('active_farm_id') ?? $request->header('X-Farm-Id');
        $userId = $request->user()->id;

        $validated = $request->validate([
            'purchase_date' => 'required|date',
            'supplier' => 'nullable|string|max:180',
            'purchase_price' => 'required|numeric|min:0',
            'transportation_cost' => 'required|numeric|min:0',
            'veterinary_cost' => 'required|numeric|min:0',
            'notes' => 'nullable|string',

            // Animal details
            'species_id' => 'required|uuid',
            'breed_id' => 'required|uuid',
            'sex' => 'required|string|in:male,female',
            'life_stage' => 'required|string',
            'animal_number' => 'prohibited',
            'shed_id' => 'required|uuid',
        ]);

        return DB::transaction(function () use ($request, $validated, $orgId, $farmId, $userId) {
            $totalCost = $validated['purchase_price'] + $validated['transportation_cost'] + $validated['veterinary_cost'];

            $animal = Animal::create([
                'organization_id' => $orgId,
                'animal_number' => $this->animalNumbers->next($orgId),
                'species_id' => $validated['species_id'],
                'breed_id' => $validated['breed_id'],
                'sex' => $validated['sex'],
                'life_stage' => $validated['life_stage'],
                'current_farm_id' => $farmId,
                'current_shed_id' => $validated['shed_id'],
                'origin' => 'purchased',
                'acquisition_date' => $validated['purchase_date'],
                'operational_status' => 'active',
                'photo_requirement_exempt' => false,
                'version' => 1,
                'created_by' => $userId,
                'updated_by' => $userId,
            ]);

            $purchaseNumber = $this->numbers->next($orgId, 'animal_purchase', 'PUR-');
            $purchaseId = (string) Str::uuid7();
            $expenseId = null;

            if ($totalCost > 0) {
                $journal = $this->posting->post(
                    $orgId,
                    $farmId,
                    'animal_purchase',
                    $purchaseId,
                    $validated['purchase_date'],
                    'Purchase of Animal #'.$animal->animal_number,
                    $userId,
                    [
                        ['account' => 'GENERAL_EXPENSE', 'debit' => $totalCost],
                        ['account' => 'FARM_FUNDS', 'credit' => $totalCost],
                    ],
                );
                $expense = ExpenseRecord::create([
                    'organization_id' => $orgId,
                    'farm_id' => $farmId,
                    'expense_number' => $this->numbers->next($orgId, 'expense_number', 'EXP-'),
                    'recorded_on' => $validated['purchase_date'],
                    'category' => 'Animal Purchases',
                    'payee' => $validated['supplier'] ?? null,
                    'amount' => $totalCost,
                    'reference' => $purchaseNumber,
                    'description' => 'Purchase of Animal #'.$animal->animal_number,
                    'journal_entry_id' => $journal->id,
                    'created_by' => $userId,
                ]);
                $expenseId = $expense->id;
            }

            $purchase = AnimalPurchase::create([
                'id' => $purchaseId,
                'organization_id' => $orgId,
                'farm_id' => $farmId,
                'animal_id' => $animal->id,
                'purchase_number' => $purchaseNumber,
                'purchase_date' => $validated['purchase_date'],
                'supplier' => $validated['supplier'] ?? null,
                'purchase_price' => $validated['purchase_price'],
                'transportation_cost' => $validated['transportation_cost'],
                'veterinary_cost' => $validated['veterinary_cost'],
                'total_cost' => $totalCost,
                'notes' => $validated['notes'] ?? null,
                'expense_record_id' => $expenseId,
                'created_by' => $userId,
            ]);

            return ApiResponse::success($request, [
                'id' => $purchase->id,
                'animal_id' => $animal->id,
                'animal_number' => $animal->animal_number,
            ], 201);
        });
    }
}

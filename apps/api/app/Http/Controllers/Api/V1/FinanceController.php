<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Finance\Models\ExpenseRecord;
use App\Domain\Finance\Models\IncomeRecord;
use App\Domain\Finance\Models\JournalEntry;
use App\Domain\Finance\Models\JournalLine;
use App\Domain\Finance\Support\FinancePostingService;
use App\Domain\Finance\Support\ScopedNumberGenerator;
use App\Domain\Workforce\Models\EmployeeLoan;
use App\Domain\Workforce\Models\PayrollPeriod;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\FinanceRecordStoreRequest;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class FinanceController extends Controller
{
    public function __construct(
        private readonly IdempotencyService $idempotency,
        private readonly AuditService $audit,
        private readonly ScopedNumberGenerator $numbers,
        private readonly FinancePostingService $posting,
    ) {}

    public function overview(Request $request): JsonResponse
    {
        [$start, $end] = $this->month($request);
        $profitLoss = $this->profitLossData($request, $start, $end);

        return ApiResponse::success($request, [
            'currency' => 'PKR',
            'month' => $start->format('Y-m'),
            ...$profitLoss,
            'paid_payroll' => $this->money(PayrollPeriod::query()
                ->where('organization_id', $this->organizationId($request))
                ->where('farm_id', $this->farmId($request))
                ->where('status', 'paid')
                ->whereBetween('paid_at', [$start, $end])
                ->sum('total_basic_salary')),
            'outstanding_employee_loans' => $this->money(EmployeeLoan::query()
                ->where('organization_id', $this->organizationId($request))
                ->where('farm_id', $this->farmId($request))
                ->sum('outstanding_amount')),
        ]);
    }

    public function income(Request $request): JsonResponse
    {
        [$start, $end] = $this->month($request);
        $records = IncomeRecord::query()
            ->where('organization_id', $this->organizationId($request))
            ->where('farm_id', $this->farmId($request))
            ->whereBetween('recorded_on', $this->dateRange($start, $end))
            ->orderByDesc('recorded_on')
            ->limit(200)
            ->get();

        return ApiResponse::success($request, [
            'currency' => 'PKR',
            'records' => $records->map(fn (IncomeRecord $record) => $this->incomeData($record)),
        ]);
    }

    public function storeIncome(FinanceRecordStoreRequest $request): JsonResponse
    {
        return $this->storeRecord($request, true);
    }

    public function expenses(Request $request): JsonResponse
    {
        [$start, $end] = $this->month($request);
        $records = ExpenseRecord::query()
            ->where('organization_id', $this->organizationId($request))
            ->where('farm_id', $this->farmId($request))
            ->whereBetween('recorded_on', $this->dateRange($start, $end))
            ->orderByDesc('recorded_on')
            ->limit(200)
            ->get();

        return ApiResponse::success($request, [
            'currency' => 'PKR',
            'records' => $records->map(fn (ExpenseRecord $record) => $this->expenseData($record)),
        ]);
    }

    public function storeExpense(FinanceRecordStoreRequest $request): JsonResponse
    {
        return $this->storeRecord($request, false);
    }

    public function ledger(Request $request): JsonResponse
    {
        [$start, $end] = $this->month($request);
        $entries = JournalEntry::query()
            ->with('lines')
            ->where('organization_id', $this->organizationId($request))
            ->where('farm_id', $this->farmId($request))
            ->whereBetween('occurred_on', $this->dateRange($start, $end))
            ->orderByDesc('occurred_on')
            ->orderByDesc('created_at')
            ->limit(200)
            ->get();

        return ApiResponse::success($request, [
            'currency' => 'PKR',
            'entries' => $entries->map(fn (JournalEntry $entry) => [
                'id' => $entry->id,
                'entry_number' => $entry->entry_number,
                'occurred_on' => $entry->occurred_on->toDateString(),
                'source_type' => $entry->source_type,
                'description' => $entry->description,
                'status' => $entry->status,
                'amount' => $this->money($entry->lines->sum('debit')),
            ]),
        ]);
    }

    public function profitLoss(Request $request): JsonResponse
    {
        [$start, $end] = $this->month($request);

        return ApiResponse::success($request, [
            'currency' => 'PKR',
            'month' => $start->format('Y-m'),
            ...$this->profitLossData($request, $start, $end),
        ]);
    }

    private function storeRecord(
        FinanceRecordStoreRequest $request,
        bool $income,
    ): JsonResponse {
        return $this->idempotency->execute($request, function () use ($request, $income): JsonResponse {
            $record = DB::transaction(function () use ($request, $income) {
                $data = $request->validated();
                $organizationId = $this->organizationId($request);
                $farmId = $this->farmId($request);
                $id = $data['id'] ?? (string) Str::uuid7();
                $journal = $this->posting->post(
                    $organizationId,
                    $farmId,
                    $income ? 'income' : 'expense',
                    $id,
                    $data['recorded_on'],
                    ($income ? 'Income: ' : 'Expense: ').$data['category'],
                    $request->user()->id,
                    $income
                        ? [
                            ['account' => 'FARM_FUNDS', 'debit' => $data['amount']],
                            ['account' => 'GENERAL_INCOME', 'credit' => $data['amount']],
                        ]
                        : [
                            ['account' => 'GENERAL_EXPENSE', 'debit' => $data['amount']],
                            ['account' => 'FARM_FUNDS', 'credit' => $data['amount']],
                        ],
                );
                if ($income) {
                    $record = IncomeRecord::query()->create([
                        'id' => $id,
                        'organization_id' => $organizationId,
                        'farm_id' => $farmId,
                        'income_number' => $this->numbers->next($organizationId, 'income_number', 'INC-'),
                        'recorded_on' => $data['recorded_on'],
                        'category' => $data['category'],
                        'payer' => $data['party'] ?? null,
                        'amount' => $data['amount'],
                        'reference' => $data['reference'] ?? null,
                        'description' => $data['description'] ?? null,
                        'journal_entry_id' => $journal->id,
                        'created_by' => $request->user()->id,
                    ]);
                } else {
                    $record = ExpenseRecord::query()->create([
                        'id' => $id,
                        'organization_id' => $organizationId,
                        'farm_id' => $farmId,
                        'expense_number' => $this->numbers->next($organizationId, 'expense_number', 'EXP-'),
                        'recorded_on' => $data['recorded_on'],
                        'category' => $data['category'],
                        'payee' => $data['party'] ?? null,
                        'amount' => $data['amount'],
                        'reference' => $data['reference'] ?? null,
                        'description' => $data['description'] ?? null,
                        'journal_entry_id' => $journal->id,
                        'created_by' => $request->user()->id,
                    ]);
                }
                $this->audit->record(
                    $request,
                    $income ? 'finance.income_posted' : 'finance.expense_posted',
                    $income ? 'income_record' : 'expense_record',
                    $id,
                    null,
                    [
                        'category' => $data['category'],
                        'amount' => $data['amount'],
                        'currency' => 'PKR',
                        'journal_entry_id' => $journal->id,
                    ],
                );

                return $record;
            });

            return ApiResponse::success(
                $request,
                $income ? $this->incomeData($record) : $this->expenseData($record),
                201,
            );
        });
    }

    private function profitLossData(
        Request $request,
        CarbonImmutable $start,
        CarbonImmutable $end,
    ): array {
        $rows = JournalLine::query()
            ->join('system_accounts', 'system_accounts.id', '=', 'finance_journal_lines.system_account_id')
            ->join('finance_journal_entries', 'finance_journal_entries.id', '=', 'finance_journal_lines.journal_entry_id')
            ->where('finance_journal_lines.organization_id', $this->organizationId($request))
            ->where('finance_journal_lines.farm_id', $this->farmId($request))
            ->where('finance_journal_entries.status', 'posted')
            ->whereBetween(
                'finance_journal_entries.occurred_on',
                $this->dateRange($start, $end),
            )
            ->whereIn('system_accounts.type', ['income', 'expense'])
            ->selectRaw('system_accounts.type, SUM(finance_journal_lines.debit) AS debits, SUM(finance_journal_lines.credit) AS credits')
            ->groupBy('system_accounts.type')
            ->get()
            ->keyBy('type');
        $income = ((float) ($rows['income']->credits ?? 0)) - ((float) ($rows['income']->debits ?? 0));
        $expenses = ((float) ($rows['expense']->debits ?? 0)) - ((float) ($rows['expense']->credits ?? 0));

        return [
            'income' => $this->money($income),
            'expenses' => $this->money($expenses),
            'net_profit' => $this->money($income - $expenses),
        ];
    }

    private function month(Request $request): array
    {
        $request->validate(['month' => ['nullable', 'date_format:Y-m']]);
        $value = (string) $request->query('month', now()->format('Y-m'));
        $start = CarbonImmutable::createFromFormat(
            'Y-m-d H:i:s',
            $value.'-01 00:00:00',
        )->startOfMonth();

        return [$start, $start->endOfMonth()];
    }

    /** @return array{0: string, 1: string} */
    private function dateRange(CarbonImmutable $start, CarbonImmutable $end): array
    {
        return [$start->toDateString(), $end->toDateString()];
    }

    private function incomeData(IncomeRecord $record): array
    {
        return [
            'id' => $record->id,
            'number' => $record->income_number,
            'recorded_on' => $record->recorded_on->toDateString(),
            'category' => $record->category,
            'party' => $record->payer,
            'amount' => $record->amount,
            'currency' => 'PKR',
            'reference' => $record->reference,
            'description' => $record->description,
        ];
    }

    private function expenseData(ExpenseRecord $record): array
    {
        return [
            'id' => $record->id,
            'number' => $record->expense_number,
            'recorded_on' => $record->recorded_on->toDateString(),
            'category' => $record->category,
            'party' => $record->payee,
            'amount' => $record->amount,
            'currency' => 'PKR',
            'reference' => $record->reference,
            'description' => $record->description,
        ];
    }

    private function organizationId(Request $request): string
    {
        return (string) $request->attributes->get('organization_id');
    }

    private function farmId(Request $request): string
    {
        return (string) $request->attributes->get('api_session')->farm_id;
    }

    private function money(mixed $amount): string
    {
        return number_format((float) $amount, 2, '.', '');
    }
}

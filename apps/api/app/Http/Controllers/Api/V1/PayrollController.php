<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Finance\Support\FinancePostingService;
use App\Domain\Workforce\Models\Employee;
use App\Domain\Workforce\Models\EmployeeLoan;
use App\Domain\Workforce\Models\EmployeeLoanInstallment;
use App\Domain\Workforce\Models\PayrollPeriod;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\PayrollGenerateRequest;
use App\Http\Resources\Api\V1\PayrollPeriodResource;
use App\Models\Farm;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PayrollController extends Controller
{
    public function __construct(
        private readonly IdempotencyService $idempotency,
        private readonly AuditService $audit,
        private readonly FinancePostingService $posting,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = $this->scope($request)->with('entries.employee');
        if ($period = $request->query('period_month')) {
            $request->validate(['period_month' => ['date_format:Y-m']]);
            $query->whereDate('period_month', $period.'-01');
        }

        return ApiResponse::success($request, [
            'currency' => 'PKR',
            'periods' => PayrollPeriodResource::collection(
                $query->orderByDesc('period_month')->limit(24)->get(),
            )->resolve($request),
        ]);
    }

    public function generate(PayrollGenerateRequest $request): JsonResponse
    {
        return $this->idempotency->execute($request, function () use ($request): JsonResponse {
            $period = DB::transaction(function () use ($request): PayrollPeriod {
                $organizationId = $this->organizationId($request);
                $farmId = $this->farmId($request);
                $month = CarbonImmutable::createFromFormat(
                    'Y-m-d',
                    $request->validated('period_month').'-01',
                )->startOfMonth();
                Farm::query()->lockForUpdate()->findOrFail($farmId);
                if ($month->isAfter(now()->startOfMonth())) {
                    abort(422, 'Future payroll periods cannot be generated.');
                }
                if ($this->scope($request)->where('status', '!=', 'paid')->exists()) {
                    abort(409, 'Finish the existing payroll before generating another month.');
                }
                if ($this->scope($request)->whereDate('period_month', $month)->exists()) {
                    abort(409, 'Payroll already exists for this month.');
                }

                $employees = Employee::query()
                    ->where('organization_id', $organizationId)
                    ->where('farm_id', $farmId)
                    ->where('is_active', true)
                    ->whereDate('joining_date', '<=', $month->endOfMonth())
                    ->orderBy('employee_number')
                    ->get();
                if ($employees->isEmpty()) {
                    abort(422, 'Add an active employee before generating payroll.');
                }

                $period = PayrollPeriod::query()->create([
                    'organization_id' => $organizationId,
                    'farm_id' => $farmId,
                    'period_month' => $month,
                    'status' => 'draft',
                    'generated_by' => $request->user()->id,
                ]);
                $basicTotal = 0;
                $loanTotal = 0;
                $netTotal = 0;
                foreach ($employees as $employee) {
                    $basic = $this->posting->toCents($employee->monthly_salary);
                    $loan = EmployeeLoan::query()
                        ->where('organization_id', $organizationId)
                        ->where('farm_id', $farmId)
                        ->where('employee_id', $employee->id)
                        ->where('status', 'active')
                        ->whereDate('first_recovery_month', '<=', $month)
                        ->get()
                        ->sum(fn (EmployeeLoan $item) => min(
                            $this->posting->toCents($item->monthly_installment),
                            $this->posting->toCents($item->outstanding_amount),
                        ));
                    $loan = min($loan, $basic);
                    $net = $basic - $loan;
                    $period->entries()->create([
                        'organization_id' => $organizationId,
                        'farm_id' => $farmId,
                        'employee_id' => $employee->id,
                        'basic_salary' => $this->posting->formatCents($basic),
                        'loan_deduction' => $this->posting->formatCents($loan),
                        'bonus' => '0.00',
                        'other_deduction' => '0.00',
                        'net_salary' => $this->posting->formatCents($net),
                    ]);
                    $basicTotal += $basic;
                    $loanTotal += $loan;
                    $netTotal += $net;
                }
                $period->forceFill([
                    'total_basic_salary' => $this->posting->formatCents($basicTotal),
                    'total_loan_deduction' => $this->posting->formatCents($loanTotal),
                    'total_net_salary' => $this->posting->formatCents($netTotal),
                ])->save();
                $this->audit->record(
                    $request,
                    'payroll.generated',
                    'payroll_period',
                    $period->id,
                    null,
                    [
                        'period_month' => $month->format('Y-m'),
                        'employees' => $employees->count(),
                        'net_salary' => $period->total_net_salary,
                        'currency' => 'PKR',
                    ],
                );

                return $period->load('entries.employee');
            });

            return ApiResponse::success(
                $request,
                (new PayrollPeriodResource($period))->resolve($request),
                201,
            );
        });
    }

    public function approve(Request $request, string $period): JsonResponse
    {
        return $this->idempotency->execute($request, function () use ($request, $period): JsonResponse {
            $model = DB::transaction(function () use ($request, $period): PayrollPeriod {
                $locked = $this->scope($request)->lockForUpdate()->findOrFail($period);
                if ($locked->status !== 'draft') {
                    abort(409, 'Only draft payroll can be approved.');
                }
                $locked->forceFill([
                    'status' => 'approved',
                    'approved_by' => $request->user()->id,
                    'approved_at' => now(),
                ])->save();
                $this->audit->record(
                    $request,
                    'payroll.approved',
                    'payroll_period',
                    $locked->id,
                    ['status' => 'draft'],
                    ['status' => 'approved'],
                );

                return $locked->load('entries.employee');
            });

            return ApiResponse::success(
                $request,
                (new PayrollPeriodResource($model))->resolve($request),
            );
        });
    }

    public function pay(Request $request, string $period): JsonResponse
    {
        return $this->idempotency->execute($request, function () use ($request, $period): JsonResponse {
            $model = DB::transaction(function () use ($request, $period): PayrollPeriod {
                $organizationId = $this->organizationId($request);
                $farmId = $this->farmId($request);
                $locked = $this->scope($request)
                    ->with('entries.employee')
                    ->lockForUpdate()
                    ->findOrFail($period);
                if ($locked->status !== 'approved') {
                    abort(409, 'Payroll must be approved before payment.');
                }

                foreach ($locked->entries as $entry) {
                    $remaining = $this->posting->toCents($entry->loan_deduction);
                    if ($remaining === 0) {
                        continue;
                    }
                    $loans = EmployeeLoan::query()
                        ->where('organization_id', $organizationId)
                        ->where('farm_id', $farmId)
                        ->where('employee_id', $entry->employee_id)
                        ->where('status', 'active')
                        ->whereDate('first_recovery_month', '<=', $locked->period_month)
                        ->orderBy('first_recovery_month')
                        ->orderBy('created_at')
                        ->lockForUpdate()
                        ->get();
                    foreach ($loans as $loan) {
                        if ($remaining === 0) {
                            break;
                        }
                        $outstanding = $this->posting->toCents($loan->outstanding_amount);
                        $amount = min(
                            $remaining,
                            $outstanding,
                            $this->posting->toCents($loan->monthly_installment),
                        );
                        if ($amount === 0) {
                            continue;
                        }
                        EmployeeLoanInstallment::query()->create([
                            'organization_id' => $organizationId,
                            'farm_id' => $farmId,
                            'employee_loan_id' => $loan->id,
                            'payroll_entry_id' => $entry->id,
                            'amount' => $this->posting->formatCents($amount),
                            'recovered_on' => now()->toDateString(),
                        ]);
                        $newOutstanding = $outstanding - $amount;
                        $loan->forceFill([
                            'recovered_amount' => $this->posting->formatCents(
                                $this->posting->toCents($loan->recovered_amount) + $amount,
                            ),
                            'outstanding_amount' => $this->posting->formatCents($newOutstanding),
                            'status' => $newOutstanding === 0 ? 'paid' : 'active',
                        ])->save();
                        $remaining -= $amount;
                    }
                    if ($remaining !== 0) {
                        abort(409, 'The scheduled loan deduction no longer matches active loans.');
                    }
                }

                $basic = $locked->total_basic_salary;
                $loan = $locked->total_loan_deduction;
                $net = $locked->total_net_salary;
                $lines = [['account' => 'SALARY_EXPENSE', 'debit' => $basic]];
                if ($this->posting->toCents($net) > 0) {
                    $lines[] = ['account' => 'FARM_FUNDS', 'credit' => $net];
                }
                if ($this->posting->toCents($loan) > 0) {
                    $lines[] = ['account' => 'EMPLOYEE_LOANS', 'credit' => $loan];
                }
                $journal = $this->posting->post(
                    $organizationId,
                    $farmId,
                    'payroll',
                    $locked->id,
                    now()->toDateString(),
                    'Monthly payroll '.$locked->period_month->format('Y-m'),
                    $request->user()->id,
                    $lines,
                );
                $locked->forceFill([
                    'status' => 'paid',
                    'paid_by' => $request->user()->id,
                    'paid_at' => now(),
                    'journal_entry_id' => $journal->id,
                ])->save();
                $this->audit->record(
                    $request,
                    'payroll.paid',
                    'payroll_period',
                    $locked->id,
                    ['status' => 'approved'],
                    [
                        'status' => 'paid',
                        'net_salary' => $net,
                        'loan_recovery' => $loan,
                        'currency' => 'PKR',
                        'journal_entry_id' => $journal->id,
                    ],
                );

                return $locked->load('entries.employee');
            });

            return ApiResponse::success(
                $request,
                (new PayrollPeriodResource($model))->resolve($request),
            );
        });
    }

    private function scope(Request $request)
    {
        return PayrollPeriod::query()
            ->where('organization_id', $this->organizationId($request))
            ->where('farm_id', $this->farmId($request));
    }

    private function organizationId(Request $request): string
    {
        return (string) $request->attributes->get('organization_id');
    }

    private function farmId(Request $request): string
    {
        return (string) $request->attributes->get('api_session')->farm_id;
    }
}

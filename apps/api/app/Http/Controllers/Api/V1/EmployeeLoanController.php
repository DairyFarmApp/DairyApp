<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Finance\Support\FinancePostingService;
use App\Domain\Finance\Support\ScopedNumberGenerator;
use App\Domain\Workforce\Models\Employee;
use App\Domain\Workforce\Models\EmployeeLoan;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\EmployeeLoanStoreRequest;
use App\Http\Resources\Api\V1\EmployeeLoanResource;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class EmployeeLoanController extends Controller
{
    public function __construct(
        private readonly IdempotencyService $idempotency,
        private readonly AuditService $audit,
        private readonly ScopedNumberGenerator $numbers,
        private readonly FinancePostingService $posting,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = $this->scope($request)->with('employee');
        if ($employee = $request->query('employee_id')) {
            $query->where('employee_id', $employee);
        }
        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }
        $loans = $query->orderByDesc('disbursement_date')->limit(200)->get();

        return ApiResponse::success($request, [
            'currency' => 'PKR',
            'summary' => [
                'active_loans' => $this->scope($request)->where('status', 'active')->count(),
                'principal_amount' => $this->money($this->scope($request)->sum('principal_amount')),
                'recovered_amount' => $this->money($this->scope($request)->sum('recovered_amount')),
                'outstanding_amount' => $this->money($this->scope($request)->sum('outstanding_amount')),
            ],
            'loans' => EmployeeLoanResource::collection($loans)->resolve($request),
        ]);
    }

    public function store(EmployeeLoanStoreRequest $request): JsonResponse
    {
        return $this->idempotency->execute($request, function () use ($request): JsonResponse {
            $loan = DB::transaction(function () use ($request): EmployeeLoan {
                $data = $request->validated();
                $organizationId = $this->organizationId($request);
                $farmId = $this->farmId($request);
                $employee = Employee::query()
                    ->where('organization_id', $organizationId)
                    ->where('farm_id', $farmId)
                    ->where('is_active', true)
                    ->lockForUpdate()
                    ->findOrFail($data['employee_id']);
                $loanId = $data['id'] ?? (string) Str::uuid7();
                $journal = $this->posting->post(
                    $organizationId,
                    $farmId,
                    'employee_loan',
                    $loanId,
                    $data['disbursement_date'],
                    'Employee loan '.$employee->name,
                    $request->user()->id,
                    [
                        ['account' => 'EMPLOYEE_LOANS', 'debit' => $data['principal_amount']],
                        ['account' => 'FARM_FUNDS', 'credit' => $data['principal_amount']],
                    ],
                );
                $loan = EmployeeLoan::query()->create([
                    'id' => $loanId,
                    'organization_id' => $organizationId,
                    'farm_id' => $farmId,
                    'employee_id' => $employee->id,
                    'loan_number' => $this->numbers->next($organizationId, 'employee_loan', 'LOAN-'),
                    'disbursement_date' => $data['disbursement_date'],
                    'principal_amount' => $data['principal_amount'],
                    'monthly_installment' => $data['monthly_installment'],
                    'recovered_amount' => '0.00',
                    'outstanding_amount' => $data['principal_amount'],
                    'first_recovery_month' => CarbonImmutable::createFromFormat(
                        'Y-m-d',
                        $data['first_recovery_month'].'-01',
                    ),
                    'reason' => $data['reason'],
                    'notes' => $data['notes'] ?? null,
                    'status' => 'active',
                    'journal_entry_id' => $journal->id,
                    'created_by' => $request->user()->id,
                ]);
                $this->audit->record(
                    $request,
                    'employee_loan.disbursed',
                    'employee_loan',
                    $loan->id,
                    null,
                    [
                        'employee_id' => $employee->id,
                        'principal_amount' => $loan->principal_amount,
                        'monthly_installment' => $loan->monthly_installment,
                        'currency' => 'PKR',
                        'journal_entry_id' => $journal->id,
                    ],
                );

                return $loan->load('employee');
            });

            return ApiResponse::success(
                $request,
                (new EmployeeLoanResource($loan))->resolve($request),
                201,
            );
        });
    }

    private function scope(Request $request)
    {
        return EmployeeLoan::query()
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

    private function money(mixed $amount): string
    {
        return number_format((float) $amount, 2, '.', '');
    }
}

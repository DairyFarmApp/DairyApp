<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Finance\Support\ScopedNumberGenerator;
use App\Domain\Workforce\Models\Employee;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\EmployeeStoreRequest;
use App\Http\Requests\Api\V1\EmployeeUpdateRequest;
use App\Http\Resources\Api\V1\EmployeeResource;
use App\Models\Shed;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class EmployeeController extends Controller
{
    public function __construct(
        private readonly IdempotencyService $idempotency,
        private readonly AuditService $audit,
        private readonly ScopedNumberGenerator $numbers,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = $this->scope($request)->withSum(
            ['loans as outstanding_loan_amount' => fn ($query) => $query->where('status', 'active')],
            'outstanding_amount',
        );
        if ($search = trim((string) $request->query('search', ''))) {
            $query->where(function ($query) use ($search): void {
                $query->where('name', 'like', '%'.$search.'%')
                    ->orWhere('employee_number', 'like', '%'.$search.'%')
                    ->orWhere('designation', 'like', '%'.$search.'%');
            });
        }
        if (! $request->boolean('include_inactive')) {
            $query->where('is_active', true);
        }
        $employees = $query->orderBy('name')->limit(200)->get();

        return ApiResponse::success($request, [
            'currency' => 'PKR',
            'employees' => EmployeeResource::collection($employees)->resolve($request),
            'summary' => [
                'active_employees' => $this->scope($request)->where('is_active', true)->count(),
                'monthly_salary_total' => number_format(
                    (float) $this->scope($request)->where('is_active', true)->sum('monthly_salary'),
                    2,
                    '.',
                    '',
                ),
                'outstanding_loans' => number_format(
                    (float) $this->scope($request)->whereHas(
                        'loans',
                        fn ($query) => $query->where('status', 'active'),
                    )->withSum(
                        ['loans as active_loan_total' => fn ($query) => $query->where('status', 'active')],
                        'outstanding_amount',
                    )->get()->sum('active_loan_total'),
                    2,
                    '.',
                    '',
                ),
            ],
        ]);
    }

    public function store(EmployeeStoreRequest $request): JsonResponse
    {
        return $this->idempotency->execute($request, function () use ($request): JsonResponse {
            $employee = DB::transaction(function () use ($request): Employee {
                $data = $request->validated();
                $this->assertShed($request, $data['shed_id'] ?? null);
                $organizationId = $this->organizationId($request);
                $farmId = $this->farmId($request);
                $employee = Employee::query()->create([
                    ...$data,
                    'organization_id' => $organizationId,
                    'farm_id' => $farmId,
                    'employee_number' => $data['employee_number']
                        ?? $this->numbers->next($organizationId, 'employee_number', 'EMP-'),
                    'is_active' => true,
                    'version' => 1,
                    'created_by' => $request->user()->id,
                    'updated_by' => $request->user()->id,
                ]);
                $this->audit->record(
                    $request,
                    'employee.created',
                    'employee',
                    $employee->id,
                    null,
                    [
                        'employee_number' => $employee->employee_number,
                        'farm_id' => $farmId,
                        'monthly_salary' => $employee->monthly_salary,
                        'currency' => 'PKR',
                    ],
                );

                return $employee;
            });

            return ApiResponse::success(
                $request,
                (new EmployeeResource($employee))->resolve($request),
                201,
            );
        });
    }

    public function update(
        EmployeeUpdateRequest $request,
        string $employee,
    ): JsonResponse {
        $model = $this->employee($request, $employee);
        $data = $request->validated();
        $this->assertShed($request, $data['shed_id'] ?? null);

        $result = DB::transaction(function () use ($request, $model, $data): ?Employee {
            $locked = Employee::query()->lockForUpdate()->findOrFail($model->id);
            if ($locked->version !== (int) $data['version']) {
                return null;
            }
            $old = $locked->only([
                'name', 'phone', 'email', 'designation', 'department',
                'joining_date', 'employment_type', 'monthly_salary', 'shed_id',
            ]);
            unset($data['version']);
            $locked->fill($data);
            $locked->version++;
            $locked->updated_by = $request->user()->id;
            $locked->save();
            $this->audit->record(
                $request,
                'employee.updated',
                'employee',
                $locked->id,
                $old,
                $locked->only(array_keys($old)),
            );

            return $locked;
        });

        if (! $result) {
            return ApiResponse::error(
                $request,
                'STALE_VERSION',
                'The employee was changed by another request.',
                412,
            );
        }

        return ApiResponse::success(
            $request,
            (new EmployeeResource($result))->resolve($request),
        );
    }

    public function archive(Request $request, string $employee): JsonResponse
    {
        $model = $this->employee($request, $employee);
        $data = $request->validate(['version' => ['required', 'integer', 'min:1']]);

        $result = DB::transaction(function () use ($request, $model, $data): string {
            $locked = Employee::query()->lockForUpdate()->findOrFail($model->id);
            if ($locked->loans()->where('status', 'active')->exists()) {
                return 'loan';
            }
            if ($locked->version !== (int) $data['version']) {
                return 'stale';
            }

            $locked->forceFill([
                'is_active' => false,
                'version' => $locked->version + 1,
                'updated_by' => $request->user()->id,
            ])->save();
            $locked->delete();
            $this->audit->record(
                $request,
                'employee.deactivated',
                'employee',
                $locked->id,
                ['is_active' => true],
                ['is_active' => false],
            );

            return 'archived';
        });
        if ($result === 'loan') {
            return ApiResponse::error(
                $request,
                'EMPLOYEE_HAS_ACTIVE_LOAN',
                'Recover the employee loan before deactivating this employee.',
                409,
            );
        }
        if ($result === 'stale') {
            return ApiResponse::error($request, 'STALE_VERSION', 'The employee was changed.', 412);
        }

        return ApiResponse::success($request, ['id' => $model->id, 'is_active' => false]);
    }

    public function restore(Request $request, string $employee): JsonResponse
    {
        $model = $this->scope($request, true)->whereKey($employee)->firstOrFail();
        $model->restore();
        $model->forceFill([
            'is_active' => true,
            'version' => $model->version + 1,
            'updated_by' => $request->user()->id,
        ])->save();
        $this->audit->record(
            $request,
            'employee.restored',
            'employee',
            $model->id,
            ['is_active' => false],
            ['is_active' => true],
        );

        return ApiResponse::success($request, (new EmployeeResource($model))->resolve($request));
    }

    private function employee(Request $request, string $id): Employee
    {
        return $this->scope($request)->whereKey($id)->firstOrFail();
    }

    private function scope(Request $request, bool $withTrashed = false)
    {
        $query = Employee::query()
            ->where('organization_id', $this->organizationId($request))
            ->where('farm_id', $this->farmId($request));

        return $withTrashed ? $query->withTrashed() : $query;
    }

    private function assertShed(Request $request, ?string $shedId): void
    {
        if (! $shedId) {
            return;
        }
        Shed::query()
            ->where('organization_id', $this->organizationId($request))
            ->where('farm_id', $this->farmId($request))
            ->findOrFail($shedId);
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

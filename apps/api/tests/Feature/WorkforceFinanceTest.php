<?php

namespace Tests\Feature;

use App\Domain\Workforce\Models\Employee;
use App\Models\Farm;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class WorkforceFinanceTest extends TestCase
{
    use CreatesFoundationData;
    use RefreshDatabase;

    private const ALL_PERMISSIONS = [
        'employees.view',
        'employees.manage',
        'employee_loans.view',
        'employee_loans.manage',
        'payroll.view',
        'payroll.process',
        'finance.view',
        'finance.manage',
    ];

    public function test_workforce_endpoints_require_authentication_and_permissions(): void
    {
        $this->getJson('/api/v1/employees')->assertUnauthorized();
        $foundation = $this->foundation([]);
        $headers = $this->bearer($this->loginToken());

        foreach ([
            '/api/v1/employees',
            '/api/v1/employee-loans',
            '/api/v1/payroll',
            '/api/v1/finance/overview',
        ] as $path) {
            $this->getJson($path, $headers)
                ->assertForbidden()
                ->assertJsonPath('error.code', 'FORBIDDEN');
        }

        $this->assertNotNull($foundation['farm']->id);
    }

    public function test_employee_management_is_pkr_monthly_versioned_and_farm_scoped(): void
    {
        $context = $this->context();
        $payload = $this->employeePayload();
        $created = $this->postJson(
            '/api/v1/employees',
            $payload,
            [...$context['headers'], 'Idempotency-Key' => 'employee-create-1'],
        )->assertCreated()
            ->assertJsonPath('data.name', 'Ali Raza')
            ->assertJsonPath('data.monthly_salary', '65000.00')
            ->assertJsonPath('data.currency', 'PKR')
            ->assertJsonPath('data.version', 1);
        $id = $created->json('data.id');
        $this->assertMatchesRegularExpression('/^EMP-\d{6}$/', $created->json('data.employee_number'));

        $this->patchJson(
            "/api/v1/employees/$id",
            ['version' => 1, 'designation' => 'Senior Farm Hand', 'monthly_salary' => '70000.00'],
            $context['headers'],
        )->assertOk()
            ->assertJsonPath('data.designation', 'Senior Farm Hand')
            ->assertJsonPath('data.monthly_salary', '70000.00')
            ->assertJsonPath('data.version', 2);
        $this->patchJson(
            "/api/v1/employees/$id",
            ['version' => 1, 'designation' => 'Stale'],
            $context['headers'],
        )->assertStatus(412)->assertJsonPath('error.code', 'STALE_VERSION');

        $otherFarm = Farm::query()->create([
            'organization_id' => $context['foundation']['organization']->id,
            'name' => 'Concealed Farm',
            'code' => 'CONCEALED',
            'timezone' => 'Asia/Karachi',
        ]);
        Employee::query()->create([
            ...$this->employeePayload(),
            'organization_id' => $context['foundation']['organization']->id,
            'farm_id' => $otherFarm->id,
            'employee_number' => 'EMP-HIDDEN',
            'is_active' => true,
            'version' => 1,
            'created_by' => $context['foundation']['user']->id,
            'updated_by' => $context['foundation']['user']->id,
        ]);

        $this->getJson('/api/v1/employees', $context['headers'])
            ->assertOk()
            ->assertJsonCount(1, 'data.employees')
            ->assertJsonPath('data.summary.active_employees', 1)
            ->assertJsonPath('data.summary.monthly_salary_total', '70000.00');
        $this->assertDatabaseHas('audit_logs', ['action' => 'employee.created', 'entity_id' => $id]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'employee.updated', 'entity_id' => $id]);
    }

    public function test_loan_disbursement_posts_a_balanced_immutable_journal(): void
    {
        $context = $this->context();
        $employee = $this->createEmployee($context);
        $payload = [
            'employee_id' => $employee,
            'disbursement_date' => now()->toDateString(),
            'principal_amount' => '30000.00',
            'monthly_installment' => '5000.00',
            'first_recovery_month' => now()->format('Y-m'),
            'reason' => 'Family medical support',
        ];
        $headers = [...$context['headers'], 'Idempotency-Key' => 'loan-create-1'];
        $first = $this->postJson('/api/v1/employee-loans', $payload, $headers)
            ->assertCreated()
            ->assertJsonPath('data.principal_amount', '30000.00')
            ->assertJsonPath('data.outstanding_amount', '30000.00')
            ->assertJsonPath('data.monthly_installment', '5000.00')
            ->assertJsonPath('data.status', 'active')
            ->assertJsonPath('data.currency', 'PKR');
        $this->postJson('/api/v1/employee-loans', $payload, $headers)
            ->assertStatus($first->status())
            ->assertExactJson($first->json());

        $this->assertDatabaseCount('employee_loans', 1);
        $this->assertDatabaseCount('finance_journal_entries', 1);
        $this->assertBalancedJournal();
        $this->assertDatabaseHas('audit_logs', ['action' => 'employee_loan.disbursed']);
        $this->deleteJson("/api/v1/employees/$employee", ['version' => 1], $context['headers'])
            ->assertConflict()
            ->assertJsonPath('error.code', 'EMPLOYEE_HAS_ACTIVE_LOAN');
        $this->patchJson('/api/v1/employee-loans/'.$first->json('data.id'), [], $context['headers'])
            ->assertNotFound();
    }

    public function test_monthly_payroll_requires_approval_recovers_loan_and_posts_once(): void
    {
        $context = $this->context();
        $employee = $this->createEmployee($context);
        $this->postJson('/api/v1/employee-loans', [
            'employee_id' => $employee,
            'disbursement_date' => now()->toDateString(),
            'principal_amount' => '12000.00',
            'monthly_installment' => '5000.00',
            'first_recovery_month' => now()->format('Y-m'),
            'reason' => 'Emergency advance',
        ], [...$context['headers'], 'Idempotency-Key' => 'payroll-loan'])->assertCreated();

        $month = now()->format('Y-m');
        $generated = $this->postJson(
            '/api/v1/payroll/generate',
            ['period_month' => $month],
            [...$context['headers'], 'Idempotency-Key' => 'payroll-generate'],
        )->assertCreated()
            ->assertJsonPath('data.status', 'draft')
            ->assertJsonPath('data.total_basic_salary', '65000.00')
            ->assertJsonPath('data.total_loan_deduction', '5000.00')
            ->assertJsonPath('data.total_net_salary', '60000.00')
            ->assertJsonCount(1, 'data.entries');
        $period = $generated->json('data.id');
        $this->postJson(
            "/api/v1/payroll/$period/pay",
            [],
            [...$context['headers'], 'Idempotency-Key' => 'payroll-early-pay'],
        )->assertConflict();

        $this->postJson(
            "/api/v1/payroll/$period/approve",
            [],
            [...$context['headers'], 'Idempotency-Key' => 'payroll-approve'],
        )->assertOk()->assertJsonPath('data.status', 'approved');
        $paidHeaders = [...$context['headers'], 'Idempotency-Key' => 'payroll-pay'];
        $paid = $this->postJson("/api/v1/payroll/$period/pay", [], $paidHeaders)
            ->assertOk()
            ->assertJsonPath('data.status', 'paid')
            ->assertJsonPath('data.total_net_salary', '60000.00');
        $this->postJson("/api/v1/payroll/$period/pay", [], $paidHeaders)
            ->assertStatus($paid->status())
            ->assertExactJson($paid->json());

        $this->assertDatabaseHas('employee_loans', [
            'employee_id' => $employee,
            'recovered_amount' => '5000.00',
            'outstanding_amount' => '7000.00',
            'status' => 'active',
        ]);
        $this->assertDatabaseCount('employee_loan_installments', 1);
        $this->assertDatabaseCount('finance_journal_entries', 2);
        $this->assertBalancedJournal();
        $this->assertDatabaseHas('audit_logs', ['action' => 'payroll.generated']);
        $this->assertDatabaseHas('audit_logs', ['action' => 'payroll.approved']);
        $this->assertDatabaseHas('audit_logs', ['action' => 'payroll.paid']);
    }

    public function test_income_expenses_ledger_and_profit_loss_are_real_balanced_rows(): void
    {
        $context = $this->context();
        $income = [
            'recorded_on' => now()->toDateString(),
            'category' => 'Milk sales',
            'party' => 'Local collection centre',
            'amount' => '150000.00',
            'reference' => 'MILK-001',
        ];
        $expense = [
            'recorded_on' => now()->toDateString(),
            'category' => 'Feed',
            'party' => 'Feed supplier',
            'amount' => '40000.00',
            'reference' => 'FEED-001',
        ];
        $incomeHeaders = [...$context['headers'], 'Idempotency-Key' => 'income-1'];
        $first = $this->postJson('/api/v1/finance/income', $income, $incomeHeaders)
            ->assertCreated()
            ->assertJsonPath('data.amount', '150000.00')
            ->assertJsonPath('data.currency', 'PKR');
        $this->postJson('/api/v1/finance/income', $income, $incomeHeaders)
            ->assertStatus($first->status())
            ->assertExactJson($first->json());
        $this->postJson(
            '/api/v1/finance/expenses',
            $expense,
            [...$context['headers'], 'Idempotency-Key' => 'expense-1'],
        )->assertCreated()->assertJsonPath('data.amount', '40000.00');

        $month = now()->format('Y-m');
        $this->getJson("/api/v1/finance/overview?month=$month", $context['headers'])
            ->assertOk()
            ->assertJsonPath('data.income', '150000.00')
            ->assertJsonPath('data.expenses', '40000.00')
            ->assertJsonPath('data.net_profit', '110000.00')
            ->assertJsonPath('data.currency', 'PKR');
        $this->getJson("/api/v1/finance/ledger?month=$month", $context['headers'])
            ->assertOk()
            ->assertJsonCount(2, 'data.entries')
            ->assertJsonMissing(['FARM_FUNDS']);
        $this->getJson("/api/v1/finance/income?month=$month", $context['headers'])
            ->assertOk()->assertJsonCount(1, 'data.records');
        $this->getJson("/api/v1/finance/expenses?month=$month", $context['headers'])
            ->assertOk()->assertJsonCount(1, 'data.records');
        $this->assertDatabaseCount('finance_journal_entries', 2);
        $this->assertBalancedJournal();
        $this->assertDatabaseHas('audit_logs', ['action' => 'finance.income_posted']);
        $this->assertDatabaseHas('audit_logs', ['action' => 'finance.expense_posted']);
    }

    public function test_cross_organization_employee_and_finance_data_remain_concealed(): void
    {
        $first = $this->context();
        $this->createEmployee($first);
        $this->postJson('/api/v1/finance/income', [
            'recorded_on' => now()->toDateString(),
            'category' => 'Other income',
            'amount' => '1000.00',
        ], [...$first['headers'], 'Idempotency-Key' => 'org-one-income'])->assertCreated();
        $first['foundation']['user']->forceFill([
            'email' => 'first-owner@example.test',
        ])->save();

        $second = $this->context('second-owner@example.test');
        $this->getJson('/api/v1/employees', $second['headers'])
            ->assertOk()->assertJsonCount(0, 'data.employees');
        $this->getJson('/api/v1/finance/ledger', $second['headers'])
            ->assertOk()->assertJsonCount(0, 'data.entries');
    }

    private function context(string $email = 'owner@example.test'): array
    {
        $foundation = $this->foundation(self::ALL_PERMISSIONS);
        if ($email !== 'owner@example.test') {
            $foundation['user']->forceFill(['email' => $email])->save();
        }
        $headers = $this->bearer($this->loginToken($email));

        return compact('foundation', 'headers');
    }

    private function createEmployee(array $context): string
    {
        return $this->postJson(
            '/api/v1/employees',
            $this->employeePayload(),
            [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()],
        )->assertCreated()->json('data.id');
    }

    private function employeePayload(): array
    {
        return [
            'name' => 'Ali Raza',
            'phone' => '03001234567',
            'email' => 'ali@example.test',
            'designation' => 'Farm Hand',
            'department' => 'Operations',
            'joining_date' => now()->subYear()->toDateString(),
            'employment_type' => 'full_time',
            'monthly_salary' => '65000.00',
            'address' => 'Village Road',
            'emergency_contact' => '03007654321',
        ];
    }

    private function assertBalancedJournal(): void
    {
        $entries = DB::table('finance_journal_lines')
            ->selectRaw('journal_entry_id, SUM(debit) AS debits, SUM(credit) AS credits')
            ->groupBy('journal_entry_id')
            ->get();
        $this->assertNotEmpty($entries);
        foreach ($entries as $entry) {
            $this->assertSame((string) $entry->debits, (string) $entry->credits);
        }
    }
}

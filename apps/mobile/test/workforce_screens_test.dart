import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/features/workforce/application/workforce_providers.dart';
import 'package:dairycare_mobile/features/workforce/domain/workforce_models.dart';
import 'package:dairycare_mobile/features/workforce/presentation/employee_loans_screen.dart';
import 'package:dairycare_mobile/features/workforce/presentation/employees_screen.dart';
import 'package:dairycare_mobile/features/workforce/presentation/finance_screen.dart';
import 'package:dairycare_mobile/features/workforce/presentation/payroll_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  setUp(() {
    FakeAuthController.session = foundationSession(
      permissions: const {
        'employees.view',
        'employees.manage',
        'employee_loans.view',
        'employee_loans.manage',
        'payroll.view',
        'payroll.process',
        'finance.view',
        'finance.manage',
      },
    );
  });

  testWidgets('employee screen shows monthly salary and functional add form', (
    tester,
  ) async {
    _wide(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
          employeesProvider.overrideWith((ref) async => _employees),
        ],
        child: const MaterialApp(home: EmployeesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Employees'), findsOneWidget);
    expect(find.text('Monthly salary'), findsOneWidget);
    expect(find.text('Ali Raza'), findsOneWidget);
    expect(find.text('Add employee'), findsOneWidget);
    await tester.tap(find.text('Add employee'));
    await tester.pumpAndSettle();
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Monthly salary (PKR)'), findsOneWidget);
    expect(find.text('Save employee'), findsOneWidget);
  });

  testWidgets('loan screen shows recovery balances and complete loan form', (
    tester,
  ) async {
    _wide(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
          employeesProvider.overrideWith((ref) async => _employees),
          employeeLoansProvider.overrideWith((ref) async => _loans),
        ],
        child: const MaterialApp(home: EmployeeLoansScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Employee loans'), findsOneWidget);
    expect(find.text('Outstanding'), findsOneWidget);
    expect(find.text('Ali Raza • LOAN-000001'), findsOneWidget);
    await tester.tap(find.text('New loan'));
    await tester.pumpAndSettle();
    expect(find.text('Loan amount (PKR)'), findsOneWidget);
    expect(find.text('Monthly installment (PKR)'), findsOneWidget);
    expect(find.text('First payroll recovery month'), findsOneWidget);
    expect(find.text('Disburse loan'), findsOneWidget);
  });

  testWidgets(
    'payroll screen shows draft approval and automatic loan recovery',
    (tester) async {
      _wide(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(FakeAuthController.new),
            payrollProvider.overrideWith((ref) async => [_payroll]),
          ],
          child: const MaterialApp(home: PayrollScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Salary & payroll'), findsOneWidget);
      expect(find.text('Loan recovery'), findsOneWidget);
      expect(find.text('Net payable'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Ali Raza\nEMP-000001'), findsOneWidget);
    },
  );

  testWidgets(
    'finance screen exposes income expenses ledger and profit metrics',
    (tester) async {
      _wide(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(FakeAuthController.new),
            financeDashboardProvider.overrideWith((ref) async => _finance),
          ],
          child: const MaterialApp(home: FinanceScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Finance'), findsOneWidget);
      expect(find.text('Income'), findsWidgets);
      expect(find.text('Expenses'), findsWidgets);
      expect(find.text('Net profit'), findsOneWidget);
      expect(find.text('Ledger'), findsOneWidget);
      expect(find.text('Add income'), findsOneWidget);
      expect(find.text('Add expense'), findsOneWidget);
      expect(find.text('Milk sales'), findsOneWidget);
    },
  );
}

void _wide(WidgetTester tester) {
  tester.view.physicalSize = const Size(1500, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

final _employee = Employee(
  id: 'employee-1',
  employeeNumber: 'EMP-000001',
  name: 'Ali Raza',
  designation: 'Farm Hand',
  joiningDate: DateTime(2025, 7, 1),
  employmentType: 'full_time',
  monthlySalary: '65000.00',
  isActive: true,
  version: 1,
);

final _employees = EmployeeOverview(
  employees: [_employee],
  activeEmployees: 1,
  monthlySalaryTotal: '65000.00',
  outstandingLoans: '30000.00',
);

final _loan = EmployeeLoan(
  id: 'loan-1',
  employeeId: 'employee-1',
  employeeName: 'Ali Raza',
  loanNumber: 'LOAN-000001',
  disbursementDate: DateTime(2026, 7, 1),
  principalAmount: '30000.00',
  monthlyInstallment: '5000.00',
  recoveredAmount: '0.00',
  outstandingAmount: '30000.00',
  firstRecoveryMonth: '2026-07',
  reason: 'Emergency support',
  status: 'active',
);

final _loans = LoanOverview(
  loans: [_loan],
  activeLoans: 1,
  principalAmount: '30000.00',
  recoveredAmount: '0.00',
  outstandingAmount: '30000.00',
);

final _payroll = PayrollPeriod(
  id: 'payroll-1',
  periodMonth: '2026-07',
  status: 'draft',
  totalBasicSalary: '65000.00',
  totalLoanDeduction: '5000.00',
  totalNetSalary: '60000.00',
  entries: const [
    PayrollLine(
      id: 'entry-1',
      employeeId: 'employee-1',
      employeeNumber: 'EMP-000001',
      employeeName: 'Ali Raza',
      basicSalary: '65000.00',
      loanDeduction: '5000.00',
      netSalary: '60000.00',
    ),
  ],
);

final _finance = FinanceDashboard(
  overview: const FinanceOverview(
    month: '2026-07',
    income: '150000.00',
    expenses: '40000.00',
    netProfit: '110000.00',
    paidPayroll: '0.00',
    outstandingEmployeeLoans: '30000.00',
  ),
  income: [
    FinanceRecord(
      id: 'income-1',
      number: 'INC-000001',
      recordedOn: DateTime(2026, 7, 30),
      category: 'Milk sales',
      amount: '150000.00',
    ),
  ],
  expenses: const [],
  ledger: [
    LedgerEntry(
      id: 'journal-1',
      entryNumber: 'JE-000001',
      occurredOn: DateTime(2026, 7, 30),
      sourceType: 'income',
      description: 'Income: Milk sales',
      status: 'posted',
      amount: '150000.00',
    ),
  ],
);

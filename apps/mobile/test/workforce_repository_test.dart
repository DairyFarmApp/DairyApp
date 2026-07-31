import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/workforce/data/workforce_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'employee repository uses functional list create update and archive APIs',
    () async {
      final requests = <RequestOptions>[];
      final repository = WorkforceRepository(api: _api(requests));

      final overview = await repository.employees();
      final created = await repository.createEmployee({'name': 'Ali Raza'});
      final updated = await repository.updateEmployee(created, {
        'designation': 'Supervisor',
      });
      await repository.archiveEmployee(updated);

      expect(overview.activeEmployees, 1);
      expect(overview.monthlySalaryTotal, '65000.00');
      expect(created.name, 'Ali Raza');
      expect(requests.map((request) => '${request.method} ${request.path}'), [
        'GET /employees',
        'POST /employees',
        'PATCH /employees/employee-1',
        'DELETE /employees/employee-1',
      ]);
      expect(requests[1].headers['Idempotency-Key'], isNotEmpty);
      expect((requests[2].data as Map<String, dynamic>)['version'], 1);
      expect((requests[3].data as Map<String, dynamic>)['version'], 1);
    },
  );

  test(
    'loans payroll and finance preserve PKR transport and workflow actions',
    () async {
      final requests = <RequestOptions>[];
      final repository = WorkforceRepository(api: _api(requests));

      final loans = await repository.loans();
      final loan = await repository.createLoan({'employee_id': 'employee-1'});
      final payroll = await repository.payroll();
      final generated = await repository.generatePayroll('2026-07');
      final approved = await repository.approvePayroll('payroll-1');
      final paid = await repository.payPayroll('payroll-1');
      final finance = await repository.finance(DateTime(2026, 7));
      final income = await repository.createIncome({'amount': '1000.00'});
      final expense = await repository.createExpense({'amount': '200.00'});

      expect(loans.outstandingAmount, '30000.00');
      expect(loan.monthlyInstallment, '5000.00');
      expect(payroll.single.totalNetSalary, '60000.00');
      expect(generated.status, 'draft');
      expect(approved.status, 'approved');
      expect(paid.status, 'paid');
      expect(finance.overview.netProfit, '800.00');
      expect(finance.ledger.single.entryNumber, 'JE-000001');
      expect(income.amount, '1000.00');
      expect(expense.amount, '200.00');
      expect(
        requests
            .where((request) => request.method == 'POST')
            .every(
              (request) =>
                  request.headers['Idempotency-Key']?.toString().isNotEmpty ==
                  true,
            ),
        isTrue,
      );
    },
  );
}

ApiClient _api(List<RequestOptions> requests) {
  final dio = Dio();
  final api = ApiClient(
    config: EnvironmentConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: Uri.parse('http://example.test/api/v1'),
    ),
    readAccessToken: () async => 'token',
    dio: dio,
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: options.method == 'POST' ? 201 : 200,
            data: {'data': _response(options)},
          ),
        );
      },
    ),
  );
  return api;
}

Object _response(RequestOptions options) {
  if (options.path == '/employees' && options.method == 'GET') {
    return {
      'currency': 'PKR',
      'summary': {
        'active_employees': 1,
        'monthly_salary_total': '65000.00',
        'outstanding_loans': '30000.00',
      },
      'employees': [_employee()],
    };
  }
  if (options.path.startsWith('/employees')) return _employee();
  if (options.path == '/employee-loans' && options.method == 'GET') {
    return {
      'currency': 'PKR',
      'summary': {
        'active_loans': 1,
        'principal_amount': '30000.00',
        'recovered_amount': '0.00',
        'outstanding_amount': '30000.00',
      },
      'loans': [_loan()],
    };
  }
  if (options.path == '/employee-loans') return _loan();
  if (options.path == '/payroll' && options.method == 'GET') {
    return {
      'currency': 'PKR',
      'periods': [_payroll('paid')],
    };
  }
  if (options.path == '/payroll/generate') return _payroll('draft');
  if (options.path.endsWith('/approve')) return _payroll('approved');
  if (options.path.endsWith('/pay')) return _payroll('paid');
  if (options.path == '/finance/overview') {
    return {
      'currency': 'PKR',
      'month': '2026-07',
      'income': '1000.00',
      'expenses': '200.00',
      'net_profit': '800.00',
      'paid_payroll': '0.00',
      'outstanding_employee_loans': '30000.00',
    };
  }
  if (options.path == '/finance/ledger') {
    return {
      'currency': 'PKR',
      'entries': [
        {
          'id': 'journal-1',
          'entry_number': 'JE-000001',
          'occurred_on': '2026-07-30',
          'source_type': 'income',
          'description': 'Income: Milk sales',
          'status': 'posted',
          'amount': '1000.00',
        },
      ],
    };
  }
  if (options.path == '/finance/income' && options.method == 'GET') {
    return {
      'currency': 'PKR',
      'records': [_financeRecord('1000.00')],
    };
  }
  if (options.path == '/finance/expenses' && options.method == 'GET') {
    return {
      'currency': 'PKR',
      'records': [_financeRecord('200.00')],
    };
  }
  if (options.path == '/finance/income') return _financeRecord('1000.00');
  if (options.path == '/finance/expenses') return _financeRecord('200.00');
  throw StateError('Unexpected request ${options.method} ${options.path}');
}

Map<String, Object?> _employee() => {
  'id': 'employee-1',
  'employee_number': 'EMP-000001',
  'name': 'Ali Raza',
  'phone': '03001234567',
  'email': 'ali@example.test',
  'designation': 'Farm Hand',
  'department': 'Operations',
  'joining_date': '2025-07-01',
  'employment_type': 'full_time',
  'monthly_salary': '65000.00',
  'address': null,
  'emergency_contact': null,
  'notes': null,
  'is_active': true,
  'version': 1,
};

Map<String, Object?> _loan() => {
  'id': 'loan-1',
  'employee_id': 'employee-1',
  'employee_name': 'Ali Raza',
  'loan_number': 'LOAN-000001',
  'disbursement_date': '2026-07-01',
  'principal_amount': '30000.00',
  'monthly_installment': '5000.00',
  'recovered_amount': '0.00',
  'outstanding_amount': '30000.00',
  'first_recovery_month': '2026-07',
  'reason': 'Emergency support',
  'notes': null,
  'status': 'active',
};

Map<String, Object> _payroll(String status) => {
  'id': 'payroll-1',
  'period_month': '2026-07',
  'status': status,
  'currency': 'PKR',
  'total_basic_salary': '65000.00',
  'total_loan_deduction': '5000.00',
  'total_net_salary': '60000.00',
  'entries': [
    {
      'id': 'payroll-entry-1',
      'employee_id': 'employee-1',
      'employee_number': 'EMP-000001',
      'employee_name': 'Ali Raza',
      'basic_salary': '65000.00',
      'loan_deduction': '5000.00',
      'net_salary': '60000.00',
    },
  ],
};

Map<String, Object?> _financeRecord(String amount) => {
  'id': 'record-1',
  'number': 'FIN-000001',
  'recorded_on': '2026-07-30',
  'category': 'Milk sales',
  'party': null,
  'amount': amount,
  'reference': null,
  'description': null,
};

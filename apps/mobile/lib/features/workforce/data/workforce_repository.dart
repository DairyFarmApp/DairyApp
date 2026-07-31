import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/workforce/domain/workforce_models.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final class WorkforceRepository {
  WorkforceRepository({required ApiClient api, Uuid uuid = const Uuid()})
    : _api = api,
      _uuid = uuid;

  final ApiClient _api;
  final Uuid _uuid;

  Future<EmployeeOverview> employees({bool includeInactive = false}) async {
    final body = await _api.getJson(
      '/employees',
      query: {'include_inactive': includeInactive ? 1 : 0},
    );
    return EmployeeOverview.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Employee> createEmployee(Map<String, dynamic> payload) async {
    final body = await _api.postJson(
      '/employees',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    return Employee.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Employee> updateEmployee(
    Employee employee,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.patchJson(
      '/employees/${employee.id}',
      data: {...payload, 'version': employee.version},
    );
    return Employee.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> archiveEmployee(Employee employee) => _api.deleteJson(
    '/employees/${employee.id}',
    data: {'version': employee.version},
  );

  Future<LoanOverview> loans() async {
    final body = await _api.getJson('/employee-loans');
    return LoanOverview.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<EmployeeLoan> createLoan(Map<String, dynamic> payload) async {
    final body = await _api.postJson(
      '/employee-loans',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    return EmployeeLoan.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<PayrollPeriod>> payroll() async {
    final body = await _api.getJson('/payroll');
    return ((body['data'] as Map<String, dynamic>)['periods'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(PayrollPeriod.fromJson)
        .toList(growable: false);
  }

  Future<PayrollPeriod> generatePayroll(String periodMonth) async {
    final body = await _api.postJson(
      '/payroll/generate',
      data: {'period_month': periodMonth},
      idempotencyKey: _uuid.v7(),
    );
    return PayrollPeriod.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<PayrollPeriod> approvePayroll(String periodId) async {
    final body = await _api.postJson(
      '/payroll/$periodId/approve',
      data: const {},
      idempotencyKey: _uuid.v7(),
    );
    return PayrollPeriod.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<PayrollPeriod> payPayroll(String periodId) async {
    final body = await _api.postJson(
      '/payroll/$periodId/pay',
      data: const {},
      idempotencyKey: _uuid.v7(),
    );
    return PayrollPeriod.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<FinanceDashboard> finance(DateTime month) async {
    final monthValue = DateFormat('yyyy-MM').format(month);
    final results = await Future.wait([
      _api.getJson('/finance/overview', query: {'month': monthValue}),
      _api.getJson('/finance/income', query: {'month': monthValue}),
      _api.getJson('/finance/expenses', query: {'month': monthValue}),
      _api.getJson('/finance/ledger', query: {'month': monthValue}),
    ]);
    final overview = results[0]['data'] as Map<String, dynamic>;
    final income = results[1]['data'] as Map<String, dynamic>;
    final expenses = results[2]['data'] as Map<String, dynamic>;
    final ledger = results[3]['data'] as Map<String, dynamic>;
    return FinanceDashboard(
      overview: FinanceOverview.fromJson(overview),
      income: (income['records'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(FinanceRecord.fromJson)
          .toList(growable: false),
      expenses: (expenses['records'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(FinanceRecord.fromJson)
          .toList(growable: false),
      ledger: (ledger['entries'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(LedgerEntry.fromJson)
          .toList(growable: false),
    );
  }

  Future<FinanceRecord> createIncome(Map<String, dynamic> payload) =>
      _createFinanceRecord('/finance/income', payload);

  Future<FinanceRecord> createExpense(Map<String, dynamic> payload) =>
      _createFinanceRecord('/finance/expenses', payload);

  Future<FinanceRecord> _createFinanceRecord(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.postJson(
      path,
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    return FinanceRecord.fromJson(body['data'] as Map<String, dynamic>);
  }
}

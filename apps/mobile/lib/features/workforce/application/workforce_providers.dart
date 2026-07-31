import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/workforce/data/workforce_repository.dart';
import 'package:dairycare_mobile/features/workforce/domain/workforce_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workforceRepositoryProvider = Provider<WorkforceRepository>(
  (ref) => WorkforceRepository(api: ref.watch(apiClientProvider)),
);

final employeesProvider = FutureProvider<EmployeeOverview>(
  (ref) => ref.watch(workforceRepositoryProvider).employees(),
);

final employeeLoansProvider = FutureProvider<LoanOverview>(
  (ref) => ref.watch(workforceRepositoryProvider).loans(),
);

final payrollProvider = FutureProvider<List<PayrollPeriod>>(
  (ref) => ref.watch(workforceRepositoryProvider).payroll(),
);

final financeMonthProvider = NotifierProvider<FinanceMonthController, DateTime>(
  FinanceMonthController.new,
);

final class FinanceMonthController extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setMonth(DateTime value) => state = value;
}

final financeDashboardProvider = FutureProvider<FinanceDashboard>(
  (ref) => ref
      .watch(workforceRepositoryProvider)
      .finance(ref.watch(financeMonthProvider)),
);

import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/workforce/application/workforce_providers.dart';
import 'package:dairycare_mobile/features/workforce/domain/workforce_models.dart';
import 'package:dairycare_mobile/features/workforce/presentation/workforce_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final class PayrollScreen extends ConsumerWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periods = ref.watch(payrollProvider);
    final canProcess =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('payroll.process') ??
        false;
    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                eyebrow: 'Monthly salary',
                title: 'Salary & payroll',
                subtitle:
                    'Generate monthly PKR salaries, approve them, recover loan installments, then post payment.',
                actions: [
                  if (canProcess)
                    FilledButton.icon(
                      onPressed: () => _generate(context, ref),
                      icon: const Icon(Icons.playlist_add_rounded),
                      label: const Text('Generate payroll'),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              periods.when(
                loading: () =>
                    const LoadingStateView(label: 'Loading payroll…'),
                error: (error, _) => ErrorStateView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(payrollProvider),
                ),
                data: (items) => items.isEmpty
                    ? emptyPanel(
                        'No payroll periods',
                        'Generate the first monthly salary period after adding employees.',
                        Icons.receipt_long_outlined,
                      )
                    : Column(
                        children: [
                          for (final period in items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: _PayrollCard(
                                period: period,
                                canProcess: canProcess,
                                onApprove: () => _approve(context, ref, period),
                                onPay: () => _pay(context, ref, period),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generate(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Choose any day in the payroll month',
    );
    if (picked == null || !context.mounted) return;
    try {
      await ref
          .read(workforceRepositoryProvider)
          .generatePayroll(DateFormat('yyyy-MM').format(picked));
      ref.invalidate(payrollProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft payroll generated.')),
        );
      }
    } catch (error) {
      if (context.mounted) _error(context, error);
    }
  }

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    PayrollPeriod period,
  ) async {
    try {
      await ref.read(workforceRepositoryProvider).approvePayroll(period.id);
      ref.invalidate(payrollProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payroll approved.')));
      }
    } catch (error) {
      if (context.mounted) _error(context, error);
    }
  }

  Future<void> _pay(
    BuildContext context,
    WidgetRef ref,
    PayrollPeriod period,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pay this payroll?'),
        content: Text(
          '${pkr(period.totalNetSalary)} will be posted as salary payment. '
          '${pkr(period.totalLoanDeduction)} will recover employee loans. '
          'This financial posting cannot be edited.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Post payment'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(workforceRepositoryProvider).payPayroll(period.id);
      ref.invalidate(payrollProvider);
      ref.invalidate(employeeLoansProvider);
      ref.invalidate(financeDashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payroll paid and posted.')),
        );
      }
    } catch (error) {
      if (context.mounted) _error(context, error);
    }
  }

  void _error(BuildContext context, Object error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

final class _PayrollCard extends StatelessWidget {
  const _PayrollCard({
    required this.period,
    required this.canProcess,
    required this.onApprove,
    required this.onPay,
  });

  final PayrollPeriod period;
  final bool canProcess;
  final VoidCallback onApprove;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) => GlassSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat(
                    'MMMM yyyy',
                  ).format(DateTime.parse('${period.periodMonth}-01')),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text('${period.entries.length} employee salary records'),
              ],
            ),
            Wrap(
              spacing: 9,
              children: [
                Chip(label: Text(period.status.toUpperCase())),
                if (canProcess && period.status == 'draft')
                  FilledButton(
                    onPressed: onApprove,
                    child: const Text('Approve'),
                  ),
                if (canProcess && period.status == 'approved')
                  FilledButton.icon(
                    onPressed: onPay,
                    icon: const Icon(Icons.payments_rounded),
                    label: const Text('Pay salaries'),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        metricGrid([
          MetricCard(
            label: 'Basic salaries',
            value: pkr(period.totalBasicSalary),
            icon: Icons.badge_outlined,
            color: const Color(0xFF2D9CDB),
          ),
          MetricCard(
            label: 'Loan recovery',
            value: pkr(period.totalLoanDeduction),
            icon: Icons.account_balance_wallet_outlined,
            color: const Color(0xFFF2994A),
          ),
          MetricCard(
            label: 'Net payable',
            value: pkr(period.totalNetSalary),
            icon: Icons.payments_rounded,
            color: const Color(0xFF2BAE74),
          ),
        ]),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Employee')),
              DataColumn(label: Text('Basic salary'), numeric: true),
              DataColumn(label: Text('Loan deduction'), numeric: true),
              DataColumn(label: Text('Net salary'), numeric: true),
            ],
            rows: [
              for (final entry in period.entries)
                DataRow(
                  cells: [
                    DataCell(
                      Text('${entry.employeeName}\n${entry.employeeNumber}'),
                    ),
                    DataCell(Text(pkr(entry.basicSalary))),
                    DataCell(Text(pkr(entry.loanDeduction))),
                    DataCell(Text(pkr(entry.netSalary))),
                  ],
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

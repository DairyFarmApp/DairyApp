import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/workforce/application/workforce_providers.dart';
import 'package:dairycare_mobile/features/workforce/domain/workforce_models.dart';
import 'package:dairycare_mobile/features/workforce/presentation/workforce_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final class EmployeeLoansScreen extends ConsumerWidget {
  const EmployeeLoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loans = ref.watch(employeeLoansProvider);
    final canManage =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('employee_loans.manage') ??
        false;
    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                eyebrow: 'Workforce',
                title: 'Employee loans',
                subtitle:
                    'Disburse PKR loans and recover scheduled installments automatically from paid payroll.',
                actions: [
                  if (canManage)
                    FilledButton.icon(
                      onPressed: () => _openLoan(context, ref),
                      icon: const Icon(Icons.add_card_rounded),
                      label: const Text('New loan'),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              loans.when(
                loading: () =>
                    const LoadingStateView(label: 'Loading employee loans…'),
                error: (error, _) => ErrorStateView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(employeeLoansProvider),
                ),
                data: (data) => _LoanBody(data: data),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLoan(BuildContext context, WidgetRef ref) async {
    try {
      final employees = await ref.read(employeesProvider.future);
      if (!context.mounted) return;
      if (employees.employees.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add an employee before creating a loan.'),
          ),
        );
        return;
      }
      final payload = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (_) => _LoanDialog(employees: employees.employees),
      );
      if (payload == null || !context.mounted) return;
      await ref.read(workforceRepositoryProvider).createLoan(payload);
      ref.invalidate(employeeLoansProvider);
      ref.invalidate(employeesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee loan posted successfully.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

final class _LoanBody extends StatelessWidget {
  const _LoanBody({required this.data});

  final LoanOverview data;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      metricGrid([
        MetricCard(
          label: 'Active loans',
          value: '${data.activeLoans}',
          icon: Icons.assignment_ind_rounded,
          color: const Color(0xFF2D9CDB),
        ),
        MetricCard(
          label: 'Principal given',
          value: pkr(data.principalAmount),
          icon: Icons.outbound_rounded,
          color: const Color(0xFF7C5CFC),
        ),
        MetricCard(
          label: 'Recovered',
          value: pkr(data.recoveredAmount),
          icon: Icons.task_alt_rounded,
          color: const Color(0xFF2BAE74),
        ),
        MetricCard(
          label: 'Outstanding',
          value: pkr(data.outstandingAmount),
          icon: Icons.schedule_rounded,
          color: const Color(0xFFF2994A),
        ),
      ]),
      const SizedBox(height: 20),
      if (data.loans.isEmpty)
        emptyPanel(
          'No employee loans',
          'New loans will appear here with recovered and outstanding balances.',
          Icons.account_balance_wallet_outlined,
        )
      else
        GlassSurface(
          child: Column(
            children: [
              for (final loan in data.loans) ...[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: loan.status == 'paid'
                        ? const Color(0xFF2BAE74).withValues(alpha: 0.15)
                        : const Color(0xFFF2994A).withValues(alpha: 0.15),
                    child: Icon(
                      loan.status == 'paid'
                          ? Icons.check_rounded
                          : Icons.payments_outlined,
                    ),
                  ),
                  title: Text(
                    '${loan.employeeName} • ${loan.loanNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${loan.reason}\n'
                    '${pkr(loan.outstandingAmount)} outstanding • '
                    '${pkr(loan.monthlyInstallment)}/month',
                  ),
                  isThreeLine: true,
                  trailing: Chip(label: Text(loan.status.toUpperCase())),
                ),
                if (loan != data.loans.last) const Divider(height: 1),
              ],
            ],
          ),
        ),
    ],
  );
}

final class _LoanDialog extends StatefulWidget {
  const _LoanDialog({required this.employees});

  final List<Employee> employees;

  @override
  State<_LoanDialog> createState() => _LoanDialogState();
}

final class _LoanDialogState extends State<_LoanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _principal = TextEditingController();
  final _installment = TextEditingController();
  final _reason = TextEditingController();
  final _notes = TextEditingController();
  late String _employeeId;
  DateTime _disbursement = DateTime.now();
  DateTime _firstRecovery = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _employeeId = widget.employees.first.id;
  }

  @override
  void dispose() {
    _principal.dispose();
    _installment.dispose();
    _reason.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('New employee loan'),
    content: SizedBox(
      width: 560,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _employeeId,
                decoration: fieldDecoration('Employee', icon: Icons.person),
                items: [
                  for (final employee in widget.employees)
                    DropdownMenuItem(
                      value: employee.id,
                      child: Text(
                        '${employee.name} (${employee.employeeNumber})',
                      ),
                    ),
                ],
                onChanged: (value) => _employeeId = value!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _principal,
                decoration: fieldDecoration(
                  'Loan amount (PKR)',
                  icon: Icons.payments_outlined,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _positiveMoney,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _installment,
                decoration: fieldDecoration(
                  'Monthly installment (PKR)',
                  icon: Icons.calendar_view_month_rounded,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final error = _positiveMoney(value);
                  if (error != null) return error;
                  if ((double.tryParse(value!) ?? 0) >
                      (double.tryParse(_principal.text) ?? 0)) {
                    return 'Installment cannot exceed the loan amount.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reason,
                decoration: fieldDecoration(
                  'Reason',
                  icon: Icons.notes_rounded,
                ),
                maxLines: 2,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the reason for this loan.'
                    : null,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available_rounded),
                title: const Text('Disbursement date'),
                subtitle: Text(shortDate(_disbursement)),
                onTap: () async {
                  final value = await pickDate(context, _disbursement);
                  if (value != null) setState(() => _disbursement = value);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_repeat_rounded),
                title: const Text('First payroll recovery month'),
                subtitle: Text(DateFormat('MMMM yyyy').format(_firstRecovery)),
                onTap: () async {
                  final value = await showDatePicker(
                    context: context,
                    initialDate: _firstRecovery,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    helpText: 'Choose any date in the recovery month',
                  );
                  if (value != null) {
                    setState(
                      () => _firstRecovery = DateTime(value.year, value.month),
                    );
                  }
                },
              ),
              TextFormField(
                controller: _notes,
                decoration: fieldDecoration('Notes (optional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(context, {
            'employee_id': _employeeId,
            'disbursement_date': DateFormat('yyyy-MM-dd').format(_disbursement),
            'principal_amount': double.parse(
              _principal.text,
            ).toStringAsFixed(2),
            'monthly_installment': double.parse(
              _installment.text,
            ).toStringAsFixed(2),
            'first_recovery_month': DateFormat(
              'yyyy-MM',
            ).format(_firstRecovery),
            'reason': _reason.text.trim(),
            'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          });
        },
        child: const Text('Disburse loan'),
      ),
    ],
  );

  String? _positiveMoney(String? value) {
    final amount = double.tryParse(value ?? '');
    return amount == null || amount <= 0 ? 'Enter an amount above zero.' : null;
  }
}

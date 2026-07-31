import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/workforce/application/workforce_providers.dart';
import 'package:dairycare_mobile/features/workforce/domain/workforce_models.dart';
import 'package:dairycare_mobile/features/workforce/presentation/workforce_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final class EmployeesScreen extends ConsumerWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(employeesProvider);
    final canManage =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('employees.manage') ??
        false;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(employeesProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  eyebrow: 'Workforce',
                  title: 'Employees',
                  subtitle:
                      'Keep employee details and monthly PKR salary records together.',
                  actions: [
                    if (canManage)
                      FilledButton.icon(
                        onPressed: () => _openEmployee(context, ref),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Add employee'),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                overview.when(
                  loading: () =>
                      const LoadingStateView(label: 'Loading employees…'),
                  error: (error, _) => ErrorStateView(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(employeesProvider),
                  ),
                  data: (data) => _EmployeeBody(
                    data: data,
                    canManage: canManage,
                    onEdit: (employee) =>
                        _openEmployee(context, ref, employee: employee),
                    onArchive: (employee) =>
                        _archiveEmployee(context, ref, employee),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEmployee(
    BuildContext context,
    WidgetRef ref, {
    Employee? employee,
  }) async {
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EmployeeDialog(employee: employee),
    );
    if (payload == null || !context.mounted) return;
    try {
      final repository = ref.read(workforceRepositoryProvider);
      if (employee == null) {
        await repository.createEmployee(payload);
      } else {
        await repository.updateEmployee(employee, payload);
      }
      ref.invalidate(employeesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              employee == null ? 'Employee added.' : 'Employee updated.',
            ),
          ),
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

  Future<void> _archiveEmployee(
    BuildContext context,
    WidgetRef ref,
    Employee employee,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deactivate employee?'),
        content: Text(
          '${employee.name} will no longer be included in new payroll periods.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(workforceRepositoryProvider).archiveEmployee(employee);
      ref.invalidate(employeesProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

final class _EmployeeBody extends StatelessWidget {
  const _EmployeeBody({
    required this.data,
    required this.canManage,
    required this.onEdit,
    required this.onArchive,
  });

  final EmployeeOverview data;
  final bool canManage;
  final ValueChanged<Employee> onEdit;
  final ValueChanged<Employee> onArchive;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      metricGrid([
        MetricCard(
          label: 'Active employees',
          value: '${data.activeEmployees}',
          icon: Icons.groups_2_rounded,
          color: const Color(0xFF2D9CDB),
        ),
        MetricCard(
          label: 'Monthly salary',
          value: pkr(data.monthlySalaryTotal),
          icon: Icons.payments_rounded,
          color: const Color(0xFF2BAE74),
        ),
        MetricCard(
          label: 'Outstanding loans',
          value: pkr(data.outstandingLoans),
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFFF2994A),
        ),
      ]),
      const SizedBox(height: 20),
      if (data.employees.isEmpty)
        emptyPanel(
          'No employees yet',
          'Add the first employee to prepare monthly payroll.',
          Icons.badge_outlined,
        )
      else
        GlassSurface(
          child: Column(
            children: [
              for (final employee in data.employees) ...[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  leading: CircleAvatar(
                    child: Text(employee.name.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(
                    employee.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${employee.employeeNumber} • ${employee.designation}\n'
                    '${pkr(employee.monthlySalary)} monthly',
                  ),
                  isThreeLine: true,
                  trailing: canManage
                      ? PopupMenuButton<String>(
                          onSelected: (value) => value == 'edit'
                              ? onEdit(employee)
                              : onArchive(employee),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'archive',
                              child: Text('Deactivate'),
                            ),
                          ],
                        )
                      : null,
                ),
                if (employee != data.employees.last) const Divider(height: 1),
              ],
            ],
          ),
        ),
    ],
  );
}

final class _EmployeeDialog extends StatefulWidget {
  const _EmployeeDialog({this.employee});

  final Employee? employee;

  @override
  State<_EmployeeDialog> createState() => _EmployeeDialogState();
}

final class _EmployeeDialogState extends State<_EmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _designation;
  late final TextEditingController _salary;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _department;
  late DateTime _joiningDate;
  late String _employmentType;

  @override
  void initState() {
    super.initState();
    final employee = widget.employee;
    _name = TextEditingController(text: employee?.name);
    _designation = TextEditingController(text: employee?.designation);
    _salary = TextEditingController(text: employee?.monthlySalary);
    _phone = TextEditingController(text: employee?.phone);
    _email = TextEditingController(text: employee?.email);
    _department = TextEditingController(text: employee?.department);
    _joiningDate = employee?.joiningDate ?? DateTime.now();
    _employmentType = employee?.employmentType ?? 'full_time';
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _designation,
      _salary,
      _phone,
      _email,
      _department,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.employee == null ? 'Add employee' : 'Edit employee'),
    content: SizedBox(
      width: 560,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: fieldDecoration('Full name', icon: Icons.person),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _designation,
                decoration: fieldDecoration(
                  'Designation',
                  icon: Icons.badge_outlined,
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salary,
                decoration: fieldDecoration(
                  'Monthly salary (PKR)',
                  icon: Icons.payments_outlined,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => double.tryParse(value ?? '') == null
                    ? 'Enter a valid salary.'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _employmentType,
                decoration: fieldDecoration('Employment type'),
                items: const [
                  DropdownMenuItem(
                    value: 'full_time',
                    child: Text('Full time'),
                  ),
                  DropdownMenuItem(
                    value: 'part_time',
                    child: Text('Part time'),
                  ),
                  DropdownMenuItem(value: 'contract', child: Text('Contract')),
                  DropdownMenuItem(value: 'casual', child: Text('Casual')),
                ],
                onChanged: (value) => _employmentType = value!,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Joining date'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(_joiningDate)),
                onTap: () async {
                  final value = await pickDate(context, _joiningDate);
                  if (value != null) setState(() => _joiningDate = value);
                },
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phone,
                decoration: fieldDecoration(
                  'Phone',
                  icon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: fieldDecoration(
                  'Email',
                  icon: Icons.email_outlined,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _department,
                decoration: fieldDecoration('Department'),
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
            'name': _name.text.trim(),
            'designation': _designation.text.trim(),
            'monthly_salary': double.parse(_salary.text).toStringAsFixed(2),
            'employment_type': _employmentType,
            'joining_date': DateFormat('yyyy-MM-dd').format(_joiningDate),
            'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
            'department': _department.text.trim().isEmpty
                ? null
                : _department.text.trim(),
          });
        },
        child: const Text('Save employee'),
      ),
    ],
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;
}

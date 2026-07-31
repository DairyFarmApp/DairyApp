import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/workforce/application/workforce_providers.dart';
import 'package:dairycare_mobile/features/workforce/domain/workforce_models.dart';
import 'package:dairycare_mobile/features/workforce/presentation/workforce_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(financeDashboardProvider);
    final month = ref.watch(financeMonthProvider);
    final canManage =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('finance.manage') ??
        false;
    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                eyebrow: 'PKR finance',
                title: 'Finance',
                subtitle:
                    'Income, expenses, immutable ledger posting and monthly profit/loss—without account setup.',
                actions: [
                  OutlinedButton.icon(
                    onPressed: () => _chooseMonth(context, ref, month),
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(DateFormat('MMMM yyyy').format(month)),
                  ),
                  if (canManage)
                    FilledButton.icon(
                      onPressed: () => _openRecord(context, ref, income: true),
                      icon: const Icon(Icons.south_west_rounded),
                      label: const Text('Add income'),
                    ),
                  if (canManage)
                    FilledButton.tonalIcon(
                      onPressed: () => _openRecord(context, ref, income: false),
                      icon: const Icon(Icons.north_east_rounded),
                      label: const Text('Add expense'),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              dashboard.when(
                loading: () =>
                    const LoadingStateView(label: 'Loading finance…'),
                error: (error, _) => ErrorStateView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(financeDashboardProvider),
                ),
                data: (data) => _FinanceBody(data: data),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseMonth(
    BuildContext context,
    WidgetRef ref,
    DateTime current,
  ) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Choose any date in the reporting month',
    );
    if (selected != null) {
      ref
          .read(financeMonthProvider.notifier)
          .setMonth(DateTime(selected.year, selected.month));
    }
  }

  Future<void> _openRecord(
    BuildContext context,
    WidgetRef ref, {
    required bool income,
  }) async {
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _FinanceRecordDialog(income: income),
    );
    if (payload == null || !context.mounted) return;
    try {
      final repository = ref.read(workforceRepositoryProvider);
      if (income) {
        await repository.createIncome(payload);
      } else {
        await repository.createExpense(payload);
      }
      ref.read(financeMonthProvider.notifier).setMonth(DateTime.now());
      ref.invalidate(financeDashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(income ? 'Income posted.' : 'Expense posted.'),
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
}

final class _FinanceBody extends StatelessWidget {
  const _FinanceBody({required this.data});

  final FinanceDashboard data;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      metricGrid([
        MetricCard(
          label: 'Income',
          value: pkr(data.overview.income),
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF2BAE74),
        ),
        MetricCard(
          label: 'Expenses',
          value: pkr(data.overview.expenses),
          icon: Icons.trending_down_rounded,
          color: const Color(0xFFEB5757),
        ),
        MetricCard(
          label: 'Net profit',
          value: pkr(data.overview.netProfit),
          icon: Icons.query_stats_rounded,
          color: const Color(0xFF2D9CDB),
        ),
        MetricCard(
          label: 'Employee loans due',
          value: pkr(data.overview.outstandingEmployeeLoans),
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFFF2994A),
        ),
      ]),
      const SizedBox(height: 20),
      DefaultTabController(
        length: 3,
        child: GlassSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Income'),
                  Tab(text: 'Expenses'),
                  Tab(text: 'Ledger'),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 430,
                child: TabBarView(
                  children: [
                    _RecordList(
                      records: data.income,
                      emptyMessage: 'No income recorded for this month.',
                      icon: Icons.south_west_rounded,
                    ),
                    _RecordList(
                      records: data.expenses,
                      emptyMessage: 'No expenses recorded for this month.',
                      icon: Icons.north_east_rounded,
                    ),
                    _LedgerList(entries: data.ledger),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

final class _RecordList extends StatelessWidget {
  const _RecordList({
    required this.records,
    required this.emptyMessage,
    required this.icon,
  });

  final List<FinanceRecord> records;
  final String emptyMessage;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return Center(child: Text(emptyMessage));
    return ListView.separated(
      itemCount: records.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final record = records[index];
        return ListTile(
          leading: CircleAvatar(child: Icon(icon)),
          title: Text(
            record.category,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${record.number} • ${shortDate(record.recordedOn)}'
            '${record.party == null ? '' : '\n${record.party}'}',
          ),
          trailing: Text(
            pkr(record.amount),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        );
      },
    );
  }
}

final class _LedgerList extends StatelessWidget {
  const _LedgerList({required this.entries});

  final List<LedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('No journal entries for this month.'));
    }
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final entry = entries[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.menu_book_rounded)),
          title: Text(
            entry.description,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${entry.entryNumber} • ${shortDate(entry.occurredOn)} • '
            '${entry.sourceType.replaceAll('_', ' ')}',
          ),
          trailing: Text(
            pkr(entry.amount),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        );
      },
    );
  }
}

final class _FinanceRecordDialog extends StatefulWidget {
  const _FinanceRecordDialog({required this.income});

  final bool income;

  @override
  State<_FinanceRecordDialog> createState() => _FinanceRecordDialogState();
}

final class _FinanceRecordDialogState extends State<_FinanceRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _party = TextEditingController();
  final _reference = TextEditingController();
  final _description = TextEditingController();
  DateTime _date = DateTime.now();
  late String _category;

  List<String> get _categories => widget.income
      ? const [
          'Milk sales',
          'Animal sales',
          'Manure sales',
          'Government support',
          'Insurance compensation',
          'Other income',
        ]
      : const [
          'Feed',
          'Medicine',
          'Veterinary charges',
          'Salaries',
          'Electricity',
          'Fuel',
          'Transport',
          'Repairs',
          'Rent',
          'Water',
          'Equipment',
          'Taxes',
          'Cleaning',
          'Laboratory',
          'Miscellaneous',
        ];

  @override
  void initState() {
    super.initState();
    _category = _categories.first;
  }

  @override
  void dispose() {
    _amount.dispose();
    _party.dispose();
    _reference.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.income ? 'Add income' : 'Add expense'),
    content: SizedBox(
      width: 540,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: fieldDecoration('Category'),
                items: [
                  for (final category in _categories)
                    DropdownMenuItem(value: category, child: Text(category)),
                ],
                onChanged: (value) => _category = value!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                decoration: fieldDecoration(
                  'Amount (PKR)',
                  icon: Icons.payments_outlined,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final number = double.tryParse(value ?? '');
                  return number == null || number <= 0
                      ? 'Enter an amount above zero.'
                      : null;
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_rounded),
                title: const Text('Date'),
                subtitle: Text(shortDate(_date)),
                onTap: () async {
                  final value = await pickDate(context, _date);
                  if (value != null) setState(() => _date = value);
                },
              ),
              TextFormField(
                controller: _party,
                decoration: fieldDecoration(
                  widget.income ? 'Payer (optional)' : 'Payee (optional)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reference,
                decoration: fieldDecoration('Reference (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: fieldDecoration('Description (optional)'),
                maxLines: 3,
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
            'recorded_on': DateFormat('yyyy-MM-dd').format(_date),
            'category': _category,
            'amount': double.parse(_amount.text).toStringAsFixed(2),
            'party': _party.text.trim().isEmpty ? null : _party.text.trim(),
            'reference': _reference.text.trim().isEmpty
                ? null
                : _reference.text.trim(),
            'description': _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
          });
        },
        child: Text(widget.income ? 'Post income' : 'Post expense'),
      ),
    ],
  );
}

import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/formatting/pkr.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/commerce/application/commercial_party_providers.dart';
import 'package:dairycare_mobile/features/commerce/domain/commercial_party_models.dart';
import 'package:dairycare_mobile/features/commerce/domain/milk_sale_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final class MilkSalesScreen extends ConsumerStatefulWidget {
  const MilkSalesScreen({super.key});
  @override
  ConsumerState<MilkSalesScreen> createState() => _MilkSalesScreenState();
}

final class _MilkSalesScreenState extends ConsumerState<MilkSalesScreen> {
  String filter = 'all';
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final overview = ref.watch(milkSalesProvider);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(milkSalesProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  eyebrow: 'Daily milk sales - Doodh farokht',
                  title: 'Milk Sales',
                  subtitle:
                      'Sellable doodh ka batch choose karein, invoice confirm karein aur customer payment ka record rakhein.',
                  actions: [
                    if (session?.can('milk_sales.manage') ?? false)
                      FilledButton.icon(
                        key: const Key('add_milk_sale_action'),
                        onPressed: _create,
                        icon: const Icon(Icons.add_business),
                        label: const Text('New milk invoice'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                overview.when(
                  loading: () =>
                      const LoadingStateView(label: 'Loading milk sales...'),
                  error: (e, _) => ErrorStateView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(milkSalesProvider),
                  ),
                  data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BatchStrip(batches: data.batches),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children:
                            [
                                  'all',
                                  'draft',
                                  'confirmed',
                                  'cancelled',
                                  'unpaid',
                                  'partially_paid',
                                  'paid',
                                ]
                                .map(
                                  (s) => ChoiceChip(
                                    label: Text(s.replaceAll('_', ' ')),
                                    selected: filter == s,
                                    onSelected: (_) =>
                                        setState(() => filter = s),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (_) {
                          final rows = data.sales
                              .where(
                                (s) =>
                                    filter == 'all' ||
                                    s.status == filter ||
                                    s.paymentStatus == filter,
                              )
                              .toList();
                          if (rows.isEmpty) {
                            return const EmptyStateView(
                              title: 'No milk sales',
                              message: 'Pehla milk invoice banayein.',
                              icon: Icons.local_drink_outlined,
                            );
                          }
                          return Column(
                            children: rows
                                .map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _SaleCard(
                                      sale: s,
                                      onConfirm:
                                          (session?.can('milk_sales.confirm') ??
                                                  false) &&
                                              s.status == 'draft'
                                          ? () => _confirm(s)
                                          : null,
                                      onPay:
                                          (session?.can(
                                                    'customer_payments.manage',
                                                  ) ??
                                                  false) &&
                                              s.status == 'confirmed' &&
                                              s.paymentStatus != 'paid'
                                          ? () => _pay(s)
                                          : null,
                                      onCancel:
                                          (session?.can('milk_sales.cancel') ??
                                                  false) &&
                                              s.status == 'confirmed' &&
                                              double.parse(s.paid) == 0
                                          ? () => _cancel(s)
                                          : null,
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _create() async {
    final data = await ref.read(milkSalesProvider.future);
    final customers = await ref.read(
      commercialPartiesProvider('customers').future,
    );
    if (!mounted) return;
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _SaleDialog(batches: data.batches, customers: customers),
    );
    if (payload != null) {
      await _action(
        () => ref.read(milkSalesRepositoryProvider).create(payload),
        'Milk invoice draft created.',
      );
    }
  }

  Future<void> _confirm(MilkSale s) => _action(
    () => ref.read(milkSalesRepositoryProvider).confirm(s.id),
    'Sale confirmed and sellable milk deducted.',
  );
  Future<void> _pay(MilkSale s) async {
    final p = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _CustomerPaymentDialog(sale: s),
    );
    if (p != null) {
      await _action(
        () => ref.read(milkSalesRepositoryProvider).pay(s.id, p),
        'Customer payment recorded.',
      );
    }
  }

  Future<void> _cancel(MilkSale s) async {
    final c = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (x) => AlertDialog(
        title: const Text('Cancel milk sale?'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'Cancellation reason *'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(x),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(x, c.text.trim()),
            child: const Text('Cancel sale'),
          ),
        ],
      ),
    );
    if (reason != null && reason.isNotEmpty) {
      await _action(
        () => ref.read(milkSalesRepositoryProvider).cancel(s.id, reason),
        'Sale cancelled and milk restored.',
      );
    }
  }

  Future<void> _action(Future<Object> Function() w, String m) async {
    try {
      await w();
      ref.invalidate(milkSalesProvider);
      ref.invalidate(commercialPartiesProvider('customers'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

final class _BatchStrip extends StatelessWidget {
  const _BatchStrip({required this.batches});
  final List<MilkBatchAvailability> batches;
  @override
  Widget build(BuildContext context) => GlassSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available sellable milk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text(
          'Rejected aur dawa-restricted doodh is quantity mein shamil nahi hai.',
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: batches
              .take(10)
              .map(
                (b) => Chip(
                  avatar: const Icon(Icons.water_drop, size: 17),
                  label: Text(
                    '${DateFormat.MMMd().format(b.date)}: ${b.available} L',
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
}

final class _SaleCard extends StatelessWidget {
  const _SaleCard({
    required this.sale,
    this.onConfirm,
    this.onPay,
    this.onCancel,
  });
  final MilkSale sale;
  final VoidCallback? onConfirm, onPay, onCancel;
  @override
  Widget build(BuildContext context) => GlassSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(child: Icon(Icons.local_drink)),
          title: Text('${sale.number} - ${sale.customerName}'),
          subtitle: Text(
            '${DateFormat.yMMMd().format(sale.batchDate)} batch - ${sale.quantity} L\n${sale.status} - ${sale.deliveryStatus} - ${sale.paymentStatus}',
          ),
          isThreeLine: true,
          trailing: Text(
            formatPkr(sale.balance),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Wrap(
          spacing: 14,
          children: [
            Text('Rate ${formatPkr(sale.baseRate)}/L'),
            Text('Total ${formatPkr(sale.total)}'),
            Text('Paid ${formatPkr(sale.paid)}'),
          ],
        ),
        if (sale.payments.isNotEmpty) ...[
          const Divider(),
          const Text(
            'Payment history',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...sale.payments.map(
            (p) => Text(
              '${p.number} - ${formatPkr(p.amount)} - ${DateFormat.yMMMd().format(p.date)} - ${p.method.replaceAll('_', ' ')}',
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            if (onConfirm != null)
              FilledButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirm & deduct milk'),
              ),
            if (onPay != null)
              FilledButton.tonalIcon(
                onPressed: onPay,
                icon: const Icon(Icons.payments),
                label: const Text('Record payment'),
              ),
            if (onCancel != null)
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel & restore milk'),
              ),
          ],
        ),
      ],
    ),
  );
}

final class _SaleDialog extends StatefulWidget {
  const _SaleDialog({required this.batches, required this.customers});
  final List<MilkBatchAvailability> batches;
  final List<CommercialParty> customers;
  @override
  State<_SaleDialog> createState() => _SaleDialogState();
}

final class _SaleDialogState extends State<_SaleDialog> {
  final key = GlobalKey<FormState>();
  String? customer;
  DateTime? batch;
  String quantity = '',
      rate = '',
      fat = '0',
      snf = '0',
      quality = '0',
      discount = '0',
      tax = '0',
      delivery = '0',
      driver = '',
      vehicle = '';
  String? nonnegative(String? v) {
    final n = double.tryParse(v ?? '');
    return n == null || n < 0 ? 'Digits only.' : null;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('New milk invoice'),
    content: SizedBox(
      width: 700,
      height: 560,
      child: Form(
        key: key,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Customer *'),
              items: widget.customers
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.code} - ${c.name}'),
                    ),
                  )
                  .toList(),
              validator: (v) => v == null ? 'Choose customer.' : null,
              onChanged: (v) => customer = v,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<DateTime>(
              decoration: const InputDecoration(labelText: 'Milk batch date *'),
              items: widget.batches
                  .where((b) => double.parse(b.available) > 0)
                  .map(
                    (b) => DropdownMenuItem(
                      value: b.date,
                      child: Text(
                        '${DateFormat.yMMMd().format(b.date)} - ${b.available} L available',
                      ),
                    ),
                  )
                  .toList(),
              validator: (v) => v == null ? 'Choose available batch.' : null,
              onChanged: (v) => setState(() => batch = v),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Quantity litres *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      final available = batch == null
                          ? 0
                          : double.parse(
                              widget.batches
                                  .firstWhere((b) => b.date == batch)
                                  .available,
                            );
                      return n == null || n <= 0 || n > available
                          ? 'Enter available litres.'
                          : null;
                    },
                    onChanged: (v) => quantity = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Base rate PKR/litre *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: nonnegative,
                    onChanged: (v) => rate = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in [
                  ('Fat adjustment', (String v) => fat = v),
                  ('SNF adjustment', (String v) => snf = v),
                  ('Quality adjustment', (String v) => quality = v),
                  ('Discount PKR', (String v) => discount = v),
                  ('Tax PKR', (String v) => tax = v),
                  ('Delivery PKR', (String v) => delivery = v),
                ])
                  SizedBox(
                    width: 205,
                    child: TextFormField(
                      initialValue: '0',
                      decoration: InputDecoration(labelText: f.$1),
                      keyboardType: TextInputType.number,
                      validator: f.$1.contains('adjustment')
                          ? null
                          : nonnegative,
                      onChanged: f.$2,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Driver'),
                    onChanged: (v) => driver = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Vehicle'),
                    onChanged: (v) => vehicle = v,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('save_milk_sale_action'),
        onPressed: () {
          if (!key.currentState!.validate()) return;
          Navigator.pop(context, {
            'customer_id': customer,
            'sold_at': DateTime.now().toIso8601String(),
            'milk_batch_date': DateFormat('yyyy-MM-dd').format(batch!),
            'quantity_litres': quantity,
            'base_rate': rate,
            'fat_adjustment': fat,
            'snf_adjustment': snf,
            'quality_adjustment': quality,
            'discount': discount,
            'tax': tax,
            'delivery_charges': delivery,
            'driver': driver.trim().isEmpty ? null : driver.trim(),
            'vehicle': vehicle.trim().isEmpty ? null : vehicle.trim(),
          });
        },
        child: const Text('Create draft'),
      ),
    ],
  );
}

final class _CustomerPaymentDialog extends StatefulWidget {
  const _CustomerPaymentDialog({required this.sale});
  final MilkSale sale;
  @override
  State<_CustomerPaymentDialog> createState() => _CustomerPaymentDialogState();
}

final class _CustomerPaymentDialogState extends State<_CustomerPaymentDialog> {
  final key = GlobalKey<FormState>();
  late String amount;
  String method = 'cash', reference = '';
  @override
  void initState() {
    super.initState();
    amount = widget.sale.balance;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Customer payment - ${widget.sale.number}'),
    content: SizedBox(
      width: 430,
      child: Form(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Outstanding ${formatPkr(widget.sale.balance)}'),
            TextFormField(
              initialValue: amount,
              decoration: const InputDecoration(labelText: 'Amount PKR *'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = double.tryParse(v ?? '');
                return n == null ||
                        n <= 0 ||
                        n > double.parse(widget.sale.balance)
                    ? 'Enter digits up to balance.'
                    : null;
              },
              onChanged: (v) => amount = v,
            ),
            DropdownButtonFormField<String>(
              initialValue: method,
              decoration: const InputDecoration(labelText: 'Method'),
              items:
                  const [
                        'cash',
                        'bank_transfer',
                        'cheque',
                        'mobile_wallet',
                        'other',
                      ]
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.replaceAll('_', ' ')),
                        ),
                      )
                      .toList(),
              onChanged: (v) => method = v!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Reference'),
              onChanged: (v) => reference = v,
            ),
          ],
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
          if (!key.currentState!.validate()) return;
          Navigator.pop(context, {
            'payment_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
            'amount': amount,
            'payment_method': method,
            'reference': reference.trim().isEmpty ? null : reference.trim(),
          });
        },
        child: const Text('Save payment'),
      ),
    ],
  );
}

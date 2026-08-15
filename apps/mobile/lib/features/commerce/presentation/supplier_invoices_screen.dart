import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/formatting/pkr.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/commerce/application/commercial_party_providers.dart';
import 'package:dairycare_mobile/features/commerce/domain/purchase_models.dart';
import 'package:dairycare_mobile/features/commerce/domain/supplier_invoice_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final class SupplierInvoicesScreen extends ConsumerStatefulWidget {
  const SupplierInvoicesScreen({super.key});
  @override
  ConsumerState<SupplierInvoicesScreen> createState() =>
      _SupplierInvoicesScreenState();
}

final class _SupplierInvoicesScreenState
    extends ConsumerState<SupplierInvoicesScreen> {
  String filter = 'all';
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final invoices = ref.watch(supplierInvoicesProvider);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(supplierInvoicesProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  eyebrow: 'Supplier payable - Adaigi',
                  title: 'Supplier Invoices',
                  subtitle:
                      'Purchase order ka bill banayein aur supplier ko di gayi har PKR payment ka record rakhein.',
                  actions: [
                    if (session?.can('supplier_invoices.manage') ?? false)
                      FilledButton.icon(
                        key: const Key('add_supplier_invoice_action'),
                        onPressed: _create,
                        icon: const Icon(Icons.note_add),
                        label: const Text('Create invoice'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children:
                      ['all', 'unpaid', 'partially_paid', 'paid', 'overdue']
                          .map(
                            (s) => ChoiceChip(
                              label: Text(s.replaceAll('_', ' ')),
                              selected: filter == s,
                              onSelected: (_) => setState(() => filter = s),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),
                invoices.when(
                  loading: () => const LoadingStateView(
                    label: 'Loading supplier invoices...',
                  ),
                  error: (e, _) => ErrorStateView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(supplierInvoicesProvider),
                  ),
                  data: (rows) {
                    final shown = rows
                        .where(
                          (i) =>
                              filter == 'all' ||
                              (filter == 'overdue'
                                  ? i.overdue
                                  : i.status == filter),
                        )
                        .toList();
                    if (shown.isEmpty) {
                      return const EmptyStateView(
                        title: 'No supplier invoices',
                        message:
                            'Eligible purchase order se invoice create karein.',
                        icon: Icons.receipt_long_outlined,
                      );
                    }
                    return Column(
                      children: shown
                          .map(
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _InvoiceCard(
                                invoice: i,
                                onPay:
                                    (session?.can('supplier_payments.manage') ??
                                            false) &&
                                        i.status != 'paid'
                                    ? () => _pay(i)
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
        ),
      ),
    );
  }

  Future<void> _create() async {
    final orders = await ref.read(purchaseOrdersProvider.future);
    final invoices = await ref.read(supplierInvoicesProvider.future);
    final used = invoices.map((i) => i.purchaseOrderId).toSet();
    final eligible = orders
        .where(
          (o) =>
              [
                'approved',
                'partially_received',
                'received',
              ].contains(o.status) &&
              !used.contains(o.id),
        )
        .toList();
    if (!mounted) return;
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _InvoiceDialog(orders: eligible),
    );
    if (data != null) {
      await _action(
        () => ref.read(supplierInvoiceRepositoryProvider).create(data),
        'Supplier invoice created.',
      );
    }
  }

  Future<void> _pay(SupplierInvoice i) async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _PaymentDialog(invoice: i),
    );
    if (data != null) {
      await _action(
        () => ref.read(supplierInvoiceRepositoryProvider).pay(i.id, data),
        'Supplier payment recorded.',
      );
    }
  }

  Future<void> _action(Future<Object> Function() work, String message) async {
    try {
      await work();
      ref.invalidate(supplierInvoicesProvider);
      ref.invalidate(commercialPartiesProvider('suppliers'));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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

final class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice, this.onPay});
  final SupplierInvoice invoice;
  final VoidCallback? onPay;
  @override
  Widget build(BuildContext context) => GlassSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            child: Icon(
              invoice.overdue ? Icons.warning_amber : Icons.receipt_long,
            ),
          ),
          title: Text('${invoice.number} - ${invoice.supplierName}'),
          subtitle: Text(
            '${invoice.purchaseNumber} - Supplier bill ${invoice.externalNumber}\nDue ${DateFormat.yMMMd().format(invoice.dueDate)} - ${invoice.overdue ? 'OVERDUE' : invoice.status.replaceAll('_', ' ')}',
          ),
          isThreeLine: true,
          trailing: Text(
            formatPkr(invoice.balance),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Wrap(
          spacing: 16,
          children: [
            Text('Total ${formatPkr(invoice.total)}'),
            Text('Paid ${formatPkr(invoice.paid)}'),
            Text('Balance ${formatPkr(invoice.balance)}'),
          ],
        ),
        if (invoice.payments.isNotEmpty) ...[
          const Divider(),
          const Text(
            'Payment history',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...invoice.payments.map(
            (p) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${p.number} - ${formatPkr(p.amount)}'),
              subtitle: Text(
                '${DateFormat.yMMMd().format(p.date)} - ${p.method.replaceAll('_', ' ')}${p.reference == null ? '' : ' - ${p.reference}'}',
              ),
            ),
          ),
        ],
        if (onPay != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: ValueKey('pay-${invoice.id}'),
              onPressed: onPay,
              icon: const Icon(Icons.payments),
              label: const Text('Record payment'),
            ),
          ),
        ],
      ],
    ),
  );
}

final class _InvoiceDialog extends StatefulWidget {
  const _InvoiceDialog({required this.orders});
  final List<PurchaseOrder> orders;
  @override
  State<_InvoiceDialog> createState() => _InvoiceDialogState();
}

final class _InvoiceDialogState extends State<_InvoiceDialog> {
  final key = GlobalKey<FormState>();
  String? orderId;
  String external = '';
  DateTime due = DateTime.now().add(const Duration(days: 30));
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create supplier invoice'),
    content: SizedBox(
      width: 520,
      child: Form(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.orders.isEmpty)
              const Text(
                'No eligible purchase orders. Approve a purchase order first.',
              ),
            if (widget.orders.isNotEmpty)
              DropdownButtonFormField<String>(
                key: const Key('invoice_purchase_order_field'),
                decoration: const InputDecoration(
                  labelText: 'Purchase order *',
                ),
                items: widget.orders
                    .map(
                      (o) => DropdownMenuItem(
                        value: o.id,
                        child: Text(
                          '${o.number} - ${o.supplierName} - ${formatPkr(o.total)}',
                        ),
                      ),
                    )
                    .toList(),
                validator: (v) => v == null ? 'Choose purchase order.' : null,
                onChanged: (v) => orderId = v,
              ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Supplier invoice number *',
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Invoice number required.' : null,
              onChanged: (v) => external = v,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due date'),
              subtitle: Text(DateFormat.yMMMd().format(due)),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: due,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (d != null) setState(() => due = d);
              },
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
      if (widget.orders.isNotEmpty)
        FilledButton(
          key: const Key('save_supplier_invoice_action'),
          onPressed: () {
            if (!key.currentState!.validate()) return;
            Navigator.pop(context, {
              'purchase_order_id': orderId,
              'supplier_invoice_number': external.trim(),
              'invoice_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
              'due_date': DateFormat('yyyy-MM-dd').format(due),
            });
          },
          child: const Text('Create invoice'),
        ),
    ],
  );
}

final class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.invoice});
  final SupplierInvoice invoice;
  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

final class _PaymentDialogState extends State<_PaymentDialog> {
  final key = GlobalKey<FormState>();
  late String amount;
  String method = 'cash', reference = '';
  @override
  void initState() {
    super.initState();
    amount = widget.invoice.balance;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Pay ${widget.invoice.number}'),
    content: SizedBox(
      width: 450,
      child: Form(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Outstanding ${formatPkr(widget.invoice.balance)}'),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('supplier_payment_amount_field'),
              initialValue: amount,
              decoration: const InputDecoration(
                labelText: 'Payment amount (PKR) *',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                return n == null ||
                        n <= 0 ||
                        n > double.parse(widget.invoice.balance)
                    ? 'Enter digits up to outstanding balance.'
                    : null;
              },
              onChanged: (v) => amount = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: method,
              decoration: const InputDecoration(labelText: 'Payment method *'),
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
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reference (optional)',
              ),
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
        key: const Key('save_supplier_payment_action'),
        onPressed: () {
          if (!key.currentState!.validate()) return;
          Navigator.pop(context, {
            'payment_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
            'amount': amount.trim(),
            'payment_method': method,
            'reference': reference.trim().isEmpty ? null : reference.trim(),
          });
        },
        child: const Text('Record payment'),
      ),
    ],
  );
}

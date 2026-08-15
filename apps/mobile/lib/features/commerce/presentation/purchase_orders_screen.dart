import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/formatting/pkr.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/commerce/application/commercial_party_providers.dart';
import 'package:dairycare_mobile/features/commerce/domain/purchase_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'purchase_order_dialogs.dart';

final class PurchaseOrdersScreen extends ConsumerStatefulWidget {
  const PurchaseOrdersScreen({super.key});
  @override
  ConsumerState<PurchaseOrdersScreen> createState() =>
      _PurchaseOrdersScreenState();
}

final class _PurchaseOrdersScreenState
    extends ConsumerState<PurchaseOrdersScreen> {
  String status = 'all';
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final orders = ref.watch(purchaseOrdersProvider);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(purchaseOrdersProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  eyebrow: 'Purchasing - Kharidari',
                  title: 'Purchase Orders',
                  subtitle:
                      'Supplier se order banayein, approve karein, phir batch aur expiry ke saath stock receive karein.',
                  actions: [
                    if (session?.can('purchases.manage') ?? false)
                      FilledButton.icon(
                        key: const Key('add_purchase_order_action'),
                        onPressed: _create,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('New purchase order'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children:
                      [
                            'all',
                            'draft',
                            'approved',
                            'partially_received',
                            'received',
                          ]
                          .map(
                            (s) => ChoiceChip(
                              label: Text(s.replaceAll('_', ' ')),
                              selected: status == s,
                              onSelected: (_) => setState(() => status = s),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),
                orders.when(
                  loading: () => const LoadingStateView(
                    label: 'Loading purchase orders...',
                  ),
                  error: (e, _) => ErrorStateView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(purchaseOrdersProvider),
                  ),
                  data: (rows) {
                    final shown = status == 'all'
                        ? rows
                        : rows.where((o) => o.status == status).toList();
                    if (shown.isEmpty) {
                      return const EmptyStateView(
                        title: 'No purchase orders',
                        message: 'Naya purchase order banayein.',
                        icon: Icons.shopping_cart_outlined,
                      );
                    }
                    return Column(
                      children: shown
                          .map(
                            (o) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _OrderCard(
                                order: o,
                                onApprove:
                                    (session?.can('purchases.approve') ??
                                            false) &&
                                        o.status == 'draft'
                                    ? () => _approve(o)
                                    : null,
                                onReceive:
                                    (session?.can('purchases.receive') ??
                                            false) &&
                                        [
                                          'approved',
                                          'partially_received',
                                        ].contains(o.status)
                                    ? () => _receive(o)
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
    final suppliers = await ref.read(
      commercialPartiesProvider('suppliers').future,
    );
    final items = await ref.read(purchaseInventoryItemsProvider.future);
    if (!mounted) return;
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => PurchaseOrderDialog(
        suppliers: suppliers,
        items: items,
        farmId: ref.read(authControllerProvider).asData!.value!.activeFarmId!,
      ),
    );
    if (data != null) {
      await _action(
        () => ref.read(purchaseRepositoryProvider).create(data),
        'Purchase order created.',
      );
    }
  }

  Future<void> _approve(PurchaseOrder o) => _action(
    () => ref.read(purchaseRepositoryProvider).approve(o.id),
    'Purchase order approved.',
  );
  Future<void> _receive(PurchaseOrder o) async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => GoodsReceiptDialog(order: o),
    );
    if (data != null) {
      await _action(
        () => ref.read(purchaseRepositoryProvider).receive(o.id, data),
        'Goods received and inventory updated.',
      );
    }
  }

  Future<void> _action(Future<Object> Function() work, String message) async {
    try {
      await work();
      ref.invalidate(purchaseOrdersProvider);
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

final class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, this.onApprove, this.onReceive});
  final PurchaseOrder order;
  final VoidCallback? onApprove, onReceive;
  @override
  Widget build(BuildContext context) => GlassSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                title: Text('${order.number} - ${order.supplierName}'),
                subtitle: Text(
                  '${DateFormat.yMMMd().format(order.purchaseDate)} - ${order.status.replaceAll('_', ' ')}',
                ),
              ),
            ),
            Text(
              formatPkr(order.total),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const Divider(),
        ...order.lines.map(
          (l) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(l.itemName),
            subtitle: Text(
              '${l.orderedQuantity} ${l.unit} ordered - ${l.receivedQuantity} received',
            ),
            trailing: Text('${formatPkr(l.unitRate)}/${l.unit}'),
          ),
        ),
        if (order.receipts.isNotEmpty) ...[
          const Divider(),
          const Text('Receipt history'),
          ...order.receipts.map(
            (r) => Text(
              '${r.number} - ${DateFormat.yMMMd().add_jm().format(r.receivedAt.toLocal())} - ${r.qualityStatus.replaceAll('_', ' ')}',
            ),
          ),
        ],
        if (onApprove != null || onReceive != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              if (onApprove != null)
                FilledButton.tonalIcon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.approval),
                  label: const Text('Approve'),
                ),
              if (onReceive != null)
                FilledButton.icon(
                  onPressed: onReceive,
                  icon: const Icon(Icons.inventory),
                  label: const Text('Receive goods'),
                ),
            ],
          ),
        ],
      ],
    ),
  );
}

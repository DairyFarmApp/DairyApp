import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/inventory/application/inventory_providers.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final class StockUsageIndentsScreen extends ConsumerStatefulWidget {
  const StockUsageIndentsScreen({super.key});

  @override
  ConsumerState<StockUsageIndentsScreen> createState() =>
      _StockUsageIndentsScreenState();
}

final class _StockUsageIndentsScreenState
    extends ConsumerState<StockUsageIndentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _purpose = TextEditingController();
  String? _itemId;
  bool _saving = false;

  @override
  void dispose() {
    _quantity.dispose();
    _purpose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final canView = session?.can('inventory.view') ?? false;
    final canManage = session?.can('inventory.manage') ?? false;
    if (!canView) {
      return const Scaffold(
        body: EmptyStateView(
          message: 'You do not have permission to view stock usage.',
        ),
      );
    }
    final items = ref.watch(stockUsageItemsProvider);
    final history = ref.watch(stockUsageHistoryProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContent(
            maxWidth: 1100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageHeader(
                  eyebrow: 'Daily operations',
                  title: 'Stock Usage',
                  subtitle:
                      'Record feed, medicine, semen, and other stock used today. Saved quantities are deducted from inventory immediately.',
                ),
                const SizedBox(height: 20),
                if (canManage) _usageForm(items),
                if (canManage) const SizedBox(height: 20),
                _history(history),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _usageForm(AsyncValue<List<InventoryItem>> items) => SectionCard(
    title: 'Record stock used',
    subtitle: 'The quantity cannot be greater than current inventory stock.',
    child: items.when(
      loading: () => const LoadingStateView(label: 'Loading stock items...'),
      error: (error, _) => ErrorStateView(
        message: error.toString(),
        onRetry: () => ref.invalidate(stockUsageItemsProvider),
      ),
      data: (available) {
        if (available.isEmpty) {
          return const EmptyStateView(
            message: 'No inventory item currently has available stock.',
          );
        }
        final selected = available
            .where((item) => item.id == _itemId)
            .firstOrNull;
        return Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                key: const Key('stock_usage_item'),
                initialValue: available.any((item) => item.id == _itemId)
                    ? _itemId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Inventory item *',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                items: [
                  for (final item in available)
                    DropdownMenuItem(
                      value: item.id,
                      child: Text(
                        '${item.name} · ${item.currentStock} ${item.unit}',
                      ),
                    ),
                ],
                validator: (value) => value == null ? 'Select an item.' : null,
                onChanged: (value) => setState(() => _itemId = value),
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('stock_usage_quantity'),
                controller: _quantity,
                decoration: InputDecoration(
                  labelText: 'Quantity used *',
                  suffixText: selected?.unit,
                  prefixIcon: const Icon(Icons.remove_circle_outline),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                ],
                validator: (value) {
                  final quantity = double.tryParse(value ?? '');
                  if (quantity == null || quantity <= 0) {
                    return 'Enter a quantity greater than zero.';
                  }
                  if (selected != null &&
                      quantity > double.parse(selected.currentStock)) {
                    return 'Only ${selected.currentStock} ${selected.unit} is available.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('stock_usage_purpose'),
                controller: _purpose,
                decoration: const InputDecoration(
                  labelText: 'Purpose / used for *',
                  hintText: 'Example: Morning feed for lactating animals',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLength: 500,
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Enter where or why the stock was used.'
                    : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  key: const Key('save_stock_usage'),
                  onPressed: _saving || selected == null
                      ? null
                      : () => _save(selected),
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: const Text('Record usage'),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  Widget _history(AsyncValue<List<StockUsageRecord>> history) => SectionCard(
    title: 'Recent stock usage',
    subtitle: 'A permanent record of inventory deductions.',
    child: history.when(
      loading: () => const LoadingStateView(label: 'Loading usage history...'),
      error: (error, _) => ErrorStateView(
        message: error.toString(),
        onRetry: () => ref.invalidate(stockUsageHistoryProvider),
      ),
      data: (records) => records.isEmpty
          ? const EmptyStateView(message: 'No stock usage recorded yet.')
          : Column(
              children: [
                for (final record in records) ...[
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.inventory_outlined),
                    ),
                    title: Text(
                      '${record.itemName} · ${record.quantity} ${record.unit}',
                    ),
                    subtitle: Text(
                      '${record.purpose}\n${DateFormat('dd MMM yyyy, hh:mm a').format(record.occurredAt)} · ${record.kind.label} · Batch ${record.batchNumber}',
                    ),
                    isThreeLine: true,
                  ),
                  if (record != records.last) const Divider(height: 1),
                ],
              ],
            ),
    ),
  );

  Future<void> _save(InventoryItem item) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(inventoryRepositoryProvider)
          .recordStockUsage(
            item,
            quantity: double.parse(_quantity.text).toStringAsFixed(3),
            purpose: _purpose.text.trim(),
          );
      _quantity.clear();
      _purpose.clear();
      _itemId = null;
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock usage recorded and inventory deducted.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(stockUsageItemsProvider);
    ref.invalidate(stockUsageHistoryProvider);
    ref.invalidate(inventoryDashboardProvider);
    for (final kind in InventoryKind.values) {
      ref.invalidate(
        inventoryOverviewProvider((
          kind: kind,
          search: '',
          category: null,
          supplier: null,
          lowStock: false,
        )),
      );
    }
    await Future.wait([
      ref.read(stockUsageItemsProvider.future),
      ref.read(stockUsageHistoryProvider.future),
    ]);
  }
}

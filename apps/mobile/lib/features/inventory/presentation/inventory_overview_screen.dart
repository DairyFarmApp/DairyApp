import 'dart:async';

import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/files/export_file_saver.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/inventory/application/inventory_providers.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:dairycare_mobile/features/inventory/presentation/inventory_date_field.dart';
import 'package:dairycare_mobile/features/inventory/presentation/inventory_form_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class InventoryOverviewScreen extends ConsumerStatefulWidget {
  const InventoryOverviewScreen({super.key, required this.kind});

  final InventoryKind kind;

  @override
  ConsumerState<InventoryOverviewScreen> createState() =>
      _InventoryOverviewScreenState();
}

class _InventoryOverviewScreenState
    extends ConsumerState<InventoryOverviewScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _searchValue = '';
  String? _category;
  String? _supplier;
  bool _lowStock = false;
  final _fromDate = TextEditingController();
  final _toDate = TextEditingController();
  final Set<String> _selectedIds = {};
  bool _exporting = false;

  InventoryQuery get _query => (
    kind: widget.kind,
    search: _searchValue,
    category: _category,
    supplier: _supplier,
    lowStock: _lowStock,
  );

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _fromDate.dispose();
    _toDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(inventoryOverviewProvider(_query));
    final canManage =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('inventory.manage') ??
        false;
    final canExport =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('inventory.export') ??
        false;
    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsiveContent(
          maxWidth: 1440,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                eyebrow: 'Manage inventory',
                title: '${widget.kind.label} inventory',
                subtitle:
                    'Monitor stock, value, low levels, expiring batches, and supplier receipts.',
                actions: [
                  OutlinedButton.icon(
                    onPressed: () => context.go('/inventory'),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('All inventory'),
                  ),
                  if (canManage)
                    FilledButton.icon(
                      onPressed: () =>
                          context.go('/inventory/${widget.kind.apiValue}/new'),
                      icon: const Icon(Icons.add_rounded),
                      label: Text('Add ${widget.kind.label.toLowerCase()}'),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              overview.when(
                loading: () =>
                    const LoadingStateView(label: 'Loading stock overview…'),
                error: (error, _) => ErrorStateView(
                  message: error.toString(),
                  onRetry: () =>
                      ref.invalidate(inventoryOverviewProvider(_query)),
                ),
                data: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SummaryGrid(summary: data.summary),
                    const SizedBox(height: 18),
                    GlassSurface(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final narrow = constraints.maxWidth < 780;
                          final fields = [
                            SizedBox(
                              width: narrow ? constraints.maxWidth : 340,
                              child: TextField(
                                key: const Key('inventory_search'),
                                controller: _search,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search_rounded),
                                  labelText:
                                      'Search name, code, brand, or barcode',
                                ),
                                onChanged: (value) {
                                  _debounce?.cancel();
                                  _debounce = Timer(
                                    const Duration(milliseconds: 350),
                                    () => setState(() {
                                      _searchValue = value;
                                      _selectedIds.clear();
                                    }),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: narrow ? constraints.maxWidth : 220,
                              child: DropdownButtonFormField<String>(
                                initialValue: _category,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All categories'),
                                  ),
                                  for (final value in data.categories)
                                    DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ),
                                ],
                                onChanged: (value) => setState(() {
                                  _category = value;
                                  _selectedIds.clear();
                                }),
                              ),
                            ),
                            SizedBox(
                              width: narrow ? constraints.maxWidth : 220,
                              child: DropdownButtonFormField<String>(
                                initialValue: _supplier,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Supplier',
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All suppliers'),
                                  ),
                                  for (final value in data.suppliers)
                                    DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ),
                                ],
                                onChanged: (value) => setState(() {
                                  _supplier = value;
                                  _selectedIds.clear();
                                }),
                              ),
                            ),
                            FilterChip(
                              selected: _lowStock,
                              avatar: const Icon(Icons.warning_amber_rounded),
                              label: const Text('Low stock only'),
                              onSelected: (value) => setState(() {
                                _lowStock = value;
                                _selectedIds.clear();
                              }),
                            ),
                          ];
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: fields,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (canExport) ...[
                      _ExportBar(
                        fromDate: _fromDate,
                        toDate: _toDate,
                        selectedCount: _selectedIds.length,
                        totalCount: data.items.length,
                        exporting: _exporting,
                        onSelectAll: () => setState(() {
                          _selectedIds
                            ..clear()
                            ..addAll(data.items.map((item) => item.id));
                        }),
                        onClearSelection: () => setState(_selectedIds.clear),
                        onReceipt: () => _export(
                          InventoryExportFormat.receipt,
                          _selectedIds.isEmpty
                              ? data.items.map((item) => item.id).toSet()
                              : Set.of(_selectedIds),
                        ),
                        onSpreadsheet: () => _export(
                          InventoryExportFormat.spreadsheet,
                          _selectedIds.isEmpty
                              ? data.items.map((item) => item.id).toSet()
                              : Set.of(_selectedIds),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    if (data.items.isEmpty)
                      const GlassSurface(
                        child: EmptyStateView(
                          message:
                              'No stock items match these filters. Add the first item to begin.',
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth >= 980
                            ? _InventoryTable(
                                items: data.items,
                                canManage: canManage,
                                canExport: canExport,
                                selectedIds: _selectedIds,
                                onSelected: _selectItem,
                                onReceipt: _receiveStock,
                                onEdit: _editItem,
                                onArchive: _archiveItem,
                                onReceiptExport: _singleReceipt,
                              )
                            : _InventoryCards(
                                items: data.items,
                                canManage: canManage,
                                canExport: canExport,
                                selectedIds: _selectedIds,
                                onSelected: _selectItem,
                                onReceipt: _receiveStock,
                                onEdit: _editItem,
                                onArchive: _archiveItem,
                                onReceiptExport: _singleReceipt,
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

  Future<void> _receiveStock(InventoryItem item) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _ReceiptDialog(item: item),
    );
    if (saved ?? false) {
      ref.invalidate(inventoryOverviewProvider(_query));
      ref.invalidate(inventoryDashboardProvider);
    }
  }

  void _selectItem(InventoryItem item, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(item.id);
      } else {
        _selectedIds.remove(item.id);
      }
    });
  }

  Future<void> _editItem(InventoryItem item) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EditItemDialog(item: item),
    );
    if (saved ?? false) {
      ref.invalidate(inventoryOverviewProvider(_query));
      ref.invalidate(inventoryDashboardProvider);
    }
  }

  Future<void> _archiveItem(InventoryItem item) async {
    if (double.parse(item.currentStock) != 0) {
      _message(
        'This item still has ${item.currentStock} ${item.unit}. Record usage or an approved adjustment before deleting it.',
      );
      return;
    }
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete ${item.name}?'),
            content: const Text(
              'The item will be archived. Its batches, receipts, and stock movement history will be kept for audit.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archive item'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    try {
      await ref.read(inventoryRepositoryProvider).archiveItem(item);
      _selectedIds.remove(item.id);
      ref.invalidate(inventoryOverviewProvider(_query));
      ref.invalidate(inventoryDashboardProvider);
      _message('${item.name} was archived.');
    } catch (error) {
      _message(error.toString());
    }
  }

  Future<void> _singleReceipt(InventoryItem item) =>
      _export(InventoryExportFormat.receipt, {item.id});

  Future<void> _export(
    InventoryExportFormat format,
    Set<String> itemIds,
  ) async {
    if (itemIds.isEmpty) {
      _message('There are no inventory items to export.');
      return;
    }
    final from = DateTime.tryParse(_fromDate.text);
    final to = DateTime.tryParse(_toDate.text);
    if (from != null && to != null && to.isBefore(from)) {
      _message('The end date must be on or after the start date.');
      return;
    }
    setState(() => _exporting = true);
    try {
      final file = await ref
          .read(inventoryRepositoryProvider)
          .export(
            widget.kind,
            format,
            itemIds: itemIds,
            fromDate: from,
            toDate: to,
          );
      final saved = await const ExportFileSaver().save(
        bytes: file.bytes,
        filename: file.filename,
        mimeType: file.mimeType,
      );
      if (saved) _message('${file.filename} is ready.');
    } catch (error) {
      _message(error.toString());
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

final class _ExportBar extends StatelessWidget {
  const _ExportBar({
    required this.fromDate,
    required this.toDate,
    required this.selectedCount,
    required this.totalCount,
    required this.exporting,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.onReceipt,
    required this.onSpreadsheet,
  });

  final TextEditingController fromDate;
  final TextEditingController toDate;
  final int selectedCount;
  final int totalCount;
  final bool exporting;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final VoidCallback onReceipt;
  final VoidCallback onSpreadsheet;

  @override
  Widget build(BuildContext context) => GlassSurface(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 850;
        final fieldWidth = narrow
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.file_download_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipts and Excel export',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        selectedCount == 0
                            ? 'No rows selected: all $totalCount filtered items will be included.'
                            : '$selectedCount of $totalCount filtered items selected.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (!narrow)
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: exporting ? null : onSelectAll,
                        child: const Text('Select all'),
                      ),
                      TextButton(
                        onPressed: exporting || selectedCount == 0
                            ? null
                            : onClearSelection,
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: fieldWidth,
                  child: InventoryDateField(
                    controller: fromDate,
                    label: 'From date (optional)',
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: InventoryDateField(
                    controller: toDate,
                    label: 'To date (optional)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                if (narrow) ...[
                  TextButton(
                    onPressed: exporting ? null : onSelectAll,
                    child: const Text('Select all'),
                  ),
                  TextButton(
                    onPressed: exporting || selectedCount == 0
                        ? null
                        : onClearSelection,
                    child: const Text('Clear'),
                  ),
                ],
                OutlinedButton.icon(
                  onPressed: exporting || totalCount == 0 ? null : onReceipt,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('PDF receipt'),
                ),
                FilledButton.icon(
                  onPressed: exporting || totalCount == 0
                      ? null
                      : onSpreadsheet,
                  icon: exporting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.table_view_outlined),
                  label: const Text('Excel file'),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

final class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final InventorySummary summary;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final count = constraints.maxWidth >= 1180
          ? 5
          : constraints.maxWidth >= 720
          ? 3
          : 2;
      final width = (constraints.maxWidth - (count - 1) * 12) / count;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _metric(width, 'Total stock', summary.totalStock, Icons.inventory_2),
          _metric(
            width,
            'Stock value',
            _money(summary.totalValue),
            Icons.payments_outlined,
            const Color(0xFF2D9CDB),
          ),
          _metric(
            width,
            'Low stock',
            '${summary.lowStockItems}',
            Icons.warning_amber_rounded,
            const Color(0xFFDA4B8B),
          ),
          _metric(
            width,
            'Expiring soon',
            '${summary.expiringSoonBatches}',
            Icons.schedule_rounded,
            const Color(0xFFFF9A3C),
          ),
          _metric(
            width,
            'Expired',
            '${summary.expiredBatches}',
            Icons.event_busy_rounded,
            const Color(0xFF8F32C8),
          ),
        ],
      );
    },
  );

  Widget _metric(
    double width,
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) => SizedBox(
    width: width,
    height: 166,
    child: MetricCard(label: label, value: value, icon: icon, color: color),
  );
}

final class _InventoryCards extends StatelessWidget {
  const _InventoryCards({
    required this.items,
    required this.canManage,
    required this.canExport,
    required this.selectedIds,
    required this.onSelected,
    required this.onReceipt,
    required this.onEdit,
    required this.onArchive,
    required this.onReceiptExport,
  });

  final List<InventoryItem> items;
  final bool canManage;
  final bool canExport;
  final Set<String> selectedIds;
  final void Function(InventoryItem item, bool selected) onSelected;
  final ValueChanged<InventoryItem> onReceipt;
  final ValueChanged<InventoryItem> onEdit;
  final ValueChanged<InventoryItem> onArchive;
  final ValueChanged<InventoryItem> onReceiptExport;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final item in items) ...[
        GlassSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (canExport) ...[
                    Checkbox(
                      value: selectedIds.contains(item.id),
                      onChanged: (value) => onSelected(item, value ?? false),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('${item.itemCode} · ${item.category}'),
                      ],
                    ),
                  ),
                  _StatusPill(item: item),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text('Stock: ${item.currentStock} ${item.unit}'),
                  Text('Value: ${_money(item.totalValue)}'),
                  Text('Batches: ${item.batches.length}'),
                  if (item.brand != null) Text('Brand: ${item.brand}'),
                ],
              ),
              if (canManage || canExport) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      if (canExport)
                        OutlinedButton.icon(
                          onPressed: () => onReceiptExport(item),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Receipt'),
                        ),
                      if (canManage) ...[
                        OutlinedButton.icon(
                          onPressed: () => onEdit(item),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => onReceipt(item),
                          icon: const Icon(Icons.add_box_outlined),
                          label: const Text('Receive stock'),
                        ),
                        IconButton(
                          tooltip: 'Delete / archive item',
                          onPressed: () => onArchive(item),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    ],
  );
}

final class _InventoryTable extends StatelessWidget {
  const _InventoryTable({
    required this.items,
    required this.canManage,
    required this.canExport,
    required this.selectedIds,
    required this.onSelected,
    required this.onReceipt,
    required this.onEdit,
    required this.onArchive,
    required this.onReceiptExport,
  });

  final List<InventoryItem> items;
  final bool canManage;
  final bool canExport;
  final Set<String> selectedIds;
  final void Function(InventoryItem item, bool selected) onSelected;
  final ValueChanged<InventoryItem> onReceipt;
  final ValueChanged<InventoryItem> onEdit;
  final ValueChanged<InventoryItem> onArchive;
  final ValueChanged<InventoryItem> onReceiptExport;

  @override
  Widget build(BuildContext context) => GlassSurface(
    padding: const EdgeInsets.all(8),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Brand')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Value')),
          DataColumn(label: Text('Next expiry')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final item in items)
            DataRow(
              selected: selectedIds.contains(item.id),
              onSelectChanged: canExport
                  ? (value) => onSelected(item, value ?? false)
                  : null,
              cells: [
                DataCell(Text(item.itemCode)),
                DataCell(Text(item.name)),
                DataCell(Text(item.category)),
                DataCell(Text(item.brand ?? '—')),
                DataCell(Text('${item.currentStock} ${item.unit}')),
                DataCell(Text(_money(item.totalValue))),
                DataCell(Text(_nextExpiry(item))),
                DataCell(_StatusPill(item: item)),
                DataCell(
                  Wrap(
                    spacing: 2,
                    children: [
                      if (canExport)
                        IconButton(
                          tooltip: 'Download item receipt',
                          onPressed: () => onReceiptExport(item),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                        ),
                      if (canManage) ...[
                        IconButton(
                          tooltip: 'Edit item',
                          onPressed: () => onEdit(item),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Receive stock',
                          onPressed: () => onReceipt(item),
                          icon: const Icon(Icons.add_box_outlined),
                        ),
                        IconButton(
                          tooltip: 'Delete / archive item',
                          onPressed: () => onArchive(item),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

final class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final expired = item.batches.any((batch) => batch.isExpired);
    final (label, color) = expired
        ? ('Expired batch', Theme.of(context).colorScheme.error)
        : item.isLowStock
        ? ('Low stock', const Color(0xFFFF9A3C))
        : ('In stock', const Color(0xFF2BAE74));
    return Chip(
      label: Text(label),
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      backgroundColor: color.withValues(alpha: 0.12),
    );
  }
}

final class _EditItemDialog extends ConsumerStatefulWidget {
  const _EditItemDialog({required this.item});

  final InventoryItem item;

  @override
  ConsumerState<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends ConsumerState<_EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _barcode;
  late final TextEditingController _brand;
  late final TextEditingController _minimum;
  late final TextEditingController _maximum;
  late final TextEditingController _notes;
  late String _unit;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item.name);
    _category = TextEditingController(text: item.category);
    _barcode = TextEditingController(text: item.barcode);
    _brand = TextEditingController(text: item.brand);
    _minimum = TextEditingController(text: item.minimumStock);
    _maximum = TextEditingController(text: item.maximumStock);
    _notes = TextEditingController(text: item.notes);
    _unit = item.unit;
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _category,
      _barcode,
      _brand,
      _minimum,
      _maximum,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Edit ${widget.item.name}'),
    content: SizedBox(
      width: 680,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _field(_name, 'Name', required: true),
              _field(_category, 'Category', required: true),
              _field(_brand, 'Brand / company'),
              _field(_barcode, 'Barcode'),
              SizedBox(
                width: 300,
                child: DropdownButtonFormField<String>(
                  initialValue: _unit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: [
                    for (final unit in const [
                      'vial',
                      'bottle',
                      'packet',
                      'dose',
                      'straw',
                      'kg',
                      'bag',
                      'litre',
                    ])
                      DropdownMenuItem(value: unit, child: Text(unit)),
                  ],
                  onChanged: (value) => setState(() => _unit = value ?? _unit),
                ),
              ),
              _field(_minimum, 'Minimum stock', number: true, required: true),
              _field(
                _maximum,
                'Maximum stock',
                number: true,
                validator: (value) =>
                    validateMaximumStock(value, _minimum.text),
              ),
              SizedBox(
                width: 612,
                child: TextFormField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: const Text('Save changes'),
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool number = false,
    FormFieldValidator<String>? validator,
  }) => SizedBox(
    width: 300,
    child: TextFormField(
      controller: controller,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      decoration: InputDecoration(labelText: label),
      validator:
          validator ??
          (number
              ? (value) => validateInventoryDecimal(
                  value,
                  required: required,
                  decimalPlaces: 3,
                )
              : required
              ? (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null
              : null),
    ),
  );

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref.read(inventoryRepositoryProvider).updateItem(widget.item, {
        'name': _name.text.trim(),
        'category': _category.text.trim(),
        'barcode': _nullable(_barcode.text),
        'brand': _nullable(_brand.text),
        'unit': _unit,
        'minimum_stock': _minimum.text.trim(),
        'maximum_stock': _nullable(_maximum.text),
        'notes': _nullable(_notes.text),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
        setState(() => _saving = false);
      }
    }
  }
}

final class _ReceiptDialog extends ConsumerStatefulWidget {
  const _ReceiptDialog({required this.item});

  final InventoryItem item;

  @override
  ConsumerState<_ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends ConsumerState<_ReceiptDialog> {
  final _formKey = GlobalKey<FormState>();
  final _batch = TextEditingController();
  final _supplier = TextEditingController();
  final _purchase = TextEditingController();
  final _expiry = TextEditingController();
  final _quantity = TextEditingController();
  final _cost = TextEditingController();
  final _reason = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _batch,
      _supplier,
      _purchase,
      _expiry,
      _quantity,
      _cost,
      _reason,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Receive ${widget.item.name}'),
    content: SizedBox(
      width: 620,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _field(_batch, 'Batch number', required: true),
              _field(_supplier, 'Supplier'),
              SizedBox(
                width: 270,
                child: InventoryDateField(
                  controller: _purchase,
                  label: 'Purchase date',
                  validator: validateInventoryDate,
                ),
              ),
              SizedBox(
                width: 270,
                child: InventoryDateField(
                  controller: _expiry,
                  label: 'Expiry date',
                  validator: (value) =>
                      validateInventoryExpiry(value, _purchase.text),
                ),
              ),
              _field(
                _quantity,
                'Quantity (${widget.item.unit})',
                required: true,
                number: true,
                positive: true,
              ),
              _field(
                _cost,
                'Rate per unit',
                required: true,
                number: true,
                decimalPlaces: 4,
              ),
              SizedBox(
                width: 552,
                child: TextFormField(
                  controller: _reason,
                  decoration: const InputDecoration(
                    labelText: 'Notes / reason',
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: const Text('Save receipt'),
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool number = false,
    bool positive = false,
    int decimalPlaces = 3,
    FormFieldValidator<String>? validator,
  }) => SizedBox(
    width: 270,
    child: TextFormField(
      controller: controller,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      decoration: InputDecoration(labelText: label),
      validator:
          validator ??
          (number
              ? (value) => validateInventoryDecimal(
                  value,
                  required: required,
                  decimalPlaces: decimalPlaces,
                  positive: positive,
                )
              : required
              ? (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null
              : null),
    ),
  );

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref.read(inventoryRepositoryProvider).receiveStock(widget.item, {
        'batch_number': _batch.text.trim(),
        'supplier': _nullable(_supplier.text),
        'purchase_date': _nullable(_purchase.text),
        'expiry_date': _nullable(_expiry.text),
        'quantity': _quantity.text.trim(),
        'unit_cost': _cost.text.trim(),
        'reason': _nullable(_reason.text),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
        setState(() => _saving = false);
      }
    }
  }
}

String _nextExpiry(InventoryItem item) {
  final dates =
      item.batches
          .map((batch) => batch.expiryDate)
          .whereType<DateTime>()
          .toList()
        ..sort();
  if (dates.isEmpty) return '—';
  return dates.first.toIso8601String().split('T').first;
}

String _money(String value) => double.parse(value).toStringAsFixed(2);

String? _nullable(String value) => value.trim().isEmpty ? null : value.trim();

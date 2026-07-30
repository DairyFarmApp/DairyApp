import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/features/inventory/application/inventory_providers.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:dairycare_mobile/features/inventory/presentation/inventory_date_field.dart';
import 'package:dairycare_mobile/features/inventory/presentation/inventory_form_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class InventoryItemFormScreen extends ConsumerStatefulWidget {
  const InventoryItemFormScreen({super.key, required this.kind});

  final InventoryKind kind;

  @override
  ConsumerState<InventoryItemFormScreen> createState() =>
      _InventoryItemFormScreenState();
}

class _InventoryItemFormScreenState
    extends ConsumerState<InventoryItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _barcode = TextEditingController();
  final _batch = TextEditingController();
  final _supplier = TextEditingController();
  final _purchase = TextEditingController();
  final _expiry = TextEditingController();
  final _quantity = TextEditingController();
  final _cost = TextEditingController();
  final _minimum = TextEditingController(text: '0');
  final _maximum = TextEditingController();
  final _notes = TextEditingController();
  String? _category;
  late String _unit;
  bool _saving = false;

  List<String> get _categories => switch (widget.kind) {
    InventoryKind.medicine => const [
      'Injection',
      'Syrup',
      'Tablet',
      'Spray',
      'Mixture',
      'Vaccine',
      'Other',
    ],
    InventoryKind.semen => const [
      'Frozen semen',
      'Sexed semen',
      'Conventional semen',
      'Other',
    ],
    InventoryKind.feed => const [
      'Green fodder',
      'Dry fodder',
      'Silage',
      'Concentrate',
      'Minerals',
      'Supplements',
      'Calf starter',
      'Other',
    ],
  };

  @override
  void initState() {
    super.initState();
    _unit = switch (widget.kind) {
      InventoryKind.medicine => 'vial',
      InventoryKind.semen => 'straw',
      InventoryKind.feed => 'kg',
    };
  }

  @override
  void dispose() {
    for (final controller in [
      _code,
      _name,
      _brand,
      _barcode,
      _batch,
      _supplier,
      _purchase,
      _expiry,
      _quantity,
      _cost,
      _minimum,
      _maximum,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      child: ResponsiveContent(
        maxWidth: 1100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              eyebrow: '${widget.kind.label} inventory',
              title: 'Add new ${widget.kind.label.toLowerCase()}',
              subtitle:
                  'Create the item and its first batch. Opening quantity is recorded as a permanent stock movement.',
              actions: [
                OutlinedButton.icon(
                  onPressed: () =>
                      context.go('/inventory/${widget.kind.apiValue}'),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            GlassSurface(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Item details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _fields([
                      _field(
                        _name,
                        '${widget.kind.label} name',
                        required: true,
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: [
                          for (final value in _categories)
                            DropdownMenuItem(value: value, child: Text(value)),
                        ],
                        onChanged: (value) => setState(() => _category = value),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      _field(_brand, 'Brand / company'),
                      _field(_code, 'Item code (optional)'),
                      _field(_barcode, 'Barcode (optional)'),
                      DropdownButtonFormField<String>(
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
                        onChanged: (value) =>
                            setState(() => _unit = value ?? _unit),
                      ),
                      _field(
                        _minimum,
                        'Minimum stock',
                        required: true,
                        number: true,
                      ),
                      _field(
                        _maximum,
                        'Maximum stock',
                        number: true,
                        validator: (value) =>
                            validateMaximumStock(value, _minimum.text),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    Text(
                      'Opening batch',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _fields([
                      _field(_batch, 'Batch number', required: true),
                      _field(_supplier, 'Supplier'),
                      InventoryDateField(
                        controller: _purchase,
                        label: 'Purchase date',
                        validator: validateInventoryDate,
                      ),
                      InventoryDateField(
                        controller: _expiry,
                        label: 'Expiry date',
                        validator: (value) =>
                            validateInventoryExpiry(value, _purchase.text),
                      ),
                      _field(
                        _quantity,
                        'Opening stock',
                        required: true,
                        number: true,
                        positive: true,
                      ),
                      _field(
                        _cost,
                        'Rate per item',
                        required: true,
                        number: true,
                        decimalPlaces: 4,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notes,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        key: const Key('save_inventory_item'),
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text('Save ${widget.kind.label.toLowerCase()}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _fields(List<Widget> children) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth >= 760
          ? (constraints.maxWidth - 14) / 2
          : constraints.maxWidth;
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool number = false,
    bool positive = false,
    int decimalPlaces = 3,
    FormFieldValidator<String>? validator,
  }) => TextFormField(
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
  );

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final farmId = ref.read(authControllerProvider).asData?.value?.activeFarmId;
    if (farmId == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(inventoryRepositoryProvider).createItem(widget.kind, {
        'farm_id': farmId,
        'item_code': _nullable(_code.text),
        'barcode': _nullable(_barcode.text),
        'name': _name.text.trim(),
        'category': _category,
        'brand': _nullable(_brand.text),
        'unit': _unit,
        'minimum_stock': _minimum.text.trim(),
        'maximum_stock': _nullable(_maximum.text),
        'notes': _nullable(_notes.text),
        'batch_number': _batch.text.trim(),
        'supplier': _nullable(_supplier.text),
        'purchase_date': _nullable(_purchase.text),
        'expiry_date': _nullable(_expiry.text),
        'opening_quantity': _quantity.text.trim(),
        'unit_cost': _cost.text.trim(),
      });
      ref.invalidate(inventoryDashboardProvider);
      ref.invalidate(inventoryOverviewProvider);
      if (mounted) {
        context.go('/inventory/${widget.kind.apiValue}');
      }
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

String? _nullable(String value) => value.trim().isEmpty ? null : value.trim();

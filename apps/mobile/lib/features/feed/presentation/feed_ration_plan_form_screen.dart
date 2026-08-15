import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/feed/application/feed_providers.dart';
import 'package:dairycare_mobile/features/feed/data/feed_repository.dart';
import 'package:dairycare_mobile/features/inventory/application/inventory_providers.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class _IngredientState {
  _IngredientState({String quantity = ''})
    : quantityController = TextEditingController(text: quantity);

  String? inventoryItemId;
  final TextEditingController quantityController;

  void dispose() {
    quantityController.dispose();
  }
}

final class FeedRationPlanFormScreen extends ConsumerStatefulWidget {
  const FeedRationPlanFormScreen({super.key});

  @override
  ConsumerState<FeedRationPlanFormScreen> createState() =>
      _FeedRationPlanFormScreenState();
}

class _FeedRationPlanFormScreenState
    extends ConsumerState<FeedRationPlanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  String? _animalGroupId;
  String? _productionStage;
  DateTime _effectiveDate = DateTime.now();
  DateTime? _endDate;
  final _frequency = TextEditingController(text: '1');

  final _ingredients = <_IngredientState>[_IngredientState()];

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _frequency.dispose();
    for (final i in _ingredients) {
      i.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Check ingredients
    if (_ingredients.isEmpty) {
      setState(() => _error = 'Please add at least one ingredient.');
      return;
    }

    final validIngredients = _ingredients
        .where((i) => i.inventoryItemId != null)
        .toList();
    if (validIngredients.isEmpty) {
      setState(
        () => _error = 'Please select an inventory item for ingredients.',
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final payload = {
      'name': _name.text,
      'animal_group_id': _animalGroupId,
      'production_stage': _productionStage,
      'effective_date': DateFormat('yyyy-MM-dd').format(_effectiveDate),
      'end_date': _endDate != null
          ? DateFormat('yyyy-MM-dd').format(_endDate!)
          : null,
      'feeding_frequency': int.tryParse(_frequency.text) ?? 1,
      'ingredients': validIngredients
          .map(
            (i) => {
              'inventory_item_id': i.inventoryItemId,
              'quantity_per_animal':
                  double.tryParse(i.quantityController.text) ?? 0,
              // The backend requires a unit. We can default to 'kg' for now, but ideally
              // we'd grab it from the inventory item.
              'unit': 'kg',
            },
          )
          .toList(),
    };

    try {
      final repo = FeedRepository(api: ref.read(apiClientProvider));
      await repo.createRationPlan(payload);
      ref.invalidate(feedRationPlansProvider);
      if (mounted) context.pop();
    } on AppException catch (e) {
      setState(() {
        if (e.fieldErrors.isNotEmpty) {
          _error = [
            e.message,
            ...e.fieldErrors.values.expand((v) => v),
          ].join('\n');
        } else {
          _error = e.message;
        }
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final organizationId = ref
        .watch(authControllerProvider)
        .asData
        ?.value
        ?.activeOrganizationId;

    final animalRefs = organizationId != null
        ? ref.watch(animalReferencesProvider(organizationId)).asData?.value
        : null;

    final feedItemsAsync = ref.watch(
      inventoryOverviewProvider((
        kind: InventoryKind.feed,
        search: '',
        category: null,
        supplier: null,
        lowStock: false,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Ration Plan'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ResponsiveContent(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  <Widget>[
                      const PageHeader(
                        eyebrow: 'Ration Plan',
                        title: 'Create plan',
                        subtitle:
                            'Define a new feeding regime for your animals.',
                      ),
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Plan Name *',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                        maxLength: 180,
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _animalGroupId,
                        decoration: const InputDecoration(
                          labelText: 'Animal Group',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All groups'),
                          ),
                          ...?animalRefs?.groups.map(
                            (g) => DropdownMenuItem(
                              value: g.id,
                              child: Text(g.name),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _animalGroupId = v),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _productionStage,
                        decoration: const InputDecoration(
                          labelText: 'Production Stage',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Any stage'),
                          ),
                          DropdownMenuItem(value: 'calf', child: Text('Calf')),
                          DropdownMenuItem(
                            value: 'heifer',
                            child: Text('Heifer'),
                          ),
                          DropdownMenuItem(
                            value: 'lactating',
                            child: Text('Lactating'),
                          ),
                          DropdownMenuItem(value: 'dry', child: Text('Dry')),
                          DropdownMenuItem(
                            value: 'pregnant',
                            child: Text('Pregnant'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _productionStage = v),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Effective Date *',
                              ),
                              child: Text(
                                DateFormat.yMMMd().format(_effectiveDate),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _effectiveDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => _effectiveDate = date);
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                              ),
                              child: Text(
                                _endDate != null
                                    ? DateFormat.yMMMd().format(_endDate!)
                                    : 'No end date',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? _effectiveDate,
                                firstDate: _effectiveDate,
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => _endDate = date);
                              }
                            },
                          ),
                          if (_endDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _endDate = null),
                            ),
                        ],
                      ),
                      TextFormField(
                        controller: _frequency,
                        decoration: const InputDecoration(
                          labelText: 'Feeding Frequency (times per day) *',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final num = int.tryParse(v);
                          if (num == null || num < 1 || num > 24) {
                            return 'Must be between 1 and 24';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                        child: Text(
                          'Ingredients',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      feedItemsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) =>
                            Text('Error loading feed items: $err'),
                        data: (overview) {
                          final feedItems = overview.items;
                          return Column(
                            children: [
                              for (int i = 0; i < _ingredients.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<String>(
                                          initialValue:
                                              _ingredients[i].inventoryItemId,
                                          decoration: const InputDecoration(
                                            labelText: 'Feed Item *',
                                          ),
                                          isExpanded: true,
                                          items: feedItems.map((item) {
                                            return DropdownMenuItem(
                                              value: item.id,
                                              child: Text(
                                                '${item.name} (${item.unit})',
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (v) => setState(
                                            () =>
                                                _ingredients[i]
                                                        .inventoryItemId =
                                                    v,
                                          ),
                                          validator: (v) =>
                                              v == null ? 'Required' : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          controller: _ingredients[i]
                                              .quantityController,
                                          decoration: const InputDecoration(
                                            labelText: 'Qty/Animal *',
                                          ),
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Required';
                                            }
                                            if (double.tryParse(v) == null) {
                                              return 'Invalid';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        color: Colors.red,
                                        onPressed: () {
                                          setState(() {
                                            _ingredients[i].dispose();
                                            _ingredients.removeAt(i);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              TextButton.icon(
                                onPressed: () => setState(
                                  () => _ingredients.add(_IngredientState()),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Ingredient'),
                              ),
                            ],
                          );
                        },
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: const Text('Save Plan'),
                      ),
                    ].expand((w) => [w, const SizedBox(height: 16)]).toList()
                    ..removeLast(),
            ),
          ),
        ),
      ),
    );
  }
}

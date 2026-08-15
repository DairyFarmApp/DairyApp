import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/formatting/pkr.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_sales_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CattleSaleFormScreen extends ConsumerStatefulWidget {
  const CattleSaleFormScreen({super.key});

  @override
  ConsumerState<CattleSaleFormScreen> createState() =>
      _CattleSaleFormScreenState();
}

class _CattleSaleFormScreenState extends ConsumerState<CattleSaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _saleDateController = TextEditingController();
  final _buyerController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _commissionController = TextEditingController();
  final _transportationCostController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _saleDate;
  String? _animalId;
  bool _saving = false;

  @override
  void dispose() {
    _saleDateController.dispose();
    _buyerController.dispose();
    _salePriceController.dispose();
    _commissionController.dispose();
    _transportationCostController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saleDate == null || _animalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an animal and sale date.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final data = {
        'sale_date': DateFormat('yyyy-MM-dd').format(_saleDate!),
        'animal_id': _animalId,
        'buyer': _buyerController.text.trim(),
        'sale_price': double.tryParse(_salePriceController.text) ?? 0,
        'commission': double.tryParse(_commissionController.text) ?? 0,
        'transportation_cost':
            double.tryParse(_transportationCostController.text) ?? 0,
        'reason': _reasonController.text.trim(),
        'notes': _notesController.text.trim(),
      };

      await ref.read(animalSalesRepositoryProvider).createSale(data);
      ref.invalidate(animalSalesProvider);
      ref.invalidate(animalListControllerProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sale registered successfully. Animal status updated to Sold.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final organizationId = session?.activeOrganizationId;
    if (organizationId == null) {
      return const Scaffold(
        body: EmptyStateView(message: 'Select an organization.'),
      );
    }

    final animalListState = ref.watch(animalListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Cattle Sale')),
      body: animalListState.when(
        loading: () =>
            const LoadingStateView(label: 'Loading in-house animals...'),
        error: (err, stack) => ErrorStateView(
          message: err.toString(),
          onRetry: () => ref.invalidate(animalListControllerProvider),
        ),
        data: (state) {
          final activeAnimals = state.items
              .where(
                (a) =>
                    a.operationalStatus != 'sold' &&
                    a.operationalStatus != 'deceased',
              )
              .toList();
          final selectedAnimal = activeAnimals
              .where((a) => a.id == _animalId)
              .firstOrNull;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sale Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _animalId,
                                  decoration: const InputDecoration(
                                    labelText: 'Select In-House Animal *',
                                    filled: true,
                                  ),
                                  items: activeAnimals
                                      .map(
                                        (a) => DropdownMenuItem(
                                          value: a.id,
                                          child: Text(
                                            '${a.animalNumber} - ${a.name ?? "Unnamed"} (${a.breedName})',
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _animalId = v),
                                  validator: (v) =>
                                      v == null ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _saleDateController,
                                  decoration: const InputDecoration(
                                    labelText: 'Sale Date *',
                                    filled: true,
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _saleDate = date;
                                        _saleDateController.text =
                                            DateFormat.yMMMd().format(date);
                                      });
                                    }
                                  },
                                  validator: (v) =>
                                      v!.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          if (selectedAnimal != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    child: Text(
                                      selectedAnimal
                                              .animalNumber
                                              .characters
                                              .firstOrNull
                                              ?.toUpperCase() ??
                                          'A',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Animal Tag #${selectedAnimal.animalNumber} · ${selectedAnimal.name ?? "In-House Cow"}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Breed: ${selectedAnimal.breedName.isNotEmpty ? selectedAnimal.breedName : "General"} | Sex: ${selectedAnimal.sex.toUpperCase()} | Stage: ${selectedAnimal.lifeStage.toUpperCase()} | Shed: ${selectedAnimal.currentShedName.isNotEmpty ? selectedAnimal.currentShedName : "Assigned"}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _buyerController,
                                  decoration: const InputDecoration(
                                    labelText: 'Buyer Name',
                                    filled: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _reasonController,
                                  decoration: const InputDecoration(
                                    labelText: 'Reason for Sale',
                                    filled: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'Financial Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _salePriceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Sale Price (PKR) *',
                                    filled: true,
                                    prefixText: 'PKR ',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: pkrInputFormatters,
                                  validator: (value) => validatePkrAmount(
                                    value,
                                    allowZero: false,
                                    required: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _commissionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Commission (PKR)',
                                    filled: true,
                                    prefixText: 'PKR ',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: pkrInputFormatters,
                                  validator: validatePkrAmount,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _transportationCostController,
                                  decoration: const InputDecoration(
                                    labelText: 'Transportation Cost (PKR)',
                                    filled: true,
                                    prefixText: 'PKR ',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: pkrInputFormatters,
                                  validator: validatePkrAmount,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              filled: true,
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _saving ? null : () => context.pop(),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 16),
                              FilledButton(
                                onPressed: _saving ? null : _submit,
                                child: _saving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Register Sale'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/application/animal_measurement_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_feed_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class AnimalFeedFormScreen extends ConsumerStatefulWidget {
  const AnimalFeedFormScreen({
    super.key,
    required this.animalId,
  });

  final String animalId;

  @override
  ConsumerState<AnimalFeedFormScreen> createState() =>
      _AnimalFeedFormScreenState();
}

class _AnimalFeedFormScreenState extends ConsumerState<AnimalFeedFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inventoryItemId = TextEditingController(); // A real app would use a dropdown here
  final _quantity = TextEditingController();
  final _notes = TextEditingController();
  String _session = 'morning';
  String _unit = 'kg';
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _dateError;

  @override
  void dispose() {
    _inventoryItemId.dispose();
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final allowed = session?.can('inventory.manage') ?? false;
    final detail = ref.watch(animalDetailProvider(widget.animalId));
    return Scaffold(
      appBar: AppBar(title: const Text('Record Feed')),
      body: !allowed
          ? const EmptyStateView(
              message: 'You do not have permission to record feed.',
            )
          : detail.when(
              loading: () => const LoadingStateView(label: 'Loading animal...'),
              error: (error, _) => ErrorStateView(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(animalDetailProvider(widget.animalId)),
              ),
              data: _form,
            ),
    );
  }

  Widget _form(Animal animal) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${animal.animalNumber}${animal.name == null ? '' : ' - ${animal.name}'}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  // Using text field for UUID for simplicity. Real app uses proper selector.
                  TextFormField(
                    controller: _inventoryItemId,
                    decoration: const InputDecoration(
                      labelText: 'Inventory Item ID (UUID)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _session,
                    decoration: const InputDecoration(
                      labelText: 'Session',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'morning', child: Text('Morning')),
                      DropdownMenuItem(value: 'afternoon', child: Text('Afternoon')),
                      DropdownMenuItem(value: 'evening', child: Text('Evening')),
                      DropdownMenuItem(value: 'night', child: Text('Night')),
                    ],
                    onChanged: (value) => setState(() => _session = value ?? 'morning'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _quantity,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateQuantity,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'kg', child: Text('Kilograms')),
                      DropdownMenuItem(value: 'lb', child: Text('Pounds')),
                      DropdownMenuItem(value: 'tonnes', child: Text('Tonnes')),
                    ],
                    onChanged: (value) => setState(() => _unit = value ?? 'kg'),
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: const OutlineInputBorder(),
                      errorText: _dateError,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(DateFormat.yMMMd().format(_date)),
                        ),
                        IconButton(
                          tooltip: 'Choose date',
                          onPressed: _pickDate,
                          icon: const Icon(Icons.event_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notes,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _saving ? null : () => _submit(animal),
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Record feed'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateQuantity(String? value) {
    final trimmed = value?.trim() ?? '';
    final parsed = double.tryParse(trimmed);
    return parsed == null || parsed <= 0
        ? 'Quantity must be greater than zero.'
        : null;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    setState(() {
      _date = date;
      _dateError = null;
    });
  }

  Future<void> _submit(Animal animal) async {
    final timeValid = !_date.isAfter(DateTime.now().add(const Duration(days: 1)));
    setState(() {
      _dateError = timeValid ? null : 'Date cannot be in the future.';
    });
    if (!(_formKey.currentState?.validate() ?? false) || !timeValid) return;
    setState(() => _saving = true);
    try {
      final repository = ref.read(animalFeedRepositoryProvider);
      await repository.recordFeedConsumption(
        animalId: animal.id,
        inventoryItemId: _inventoryItemId.text.trim(),
        date: _date,
        session: _session,
        quantity: double.parse(_quantity.text.trim()),
        unit: _unit,
        notes: _notes.text,
      );
      ref.invalidate(animalFeedHistoryProvider(animal.id));
      if (mounted) context.pop();
    } on AppException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

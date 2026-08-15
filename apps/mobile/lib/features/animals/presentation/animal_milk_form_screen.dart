import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/application/animal_measurement_providers.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/milk/application/milk_providers.dart';
import 'package:dairycare_mobile/features/milk/domain/milk_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class AnimalMilkFormScreen extends ConsumerStatefulWidget {
  const AnimalMilkFormScreen({
    super.key,
    required this.animalId,
  });

  final String animalId;

  @override
  ConsumerState<AnimalMilkFormScreen> createState() =>
      _AnimalMilkFormScreenState();
}

class _AnimalMilkFormScreenState extends ConsumerState<AnimalMilkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _rejectedQuantity = TextEditingController();
  final _rejectionReason = TextEditingController();
  final _notes = TextEditingController();
  MilkingSession _session = MilkingSession.morning;
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _dateError;

  @override
  void dispose() {
    _quantity.dispose();
    _rejectedQuantity.dispose();
    _rejectionReason.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final allowed = session?.can('milk.create') ?? false;
    final detail = ref.watch(animalDetailProvider(widget.animalId));
    return Scaffold(
      appBar: AppBar(title: const Text('Record Milk')),
      body: !allowed
          ? const EmptyStateView(
              message: 'You do not have permission to record milk.',
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
                  DropdownButtonFormField<MilkingSession>(
                    initialValue: _session,
                    decoration: const InputDecoration(
                      labelText: 'Session',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final value in MilkingSession.values)
                        DropdownMenuItem(value: value, child: Text(value.label)),
                    ],
                    onChanged: (value) => setState(
                      () => _session = value ?? MilkingSession.morning,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _quantity,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Quantity (Litres)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateQuantity,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _rejectedQuantity,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Rejected Quantity (Litres)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateRejectedQuantity,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _rejectionReason,
                    decoration: const InputDecoration(
                      labelText: 'Rejection Reason (optional)',
                      border: OutlineInputBorder(),
                    ),
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
                    label: const Text('Record milk'),
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

  String? _validateRejectedQuantity(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return 'Quantity must be zero or greater.';
    }
    final total = double.tryParse(_quantity.text.trim());
    if (total != null && parsed > total) {
      return 'Rejected milk cannot exceed total milk.';
    }
    if (parsed > 0 && _rejectionReason.text.trim().isEmpty) {
      return 'Enter a reason for rejected milk.';
    }
    return null;
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
    final today = DateTime.now();
    final selected = DateTime(_date.year, _date.month, _date.day);
    final currentDay = DateTime(today.year, today.month, today.day);
    final timeValid = !selected.isAfter(currentDay);
    setState(() {
      _dateError = timeValid ? null : 'Date cannot be in the future.';
    });
    if (!(_formKey.currentState?.validate() ?? false) || !timeValid) return;
    setState(() => _saving = true);
    try {
      final session = ref.read(authControllerProvider).asData?.value;
      final organizationId = session?.activeOrganizationId;
      final farmId = session?.activeFarmId;
      final shedId = animal.currentShedId;
      if (organizationId == null || farmId == null) {
        throw const ValidationException(
          'Select the animal\'s farm before recording milk.',
          code: 'MILK_CONTEXT_REQUIRED',
        );
      }
      final result = await ref.read(milkRepositoryProvider).saveBulk(
        organizationId: organizationId,
        farmId: farmId,
        productionDate: _date,
        session: _session,
        drafts: [
          MilkEntryDraft(
            animal: MilkEligibleAnimal(
              id: animal.id,
              animalNumber: animal.animalNumber,
              name: animal.name,
              shedId: shedId,
            ),
            quantityLitres: double.parse(_quantity.text.trim()).toStringAsFixed(3),
            rejectedQuantityLitres: _rejectedQuantity.text.trim().isEmpty
                ? '0.000'
                : double.parse(_rejectedQuantity.text.trim()).toStringAsFixed(3),
            rejectionReason: _rejectionReason.text.trim().isEmpty
                ? null
                : _rejectionReason.text.trim(),
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          ),
        ],
      );
      ref.invalidate(animalMilkHistoryProvider(animal.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.queuedOffline
                  ? 'Milk entry saved offline and queued for synchronization.'
                  : 'Milk entry recorded.',
            ),
          ),
        );
        context.pop();
      }
    } on AppException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_measurement_providers.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_weight_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class AnimalWeightFormScreen extends ConsumerStatefulWidget {
  const AnimalWeightFormScreen({
    super.key,
    required this.animalId,
    this.weightId,
  });

  final String animalId;
  final String? weightId;

  bool get isCorrection => weightId != null;

  @override
  ConsumerState<AnimalWeightFormScreen> createState() =>
      _AnimalWeightFormScreenState();
}

class _AnimalWeightFormScreenState
    extends ConsumerState<AnimalWeightFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _value = TextEditingController();
  final _notes = TextEditingController();
  final _correctionReason = TextEditingController();
  String _unit = 'kg';
  String _source = 'scale';
  DateTime _observedAt = DateTime.now();
  bool _initialized = false;
  bool _saving = false;
  String? _timeError;

  @override
  void dispose() {
    _value.dispose();
    _notes.dispose();
    _correctionReason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final allowed = widget.isCorrection
        ? session?.can('animals.correct_weight') ?? false
        : session?.can('animals.record_weight') ?? false;
    final detail = ref.watch(animalDetailProvider(widget.animalId));
    final weight = widget.weightId == null
        ? const AsyncValue<AnimalWeight?>.data(null)
        : ref
              .watch(animalWeightDetailProvider(widget.weightId!))
              .whenData((value) => value);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCorrection ? 'Correct weight' : 'Record weight'),
      ),
      body: !allowed
          ? const EmptyStateView(
              message: 'You do not have permission for this weight action.',
            )
          : detail.when(
              loading: () => const LoadingStateView(label: 'Loading animal...'),
              error: (error, _) => ErrorStateView(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(animalDetailProvider(widget.animalId)),
              ),
              data: (animal) => weight.when(
                loading: () =>
                    const LoadingStateView(label: 'Loading weight record...'),
                error: (error, _) => ErrorStateView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(
                    animalWeightDetailProvider(widget.weightId!),
                  ),
                ),
                data: (original) => _form(animal, original),
              ),
            ),
    );
  }

  Widget _form(Animal animal, AnimalWeight? original) {
    if (!_initialized) {
      _initialized = true;
      if (original != null) {
        _value.text = original.enteredValue;
        _unit = original.enteredUnit;
        _notes.text = original.notes ?? '';
        _observedAt = original.observedAt.toLocal();
      }
    }
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
                  const SizedBox(height: 12),
                  if (original != null)
                    Card(
                      key: const Key('original_weight_summary'),
                      child: ListTile(
                        leading: const Icon(Icons.monitor_weight_outlined),
                        title: Text(
                          '${original.enteredValue} ${original.enteredUnit}',
                        ),
                        subtitle: Text(
                          'Observed ${DateFormat.yMMMd().add_jm().format(original.observedAt.toLocal())}\n'
                          'Normalized ${original.normalizedKg} kg',
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('weight_value_field'),
                    controller: _value,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Weight value',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateWeight,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: const Key('weight_unit_field'),
                    initialValue: _unit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'kg', child: Text('Kilograms')),
                      DropdownMenuItem(value: 'lb', child: Text('Pounds')),
                    ],
                    onChanged: (value) => setState(() => _unit = value ?? 'kg'),
                  ),
                  if (original == null) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: const Key('weight_source_field'),
                      initialValue: _source,
                      decoration: const InputDecoration(
                        labelText: 'Source',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'scale', child: Text('Scale')),
                        DropdownMenuItem(
                          value: 'manual',
                          child: Text('Manual entry'),
                        ),
                        DropdownMenuItem(
                          value: 'estimated',
                          child: Text('Estimated'),
                        ),
                        DropdownMenuItem(
                          value: 'imported',
                          child: Text('Imported'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _source = value ?? 'scale'),
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Observed at',
                        border: const OutlineInputBorder(),
                        errorText: _timeError,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat.yMMMd().add_jm().format(_observedAt),
                            ),
                          ),
                          IconButton(
                            key: const Key('weight_observed_at_field'),
                            tooltip: 'Choose observed time',
                            onPressed: _pickObservedAt,
                            icon: const Icon(Icons.event_outlined),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('weight_notes_field'),
                    controller: _notes,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 5000,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (original != null) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('weight_correction_reason_field'),
                      controller: _correctionReason,
                      minLines: 2,
                      maxLines: 4,
                      maxLength: 2000,
                      decoration: const InputDecoration(
                        labelText: 'Correction reason',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'A correction reason is required.'
                          : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('submit_weight_button'),
                    onPressed: _saving ? null : () => _submit(animal, original),
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      original == null ? 'Record weight' : 'Create correction',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateWeight(String? value) {
    final trimmed = value?.trim() ?? '';
    if (!RegExp(r'^\d{1,12}(?:\.\d{1,6})?$').hasMatch(trimmed)) {
      return 'Enter a positive decimal with at most six decimal places.';
    }
    final parsed = double.tryParse(trimmed);
    return parsed == null || parsed <= 0
        ? 'Weight must be greater than zero.'
        : null;
  }

  Future<void> _pickObservedAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _observedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_observedAt),
    );
    if (time == null) return;
    setState(() {
      _observedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _timeError = null;
    });
  }

  Future<void> _submit(Animal animal, AnimalWeight? original) async {
    final timeValid =
        original != null ||
        !_observedAt.isAfter(DateTime.now().add(const Duration(minutes: 5)));
    setState(() {
      _timeError = timeValid
          ? null
          : 'Observed time cannot be more than five minutes in the future.';
    });
    if (!(_formKey.currentState?.validate() ?? false) || !timeValid) return;
    setState(() => _saving = true);
    try {
      final repository = ref.read(animalMeasurementRepositoryProvider);
      if (original == null) {
        await repository.recordWeight(
          animal.id,
          AnimalWeightDraft(
            farmId: animal.currentFarmId,
            value: _value.text,
            unit: _unit,
            observedAt: _observedAt,
            source: _source,
            notes: _notes.text,
          ),
        );
      } else {
        await repository.correctWeight(
          original,
          AnimalWeightCorrectionDraft(
            value: _value.text,
            unit: _unit,
            correctionReason: _correctionReason.text,
            notes: _notes.text,
          ),
        );
      }
      ref.invalidate(animalWeightHistoryProvider(animal.id));
      ref.invalidate(animalDetailProvider(animal.id));
      ref.invalidate(animalListControllerProvider);
      if (mounted) context.go('/animals/${animal.id}');
    } on AppException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

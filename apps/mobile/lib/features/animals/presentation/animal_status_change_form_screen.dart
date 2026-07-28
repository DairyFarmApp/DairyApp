import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_measurement_providers.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_status_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class AnimalStatusChangeFormScreen extends ConsumerStatefulWidget {
  const AnimalStatusChangeFormScreen({super.key, required this.animalId});

  final String animalId;

  @override
  ConsumerState<AnimalStatusChangeFormScreen> createState() =>
      _AnimalStatusChangeFormScreenState();
}

class _AnimalStatusChangeFormScreenState
    extends ConsumerState<AnimalStatusChangeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  String? _newStatus;
  DateTime _effectiveAt = DateTime.now();
  bool _saving = false;
  String? _timeError;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canChange =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('animals.change_status') ??
        false;
    final detail = ref.watch(animalDetailProvider(widget.animalId));
    return Scaffold(
      appBar: AppBar(title: const Text('Change operational status')),
      body: !canChange
          ? const EmptyStateView(
              message: 'You do not have permission to change animal status.',
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
    final statuses = ['active', 'inactive', 'missing']
        .where((status) => status != animal.operationalStatus)
        .toList(growable: false);
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
                    animal.animalNumber,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      title: const Text('Current operational status'),
                      subtitle: Text(_label(animal.operationalStatus)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: const Key('new_status_field'),
                    initialValue: _newStatus,
                    decoration: const InputDecoration(
                      labelText: 'New status',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final status in statuses)
                        DropdownMenuItem(
                          value: status,
                          child: Text(_label(status)),
                        ),
                    ],
                    validator: (value) =>
                        value == null ? 'Select a new status.' : null,
                    onChanged: (value) => setState(() => _newStatus = value),
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Effective at',
                      border: const OutlineInputBorder(),
                      errorText: _timeError,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat.yMMMd().add_jm().format(_effectiveAt),
                          ),
                        ),
                        IconButton(
                          key: const Key('status_effective_at_field'),
                          tooltip: 'Choose effective time',
                          onPressed: _pickEffectiveAt,
                          icon: const Icon(Icons.event_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('status_reason_field'),
                    controller: _reason,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 2000,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      helperText:
                          'A reason is required for every operational-status transition.',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'A status-change reason is required.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('submit_status_change_button'),
                    onPressed: _saving ? null : () => _submit(animal),
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.change_circle_outlined),
                    label: const Text('Change status'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickEffectiveAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _effectiveAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_effectiveAt),
    );
    if (time == null) return;
    setState(() {
      _effectiveAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _timeError = null;
    });
  }

  Future<void> _submit(Animal animal) async {
    final timeValid = !_effectiveAt.isAfter(DateTime.now());
    setState(() {
      _timeError = timeValid ? null : 'Effective time cannot be in the future.';
    });
    if (!(_formKey.currentState?.validate() ?? false) || !timeValid) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(animalMeasurementRepositoryProvider)
          .changeStatus(
            animal.id,
            AnimalStatusChangeDraft(
              newStatus: _newStatus!,
              effectiveAt: _effectiveAt,
              reason: _reason.text,
              version: animal.version,
            ),
          );
      ref.invalidate(animalStatusHistoryProvider(animal.id));
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

  String _label(String value) => value
      .split('_')
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

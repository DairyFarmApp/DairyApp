import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_movement_providers.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_movement_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class AnimalMovementFormScreen extends ConsumerStatefulWidget {
  const AnimalMovementFormScreen({super.key, required this.animalId});

  final String animalId;

  @override
  ConsumerState<AnimalMovementFormScreen> createState() =>
      _AnimalMovementFormScreenState();
}

class _AnimalMovementFormScreenState
    extends ConsumerState<AnimalMovementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  final _notes = TextEditingController();
  String? _destinationFarmId;
  String? _destinationShedId;
  String? _destinationGroupId;
  DateTime _requestedEffectiveAt = DateTime.now();
  bool _saving = false;
  String? _timeError;

  @override
  void dispose() {
    _reason.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final detail = ref.watch(animalDetailProvider(widget.animalId));
    final organizationId = session?.activeOrganizationId;
    final references = organizationId == null
        ? null
        : ref.watch(animalReferencesProvider(organizationId));
    return Scaffold(
      appBar: AppBar(title: const Text('Request animal movement')),
      body: !(session?.can('animals.move') ?? false)
          ? const Center(
              child: Text('You do not have permission to move animals.'),
            )
          : detail.when(
              loading: () => const LoadingStateView(label: 'Loading animal...'),
              error: (error, _) => ErrorStateView(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(animalDetailProvider(widget.animalId)),
              ),
              data: (animal) => references!.when(
                loading: () =>
                    const LoadingStateView(label: 'Loading destinations...'),
                error: (error, _) => ErrorStateView(
                  message: error.toString(),
                  onRetry: () =>
                      ref.invalidate(animalReferencesProvider(organizationId!)),
                ),
                data: (items) => _form(context, animal, items),
              ),
            ),
    );
  }

  Widget _form(
    BuildContext context,
    Animal animal,
    AnimalReferenceData references,
  ) {
    final farms = references.farms.where((farm) => !farm.isDeleted).toList();
    final sheds = references.sheds
        .where((shed) => !shed.isDeleted && shed.farmId == _destinationFarmId)
        .toList();
    final groups = references.groups
        .where(
          (group) =>
              !group.isArchived &&
              group.isActive &&
              group.farmId == _destinationFarmId,
        )
        .toList();
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    animal.animalNumber,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    key: const Key('movement_source_summary'),
                    child: ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Current source location'),
                      subtitle: Text(
                        '${animal.currentFarmName} / ${animal.currentShedName}'
                        '${animal.currentAnimalGroupName == null ? '' : ' / ${animal.currentAnimalGroupName}'}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: const Key('movement_destination_farm'),
                    initialValue: _destinationFarmId,
                    decoration: const InputDecoration(
                      labelText: 'Destination farm',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final farm in farms)
                        DropdownMenuItem(
                          value: farm.id,
                          child: Text(farm.name),
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      _destinationFarmId = value;
                      _destinationShedId = null;
                      _destinationGroupId = null;
                    }),
                    validator: (value) =>
                        value == null ? 'This field is required.' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: const Key('movement_destination_shed'),
                    initialValue: _destinationShedId,
                    decoration: const InputDecoration(
                      labelText: 'Destination shed',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final shed in sheds)
                        DropdownMenuItem(
                          value: shed.id,
                          child: Text(shed.name),
                        ),
                    ],
                    onChanged: _destinationFarmId == null
                        ? null
                        : (value) => setState(() => _destinationShedId = value),
                    validator: (value) =>
                        value == null ? 'This field is required.' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    key: const Key('movement_destination_group'),
                    initialValue: _destinationGroupId,
                    decoration: const InputDecoration(
                      labelText: 'Destination group (optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No group'),
                      ),
                      for (final group in groups)
                        DropdownMenuItem(
                          value: group.id,
                          child: Text(group.name),
                        ),
                    ],
                    onChanged: _destinationFarmId == null
                        ? null
                        : (value) =>
                              setState(() => _destinationGroupId = value),
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Requested effective time',
                      border: const OutlineInputBorder(),
                      errorText: _timeError,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat.yMMMd().add_jm().format(
                              _requestedEffectiveAt,
                            ),
                          ),
                        ),
                        IconButton(
                          key: const Key('movement_effective_time'),
                          tooltip: 'Choose date and time',
                          onPressed: _pickEffectiveTime,
                          icon: const Icon(Icons.event_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('movement_reason'),
                    controller: _reason,
                    maxLength: 255,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'This field is required.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('movement_notes'),
                    controller: _notes,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 5000,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('submit_movement_button'),
                    onPressed: _saving ? null : () => _submit(animal),
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: const Text('Submit movement'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickEffectiveTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _requestedEffectiveAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_requestedEffectiveAt),
    );
    if (time == null) return;
    setState(() {
      _requestedEffectiveAt = DateTime(
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
    final timeValid = !_requestedEffectiveAt.isAfter(DateTime.now());
    setState(() {
      _timeError = timeValid
          ? null
          : 'The requested time cannot be in the future.';
    });
    if (!(_formKey.currentState?.validate() ?? false) || !timeValid) return;
    if (_destinationFarmId == animal.currentFarmId &&
        _destinationShedId == animal.currentShedId &&
        _destinationGroupId == animal.currentAnimalGroupId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The destination must differ from the source.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final movement = await ref
          .read(animalMovementRepositoryProvider)
          .requestMovement(
            animal.id,
            AnimalMovementDraft(
              sourceFarmId: animal.currentFarmId,
              sourceShedId: animal.currentShedId,
              sourceAnimalGroupId: animal.currentAnimalGroupId,
              destinationFarmId: _destinationFarmId!,
              destinationShedId: _destinationShedId!,
              destinationAnimalGroupId: _destinationGroupId,
              requestedEffectiveAt: _requestedEffectiveAt,
              reason: _reason.text,
              notes: _notes.text,
            ),
          );
      ref.invalidate(animalMovementHistoryProvider(animal.id));
      ref.invalidate(animalDetailProvider(animal.id));
      ref.invalidate(animalListControllerProvider);
      if (mounted) {
        context.go('/animals/${animal.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              movement.status == 'approved'
                  ? 'Animal location updated.'
                  : 'Movement request submitted.',
            ),
          ),
        );
      }
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

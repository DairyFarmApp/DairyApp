import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_movement_history_section.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_registry_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class AnimalDetailScreen extends ConsumerStatefulWidget {
  const AnimalDetailScreen({super.key, required this.animalId});

  final String animalId;

  @override
  ConsumerState<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends ConsumerState<AnimalDetailScreen> {
  bool _mutating = false;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(animalDetailProvider(widget.animalId));
    final session = ref.watch(authControllerProvider).asData?.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal profile'),
        actions: [
          if (detail.asData?.value != null &&
              !detail.requireValue.isArchived &&
              (session?.can('animals.update') ?? false))
            IconButton(
              key: const Key('edit_animal_action'),
              tooltip: AnimalRegistryStrings.editAnimal,
              onPressed: () => context.go('/animals/${widget.animalId}/edit'),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: detail.when(
        loading: () => const LoadingStateView(label: 'Loading animal...'),
        error: (error, _) => ErrorStateView(
          message: error.toString(),
          onRetry: () => ref.invalidate(animalDetailProvider(widget.animalId)),
        ),
        data: (animal) => _content(context, animal),
      ),
      bottomNavigationBar: detail.asData?.value == null
          ? null
          : _actions(context, detail.requireValue),
    );
  }

  Widget _content(BuildContext context, Animal animal) {
    final width = MediaQuery.sizeOf(context).width;
    final fields = <_ProfileField>[
      _ProfileField('Animal number', animal.animalNumber),
      _ProfileField('Name', animal.name),
      _ProfileField('Ear tag', animal.earTagNumber),
      _ProfileField('RFID', animal.rfidNumber),
      _ProfileField('Registration number', animal.registrationNumber),
      _ProfileField('Species', animal.speciesName),
      _ProfileField('Breed', animal.breedName),
      _ProfileField('Sex', _label(animal.sex)),
      _ProfileField('Life stage', _label(animal.lifeStage)),
      _ProfileField(
        'Date of birth',
        animal.dateOfBirth == null
            ? null
            : '${DateFormat.yMMMd().format(animal.dateOfBirth!)}'
                  '${animal.isDateOfBirthEstimated ? ' (estimated)' : ''}',
      ),
      _ProfileField('Colour', animal.colour),
      _ProfileField('Identifying marks', animal.identifyingMarks),
      _ProfileField('Farm', animal.currentFarmName),
      _ProfileField('Shed', animal.currentShedName),
      _ProfileField('Group', animal.currentAnimalGroupName),
      _ProfileField('Mother', animal.motherAnimalNumber),
      _ProfileField('Father', animal.fatherAnimalNumber),
      _ProfileField('External sire', animal.externalSireReference),
      _ProfileField('Origin', _label(animal.origin)),
      _ProfileField(
        'Acquisition date',
        animal.acquisitionDate == null
            ? null
            : DateFormat.yMMMd().format(animal.acquisitionDate!),
      ),
      _ProfileField('Source', animal.sourceDescription),
      _ProfileField('Operational status', _label(animal.operationalStatus)),
      _ProfileField('Notes', animal.notes),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: Icon(
                        animal.isArchived
                            ? Icons.archive_outlined
                            : Icons.check_circle_outline,
                      ),
                      label: Text(
                        animal.isArchived ? 'Archived' : 'Active record',
                      ),
                    ),
                    Chip(
                      avatar: const Icon(Icons.cloud_done_outlined),
                      label: Text(
                        'Cached from server ${DateFormat.yMd().add_jm().format(animal.serverUpdatedAt.toLocal())}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (width >= 760)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final field in fields)
                        SizedBox(
                          width: (width.clamp(760, 960) - 60) / 2,
                          child: _fieldCard(field),
                        ),
                    ],
                  )
                else
                  for (final field in fields) _fieldCard(field),
                AnimalMovementHistorySection(animal: animal),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldCard(_ProfileField field) => Card(
    child: ListTile(
      title: Text(field.label),
      subtitle: Text(
        field.value == null || field.value!.isEmpty ? '-' : field.value!,
      ),
    ),
  );

  Widget? _actions(BuildContext context, Animal animal) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final canArchive =
        !animal.isArchived && (session?.can('animals.archive') ?? false);
    final canRestore =
        animal.isArchived && (session?.can('animals.restore') ?? false);
    if (!canArchive && !canRestore) return null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton.tonalIcon(
          key: Key(
            canRestore ? 'restore_animal_action' : 'archive_animal_action',
          ),
          onPressed: _mutating ? null : () => _confirmMutation(animal),
          icon: Icon(
            canRestore ? Icons.unarchive_outlined : Icons.archive_outlined,
          ),
          label: Text(
            canRestore
                ? AnimalRegistryStrings.restore
                : AnimalRegistryStrings.archive,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmMutation(Animal animal) async {
    final restoring = animal.isArchived;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(restoring ? 'Restore animal?' : 'Archive animal?'),
        content: Text(
          restoring
              ? 'This returns the animal to active registry results.'
              : 'This hides the animal from active registry results without deleting its history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AnimalRegistryStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              restoring
                  ? AnimalRegistryStrings.restore
                  : AnimalRegistryStrings.archive,
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _mutating = true);
    try {
      final repository = ref.read(animalRepositoryProvider);
      final updated = restoring
          ? await repository.restoreAnimal(animal)
          : await repository.archiveAnimal(animal);
      ref.invalidate(animalDetailProvider(widget.animalId));
      ref.invalidate(animalListControllerProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updated.isArchived ? 'Animal archived.' : 'Animal restored.',
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
      if (mounted) setState(() => _mutating = false);
    }
  }

  String _label(String value) => value
      .split('_')
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

final class _ProfileField {
  const _ProfileField(this.label, this.value);

  final String label;
  final String? value;
}

import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_feed_history_section.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_milk_history_section.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_movement_history_section.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_registry_strings.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_status_history_section.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_weight_history_section.dart';
import 'package:dairycare_mobile/features/health/presentation/animal_health_section.dart';
import 'package:dairycare_mobile/features/health/presentation/breeding_section.dart';
import 'package:dairycare_mobile/features/health/presentation/calf_care_section.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal profile'),
        actions: [
          if (detail.asData?.value != null &&
              !detail.requireValue.isArchived &&
              (ref
                      .watch(authControllerProvider)
                      .asData
                      ?.value
                      ?.can('animals.update') ??
                  false))
            IconButton(
              key: const Key('edit_animal_profile_button'),
              tooltip: 'Edit animal profile',
              onPressed: () => context.go('/animals/${widget.animalId}/edit'),
              icon: const Icon(Icons.edit_outlined),
            ),
          if (detail.asData?.value != null && !detail.requireValue.isArchived)
            PopupMenuButton<String>(
              key: const Key('edit_animal_action'),
              onSelected: (value) {
                final animal = detail.requireValue;
                switch (value) {
                  case 'record_weight':
                    context.push('/animals/${animal.id}/record-weight');
                  case 'record_feed':
                    context.push('/animals/${animal.id}/record-feed');
                  case 'record_milk':
                    context.push('/animals/${animal.id}/record-milk');
                  case 'health_assessment':
                    context.push('/animals/${animal.id}/health-assessment');
                  case 'change_status':
                    context.push('/animals/${animal.id}/change-status');
                  case 'edit':
                    context.go('/animals/${widget.animalId}/edit');
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit details')),
                const PopupMenuItem(
                  value: 'record_weight',
                  child: Text('Record weight'),
                ),
                if (detail.requireValue.operationalStatus == 'active' &&
                    detail.requireValue.photoRequirementMet) ...[
                  const PopupMenuItem(
                    value: 'record_milk',
                    child: Text('Record milk'),
                  ),
                  const PopupMenuItem(
                    value: 'record_feed',
                    child: Text('Record feed'),
                  ),
                ],
                const PopupMenuItem(
                  value: 'change_status',
                  child: Text('Change status'),
                ),
                if (detail.requireValue.operationalStatus != 'deceased' &&
                    (ref
                            .watch(authControllerProvider)
                            .asData
                            ?.value
                            ?.can('health.assess') ??
                        false))
                  const PopupMenuItem(
                    value: 'health_assessment',
                    child: Text('Check health symptoms'),
                  ),
              ],
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
      _ProfileField(
        'Latest weight',
        animal.latestWeight == null
            ? null
            : '${animal.latestWeight!.normalizedKg} kg · '
                  '${DateFormat.yMMMd().add_jm().format(animal.latestWeight!.observedAt.toLocal())}',
      ),
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
                    _operationalStatusChip(animal.operationalStatus),
                    Chip(
                      avatar: Icon(
                        animal.photoRequirementMet
                            ? Icons.photo_library_outlined
                            : Icons.warning_amber_rounded,
                      ),
                      label: Text(
                        animal.photoRequirementMet
                            ? '${animal.photoCount} photos'
                            : '${animal.photoCount}/4 photos · restricted',
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
                const SizedBox(height: 16),
                _photoGallery(animal),
                const SizedBox(height: 16),
                if (ref
                        .watch(authControllerProvider)
                        .asData
                        ?.value
                        ?.can('health.view') ??
                    false) ...[
                  AnimalHealthSection(
                    animalId: animal.id,
                    canAssess:
                        animal.operationalStatus != 'deceased' &&
                        (ref
                                .watch(authControllerProvider)
                                .asData
                                ?.value
                                ?.can('health.assess') ??
                            false),
                    canTreat:
                        animal.operationalStatus == 'active' &&
                        (ref
                                .watch(authControllerProvider)
                                .asData
                                ?.value
                                ?.can('health.treat') ??
                            false),
                  ),
                  const SizedBox(height: 16),
                  if (animal.sex == 'female') ...[
                    BreedingSection(
                      animalId: animal.id,
                      canManage:
                          animal.operationalStatus == 'active' &&
                          (ref
                                  .watch(authControllerProvider)
                                  .asData
                                  ?.value
                                  ?.can('breeding.manage') ??
                              false),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
                if (animal.lifeStage == 'calf') ...[
                  CalfCareSection(
                    animalId: animal.id,
                    canManage:
                        animal.operationalStatus == 'active' &&
                        (ref
                                .watch(authControllerProvider)
                                .asData
                                ?.value
                                ?.can('calves.manage') ??
                            false),
                  ),
                  const SizedBox(height: 16),
                ],
                AnimalFeedHistorySection(
                  animalId: animal.id,
                  canRecord:
                      animal.operationalStatus == 'active' &&
                      animal.photoRequirementMet,
                ),
                if (animal.sex.toLowerCase() == 'female') ...[
                  const SizedBox(height: 16),
                  AnimalMilkHistorySection(
                    animalId: animal.id,
                    canRecord:
                        animal.operationalStatus == 'active' &&
                        animal.photoRequirementMet,
                  ),
                ],
                const SizedBox(height: 24),
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
                AnimalWeightHistorySection(animal: animal),
                AnimalStatusHistorySection(animal: animal),
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

  Widget _photoGallery(Animal animal) {
    if (animal.photos.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.add_a_photo_outlined),
          title: const Text('Animal photos required'),
          subtitle: Text(
            animal.photoRequirementMet
                ? 'This existing record has no uploaded photo gallery.'
                : 'Upload at least four photos before milk or feed recording.',
          ),
        ),
      );
    }
    final api = ref.read(apiClientProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: animal.photos.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final photo = animal.photos[index];
              return FutureBuilder(
                future: api.getBytes(photo.url),
                builder: (context, snapshot) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 190,
                    child: snapshot.hasData
                        ? Image.memory(snapshot.requireData, fit: BoxFit.cover)
                        : const ColoredBox(
                            color: Colors.black12,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _operationalStatusChip(String status) {
    final (color, icon) = switch (status) {
      'active' => (Colors.green, Icons.check_circle_outline),
      'missing' => (Colors.red, Icons.warning_amber_outlined),
      _ => (Colors.orange, Icons.pause_circle_outline),
    };
    return Chip(
      key: Key('profile_operational_status_$status'),
      avatar: Icon(icon, color: color, size: 18),
      label: Text(_label(status)),
      side: BorderSide(color: color),
    );
  }

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

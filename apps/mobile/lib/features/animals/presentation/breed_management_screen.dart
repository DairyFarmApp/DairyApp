import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class BreedManagementScreen extends ConsumerWidget {
  const BreedManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final organizationId = session?.activeOrganizationId;
    if (organizationId == null) {
      return const Scaffold(
        body: EmptyStateView(message: 'Select an organization.'),
      );
    }
    final references = ref.watch(animalReferencesProvider(organizationId));
    final canManage = session?.can('animal_breeds.manage') ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeds'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(58),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 2, 24, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose a built-in cattle or buffalo breed, or add a custom breed for your farm.',
              ),
            ),
          ),
        ),
      ),
      body: references.when(
        loading: () => const LoadingStateView(label: 'Loading breeds...'),
        error: (error, _) => ErrorStateView(
          message: error.toString(),
          onRetry: () =>
              ref.invalidate(animalReferencesProvider(organizationId)),
        ),
        data: (data) {
          if (data.breeds.isEmpty) {
            return const EmptyStateView(
              message: 'No breeds are configured for this organization.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            itemCount: data.breeds.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final breed = data.breeds[index];
              final species = data.species
                  .where((item) => item.id == breed.speciesId)
                  .firstOrNull;
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      minVerticalPadding: 12,
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.pets_rounded,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            breed.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          _BreedBadge(label: breed.code),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 9),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(species?.name ?? 'Unknown species'),
                            if (!breed.isActive)
                              const _BreedBadge(
                                label: 'Inactive',
                                highlighted: true,
                              ),
                            if (breed.isArchived)
                              const _BreedBadge(
                                label: 'Archived',
                                highlighted: true,
                              ),
                          ],
                        ),
                      ),
                      trailing: canManage && !breed.isArchived
                          ? PopupMenuButton<String>(
                              tooltip: 'Breed actions',
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _edit(context, ref, data, breed);
                                } else {
                                  _archive(context, ref, organizationId, breed);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'archive',
                                  child: Text('Archive'),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: canManage && references.asData != null
          ? FloatingActionButton.extended(
              key: const Key('add_breed_action'),
              onPressed: () => _create(
                context,
                ref,
                organizationId,
                references.requireValue,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add custom breed'),
            )
          : null,
    );
  }

  Future<void> _create(
    BuildContext context,
    WidgetRef ref,
    String organizationId,
    AnimalReferenceData data,
  ) async {
    final input = await _breedDialog(context, data.species);
    if (input == null) return;
    try {
      await ref
          .read(animalRepositoryProvider)
          .createBreed(
            speciesId: input.speciesId,
            code: input.code,
            name: input.name,
            description: input.description,
          );
      ref.invalidate(animalReferencesProvider(organizationId));
    } on AppException catch (error) {
      if (context.mounted) showRegistryError(context, error.message);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    AnimalReferenceData data,
    AnimalBreed breed,
  ) async {
    final input = await _breedDialog(context, data.species, breed: breed);
    if (input == null) return;
    try {
      await ref
          .read(animalRepositoryProvider)
          .updateBreed(
            breed,
            code: input.code,
            name: input.name,
            description: input.description,
            isActive: input.isActive,
          );
      ref.invalidate(animalReferencesProvider(breed.organizationId));
    } on AppException catch (error) {
      if (context.mounted) showRegistryError(context, error.message);
    }
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    String organizationId,
    AnimalBreed breed,
  ) async {
    final confirmed = await confirmRegistryArchive(
      context,
      'Archive breed?',
      'Existing animal profiles will keep this breed reference.',
    );
    if (!confirmed) return;
    try {
      await ref.read(animalRepositoryProvider).archiveBreed(breed);
      ref.invalidate(animalReferencesProvider(organizationId));
    } on AppException catch (error) {
      if (context.mounted) showRegistryError(context, error.message);
    }
  }
}

Future<_BreedInput?> _breedDialog(
  BuildContext context,
  List<AnimalSpecies> species, {
  AnimalBreed? breed,
}) async {
  final formKey = GlobalKey<FormState>();
  var code = breed?.code ?? '';
  var name = breed?.name ?? '';
  var description = breed?.description ?? '';
  var speciesId = breed?.speciesId ?? species.firstOrNull?.id;
  var isActive = breed?.isActive ?? true;
  final result = await showDialog<_BreedInput>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        actionsAlignment: MainAxisAlignment.end,
        title: Text(breed == null ? 'Add custom breed' : 'Edit breed'),
        content: SizedBox(
          width: 520,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    breed == null
                        ? 'Add a breed that is specific to your dairy farm.'
                        : 'Update the breed name, code, description or status.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: speciesId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Species *'),
                    items: [
                      for (final item in species.where((item) => item.isActive))
                        DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                    ],
                    onChanged: breed == null
                        ? (value) => setState(() => speciesId = value)
                        : null,
                    validator: (value) =>
                        value == null ? 'Species is required.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('breed_code_field'),
                    initialValue: code,
                    decoration: const InputDecoration(
                      labelText: 'Code (optional)',
                      helperText: 'Leave blank to create it from the name.',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => code = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('breed_name_field'),
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'Name *'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: requiredRegistryText,
                    onChanged: (value) => name = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    minLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) => description = value,
                  ),
                  if (breed != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: const Text('Active breed'),
                          subtitle: const Text(
                            'Inactive breeds cannot be selected for new animals.',
                          ),
                          value: isActive,
                          onChanged: (value) =>
                              setState(() => isActive = value),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('save_breed_button'),
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false) ||
                  speciesId == null) {
                return;
              }
              Navigator.pop(
                context,
                _BreedInput(
                  speciesId: speciesId!,
                  code: code.trim().isEmpty
                      ? _breedCode(name)
                      : code.trim().toUpperCase(),
                  name: name.trim(),
                  description: optionalRegistryText(description),
                  isActive: isActive,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  return result;
}

final class _BreedBadge extends StatelessWidget {
  const _BreedBadge({required this.label, this.highlighted = false});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: highlighted
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: highlighted
            ? Theme.of(context).colorScheme.onErrorContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

String _breedCode(String name) {
  final generated = name
      .trim()
      .toUpperCase()
      .replaceAll(RegExp('[^A-Z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  if (generated.isEmpty) return 'CUSTOM-BREED';
  return generated.length <= 40 ? generated : generated.substring(0, 40);
}

final class _BreedInput {
  const _BreedInput({
    required this.speciesId,
    required this.code,
    required this.name,
    required this.isActive,
    this.description,
  });

  final String speciesId;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
}

String? requiredRegistryText(String? value) =>
    value == null || value.trim().isEmpty ? 'This field is required.' : null;

String? optionalRegistryText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

void showRegistryError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirmRegistryArchive(
  BuildContext context,
  String title,
  String message,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    ) ??
    false;

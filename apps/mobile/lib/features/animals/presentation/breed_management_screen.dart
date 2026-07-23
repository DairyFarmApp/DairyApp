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
      appBar: AppBar(title: const Text('Breeds')),
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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.breeds.length,
            itemBuilder: (context, index) {
              final breed = data.breeds[index];
              final species = data.species
                  .where((item) => item.id == breed.speciesId)
                  .firstOrNull;
              return Card(
                child: ListTile(
                  title: Text('${breed.code} - ${breed.name}'),
                  subtitle: Text(
                    [
                      species?.name ?? 'Unknown species',
                      if (!breed.isActive) 'Inactive',
                      if (breed.isArchived) 'Archived',
                    ].join(' - '),
                  ),
                  trailing: canManage && !breed.isArchived
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _edit(context, ref, data, breed);
                            } else {
                              _archive(context, ref, organizationId, breed);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'archive',
                              child: Text('Archive'),
                            ),
                          ],
                        )
                      : null,
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
              label: const Text('Add breed'),
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
  final code = TextEditingController(text: breed?.code);
  final name = TextEditingController(text: breed?.name);
  final description = TextEditingController(text: breed?.description);
  var speciesId = breed?.speciesId ?? species.firstOrNull?.id;
  var isActive = breed?.isActive ?? true;
  final result = await showDialog<_BreedInput>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(breed == null ? 'Add breed' : 'Edit breed'),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: speciesId,
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
                  TextFormField(
                    key: const Key('breed_code_field'),
                    controller: code,
                    decoration: const InputDecoration(labelText: 'Code *'),
                    textCapitalization: TextCapitalization.characters,
                    validator: requiredRegistryText,
                  ),
                  TextFormField(
                    key: const Key('breed_name_field'),
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Name *'),
                    validator: requiredRegistryText,
                  ),
                  TextFormField(
                    controller: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  if (breed != null)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
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
                  code: code.text.trim(),
                  name: name.text.trim(),
                  description: optionalRegistryText(description.text),
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
  code.dispose();
  name.dispose();
  description.dispose();
  return result;
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

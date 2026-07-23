import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/presentation/breed_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AnimalGroupManagementScreen extends ConsumerWidget {
  const AnimalGroupManagementScreen({super.key});

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
    final canManage = session?.can('animal_groups.manage') ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Animal groups')),
      body: references.when(
        loading: () => const LoadingStateView(label: 'Loading groups...'),
        error: (error, _) => ErrorStateView(
          message: error.toString(),
          onRetry: () =>
              ref.invalidate(animalReferencesProvider(organizationId)),
        ),
        data: (data) {
          if (data.groups.isEmpty) {
            return const EmptyStateView(
              message: 'No animal groups are configured.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.groups.length,
            itemBuilder: (context, index) {
              final group = data.groups[index];
              final farm = data.farms
                  .where((item) => item.id == group.farmId)
                  .firstOrNull;
              final defaultShed = data.sheds
                  .where((item) => item.id == group.defaultShedId)
                  .firstOrNull;
              return Card(
                child: ListTile(
                  title: Text('${group.code} - ${group.name}'),
                  subtitle: Text(
                    [
                      farm?.name ?? 'Unknown farm',
                      if (defaultShed != null) 'Default: ${defaultShed.name}',
                      if (!group.isActive) 'Inactive',
                      if (group.isArchived) 'Archived',
                    ].join(' - '),
                  ),
                  trailing: canManage && !group.isArchived
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _edit(context, ref, data, group);
                            } else {
                              _archive(context, ref, organizationId, group);
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
              key: const Key('add_group_action'),
              onPressed: () => _create(
                context,
                ref,
                organizationId,
                references.requireValue,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add group'),
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
    final input = await _groupDialog(context, data);
    if (input == null) return;
    try {
      await ref
          .read(animalRepositoryProvider)
          .createGroup(
            farmId: input.farmId,
            defaultShedId: input.defaultShedId,
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
    AnimalGroup group,
  ) async {
    final input = await _groupDialog(context, data, group: group);
    if (input == null) return;
    try {
      await ref
          .read(animalRepositoryProvider)
          .updateGroup(
            group,
            defaultShedId: input.defaultShedId,
            code: input.code,
            name: input.name,
            description: input.description,
            isActive: input.isActive,
          );
      ref.invalidate(animalReferencesProvider(group.organizationId));
    } on AppException catch (error) {
      if (context.mounted) showRegistryError(context, error.message);
    }
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    String organizationId,
    AnimalGroup group,
  ) async {
    final confirmed = await confirmRegistryArchive(
      context,
      'Archive animal group?',
      'Animals in this group will remain active and keep their historical reference.',
    );
    if (!confirmed) return;
    try {
      await ref.read(animalRepositoryProvider).archiveGroup(group);
      ref.invalidate(animalReferencesProvider(organizationId));
    } on AppException catch (error) {
      if (context.mounted) showRegistryError(context, error.message);
    }
  }
}

Future<_GroupInput?> _groupDialog(
  BuildContext context,
  AnimalReferenceData data, {
  AnimalGroup? group,
}) async {
  final formKey = GlobalKey<FormState>();
  final code = TextEditingController(text: group?.code);
  final name = TextEditingController(text: group?.name);
  final description = TextEditingController(text: group?.description);
  var farmId = group?.farmId ?? data.farms.firstOrNull?.id;
  var defaultShedId = group?.defaultShedId;
  var isActive = group?.isActive ?? true;
  final result = await showDialog<_GroupInput>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final sheds = data.sheds
            .where((item) => item.farmId == farmId && !item.isDeleted)
            .toList();
        return AlertDialog(
          title: Text(group == null ? 'Add animal group' : 'Edit animal group'),
          content: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: farmId,
                      decoration: const InputDecoration(labelText: 'Farm *'),
                      items: [
                        for (final LocalFarm item in data.farms)
                          DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                      ],
                      onChanged: group == null
                          ? (value) => setState(() {
                              farmId = value;
                              defaultShedId = null;
                            })
                          : null,
                      validator: (value) =>
                          value == null ? 'Farm is required.' : null,
                    ),
                    DropdownButtonFormField<String>(
                      key: ValueKey('default-shed-$farmId-$defaultShedId'),
                      initialValue:
                          sheds.any((item) => item.id == defaultShedId)
                          ? defaultShedId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Default shed',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No default shed'),
                        ),
                        for (final LocalShed item in sheds)
                          DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => defaultShedId = value),
                    ),
                    TextFormField(
                      key: const Key('group_code_field'),
                      controller: code,
                      decoration: const InputDecoration(labelText: 'Code *'),
                      textCapitalization: TextCapitalization.characters,
                      validator: requiredRegistryText,
                    ),
                    TextFormField(
                      key: const Key('group_name_field'),
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Name *'),
                      validator: requiredRegistryText,
                    ),
                    TextFormField(
                      controller: description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                    if (group != null)
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
              key: const Key('save_group_button'),
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false) ||
                    farmId == null) {
                  return;
                }
                Navigator.pop(
                  context,
                  _GroupInput(
                    farmId: farmId!,
                    defaultShedId: defaultShedId,
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
        );
      },
    ),
  );
  code.dispose();
  name.dispose();
  description.dispose();
  return result;
}

final class _GroupInput {
  const _GroupInput({
    required this.farmId,
    required this.code,
    required this.name,
    required this.isActive,
    this.defaultShedId,
    this.description,
  });

  final String farmId;
  final String? defaultShedId;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
}

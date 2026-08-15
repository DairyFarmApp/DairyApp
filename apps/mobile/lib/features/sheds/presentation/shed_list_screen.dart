import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/farms/application/foundation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ShedListScreen extends ConsumerWidget {
  const ShedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final organizationId = session?.activeOrganizationId;
    final farmId = session?.activeFarmId;
    if (organizationId == null || farmId == null) {
      return const Scaffold(
        body: EmptyStateView(message: 'Sign in to your farm account first.'),
      );
    }
    final query = (organizationId: organizationId, farmId: farmId);
    final sheds = ref.watch(shedListProvider(query));
    final canCreate = session?.can('sheds.create') ?? false;
    final canUpdate = session?.can('sheds.update') ?? false;
    final canArchive = session?.can('sheds.archive') ?? false;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(shedListProvider(query).future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContent(
            maxWidth: 980,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  eyebrow: session?.activeFarm?.name ?? 'Current farm',
                  title: 'Sheds',
                  subtitle:
                      'Sheds are physical animal locations inside your farm. Every active animal is assigned to one current shed.',
                  actions: [
                    if (canCreate)
                      FilledButton.icon(
                        key: const Key('add_shed_action'),
                        onPressed: () => _create(context, ref, query),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add shed'),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                sheds.when(
                  loading: () =>
                      const LoadingStateView(label: 'Loading sheds...'),
                  error: (error, _) => ErrorStateView(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(shedListProvider(query)),
                  ),
                  data: (items) => items.isEmpty
                      ? EmptyStateView(
                          title: 'Create your first shed',
                          message:
                              'Examples include Main Cow Shed, Buffalo Shed, Calf Shed, or Isolation Shed.',
                          icon: Icons.warehouse_outlined,
                          action: canCreate
                              ? FilledButton.icon(
                                  onPressed: () => _create(context, ref, query),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Add first shed'),
                                )
                              : null,
                        )
                      : _ShedList(
                          items: items,
                          canUpdate: canUpdate,
                          canArchive: canArchive,
                          onEdit: (shed) => _edit(context, ref, query, shed),
                          onArchive: (shed) =>
                              _archive(context, ref, query, shed),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _create(
    BuildContext context,
    WidgetRef ref,
    FarmProfileQuery query,
  ) async {
    final details = await _shedDialog(context, title: 'Add shed');
    if (details == null) return;
    try {
      final result = await ref
          .read(foundationRepositoryProvider)
          .createShed(
            organizationId: query.organizationId,
            farmId: query.farmId,
            name: details.name,
            location: details.location,
          );
      ref.invalidate(shedListProvider(query));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.queuedOffline
                  ? '${details.name} added and waiting to synchronize.'
                  : '${details.name} added to your farm.',
            ),
          ),
        );
      }
    } on AppException catch (error) {
      if (context.mounted) _showError(context, error.message);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    FarmProfileQuery query,
    LocalShed shed,
  ) async {
    final details = await _shedDialog(
      context,
      title: 'Edit shed',
      initialName: shed.name,
      initialLocation: shed.location,
    );
    if (details == null ||
        (details.name == shed.name && details.location == shed.location)) {
      return;
    }
    try {
      await ref
          .read(foundationRepositoryProvider)
          .updateShed(
            shed: shed,
            name: details.name,
            location: details.location,
          );
      ref.invalidate(shedListProvider(query));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Shed updated.')));
      }
    } on AppException catch (error) {
      if (context.mounted) _showError(context, error.message);
    }
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    FarmProfileQuery query,
    LocalShed shed,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete shed?'),
        content: Text(
          '${shed.name} will be archived and removed from active shed lists. Historical records will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_delete_shed'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete shed'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(foundationRepositoryProvider).archiveShed(shed);
      ref.invalidate(shedListProvider(query));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${shed.name} deleted.')));
      }
    } on AppException catch (error) {
      if (context.mounted) _showError(context, error.message);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

final class _ShedList extends StatelessWidget {
  const _ShedList({
    required this.items,
    required this.canUpdate,
    required this.canArchive,
    required this.onEdit,
    required this.onArchive,
  });

  final List<LocalShed> items;
  final bool canUpdate;
  final bool canArchive;
  final ValueChanged<LocalShed> onEdit;
  final ValueChanged<LocalShed> onArchive;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: '${items.length} ${items.length == 1 ? 'shed' : 'sheds'}',
    subtitle: 'All sheds belong to the current farm.',
    child: Column(
      children: [
        for (final shed in items) ...[
          ListTile(
            key: ValueKey('shed-${shed.id}'),
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              child: Icon(
                Icons.warehouse_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(shed.name),
            subtitle: Text(
              shed.location == null || shed.location!.isEmpty
                  ? 'Location not specified'
                  : shed.location!,
            ),
            trailing: canUpdate || canArchive
                ? PopupMenuButton<String>(
                    key: ValueKey('shed-actions-${shed.id}'),
                    onSelected: (value) =>
                        value == 'edit' ? onEdit(shed) : onArchive(shed),
                    itemBuilder: (_) => [
                      if (canUpdate)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit shed'),
                        ),
                      if (canArchive)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete shed'),
                        ),
                    ],
                  )
                : null,
          ),
          if (shed != items.last) const Divider(height: 20),
        ],
      ],
    ),
  );
}

Future<({String name, String? location})?> _shedDialog(
  BuildContext context, {
  required String title,
  String? initialName,
  String? initialLocation,
}) async {
  final formKey = GlobalKey<FormState>();
  var name = initialName ?? '';
  var location = initialLocation ?? '';
  return showDialog<({String name, String? location})>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('shed_name_field'),
                initialValue: initialName,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Shed name *',
                  hintText: 'Example: Main Cow Shed',
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Shed name is required.'
                    : null,
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('shed_location_field'),
                initialValue: initialLocation,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Example: North block, beside milking parlour',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLength: 255,
                onChanged: (value) => location = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('save_shed_button'),
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(context, (
              name: name.trim(),
              location: location.trim().isEmpty ? null : location.trim(),
            ));
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

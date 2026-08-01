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
                          onEdit: (shed) => _edit(context, ref, query, shed),
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
    final name = await _shedNameDialog(context, title: 'Add shed');
    if (name == null) return;
    try {
      final result = await ref
          .read(foundationRepositoryProvider)
          .createShed(
            organizationId: query.organizationId,
            farmId: query.farmId,
            name: name,
          );
      ref.invalidate(shedListProvider(query));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.queuedOffline
                  ? '$name added and waiting to synchronize.'
                  : '$name added to your farm.',
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
    final name = await _shedNameDialog(
      context,
      title: 'Rename shed',
      initialValue: shed.name,
    );
    if (name == null || name == shed.name) return;
    try {
      await ref
          .read(foundationRepositoryProvider)
          .updateShed(shed: shed, name: name);
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
    required this.onEdit,
  });

  final List<LocalShed> items;
  final bool canUpdate;
  final ValueChanged<LocalShed> onEdit;

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
            subtitle: const Text('Animal location inside this farm'),
            trailing: canUpdate
                ? IconButton(
                    tooltip: 'Rename shed',
                    onPressed: () => onEdit(shed),
                    icon: const Icon(Icons.edit_outlined),
                  )
                : null,
          ),
          if (shed != items.last) const Divider(height: 20),
        ],
      ],
    ),
  );
}

Future<String?> _shedNameDialog(
  BuildContext context, {
  required String title,
  String? initialValue,
}) async {
  final formKey = GlobalKey<FormState>();
  var name = initialValue ?? '';
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: Form(
          key: formKey,
          child: TextFormField(
            key: const Key('shed_name_field'),
            initialValue: initialValue,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Shed name *',
              hintText: 'Example: Main Cow Shed',
            ),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Shed name is required.' : null,
            onChanged: (value) => name = value,
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
            Navigator.pop(context, name.trim());
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

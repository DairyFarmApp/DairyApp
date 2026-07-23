import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/providers.dart';
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
      return const EmptyStateView(message: 'Select a farm.');
    }
    final stream = ref
        .watch(foundationRepositoryProvider)
        .watchSheds(organizationId, farmId);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sheds', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<LocalShed>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LoadingStateView();
                  final sheds = snapshot.data!;
                  if (sheds.isEmpty) {
                    return const EmptyStateView(
                      message:
                          'No synchronized sheds are cached for this farm.',
                    );
                  }
                  return ListView.builder(
                    itemCount: sheds.length,
                    itemBuilder: (_, index) =>
                        Card(child: ListTile(title: Text(sheds[index].name))),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: session?.can('sheds.create') ?? false
          ? FloatingActionButton.extended(
              onPressed: () => _create(
                context,
                ref,
                organizationId: organizationId,
                farmId: farmId,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add shed'),
            )
          : null,
    );
  }

  Future<void> _create(
    BuildContext context,
    WidgetRef ref, {
    required String organizationId,
    required String farmId,
  }) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New shed'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Shed name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('Save offline'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null) return;
    final database = ref.read(appDatabaseProvider);
    final device = await database
        .select(database.syncDevices)
        .getSingleOrNull();
    if (device == null) return;
    await ref
        .read(foundationRepositoryProvider)
        .createShedOffline(
          organizationId: organizationId,
          farmId: farmId,
          deviceId: device.id,
          name: name,
        );
  }
}

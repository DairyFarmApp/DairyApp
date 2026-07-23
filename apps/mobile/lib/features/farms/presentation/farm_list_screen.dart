import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/farms/application/foundation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class FarmListScreen extends ConsumerWidget {
  const FarmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final organizationId = session?.activeOrganizationId;
    if (organizationId == null) {
      return const EmptyStateView(message: 'Select an organization.');
    }
    final stream = ref
        .watch(foundationRepositoryProvider)
        .watchFarms(organizationId);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Farms', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<LocalFarm>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LoadingStateView();
                  final farms = snapshot.data!;
                  if (farms.isEmpty) {
                    return const EmptyStateView(
                      message:
                          'No synchronized farms are cached on this device.',
                    );
                  }
                  return ListView.builder(
                    itemCount: farms.length,
                    itemBuilder: (_, index) => Card(
                      child: ListTile(
                        title: Text(farms[index].name),
                        subtitle: Text(farms[index].timezone),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: session?.can('farms.create') ?? false
          ? FloatingActionButton.extended(
              onPressed: () => _create(context, ref, organizationId),
              icon: const Icon(Icons.add),
              label: const Text('Add farm'),
            )
          : null,
    );
  }

  Future<void> _create(
    BuildContext context,
    WidgetRef ref,
    String organizationId,
  ) async {
    final name = await _nameDialog(context, 'New farm', 'Farm name');
    if (name == null) return;
    final device = await ref
        .read(appDatabaseProvider)
        .select(ref.read(appDatabaseProvider).syncDevices)
        .getSingleOrNull();
    if (device == null || !context.mounted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Register this device by synchronizing first.'),
          ),
        );
      }
      return;
    }
    await ref
        .read(foundationRepositoryProvider)
        .createFarmOffline(
          organizationId: organizationId,
          deviceId: device.id,
          name: name,
          timezone: 'UTC',
        );
  }
}

Future<String?> _nameDialog(
  BuildContext context,
  String title,
  String label,
) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
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
  return result;
}

import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class FarmSelectionScreen extends ConsumerWidget {
  const FarmSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final session = auth.asData?.value;
    final farms =
        session?.farms
            .where(
              (farm) => farm.organizationId == session.activeOrganizationId,
            )
            .toList(growable: false) ??
        const [];
    return Scaffold(
      appBar: AppBar(title: const Text('Select farm')),
      body: auth.isLoading
          ? const LoadingStateView()
          : farms.isEmpty
          ? const EmptyStateView(
              message:
                  'No accessible farms are available in this organization.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: farms.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final farm = farms[index];
                return Card(
                  child: ListTile(
                    title: Text(farm.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => ref
                        .read(authControllerProvider.notifier)
                        .switchFarm(farm.id),
                  ),
                );
              },
            ),
    );
  }
}

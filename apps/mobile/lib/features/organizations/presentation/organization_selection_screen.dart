import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class OrganizationSelectionScreen extends ConsumerWidget {
  const OrganizationSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final session = auth.asData?.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Select organization')),
      body: auth.isLoading
          ? const LoadingStateView()
          : session == null || session.organizations.isEmpty
          ? EmptyStateView(
              message: auth.hasError
                  ? auth.error.toString()
                  : 'No active organization membership is available.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: session.organizations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final organization = session.organizations[index];
                return Card(
                  child: ListTile(
                    title: Text(organization.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => ref
                        .read(authControllerProvider.notifier)
                        .switchOrganization(organization.id),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const AppMark(size: 48),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Choose organization',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Select the organization you want to manage.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      if (auth.isLoading)
                        const SizedBox(
                          height: 180,
                          child: LoadingStateView(
                            label: 'Loading organizations…',
                          ),
                        )
                      else if (session == null || session.organizations.isEmpty)
                        SizedBox(
                          height: 260,
                          child: EmptyStateView(
                            title: 'No organization available',
                            icon: Icons.business_outlined,
                            message: auth.hasError
                                ? safeErrorMessage(auth.error.toString())
                                : 'Your account has no active organization '
                                      'membership.',
                          ),
                        )
                      else
                        for (final organization in session.organizations) ...[
                          _OrganizationOption(
                            name: organization.name,
                            onTap: () => ref
                                .read(authControllerProvider.notifier)
                                .switchOrganization(organization.id),
                          ),
                          if (organization != session.organizations.last)
                            const SizedBox(height: 12),
                        ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _OrganizationOption extends StatelessWidget {
  const _OrganizationOption({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.business_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(name, style: Theme.of(context).textTheme.titleMedium),
            ),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    ),
  );
}

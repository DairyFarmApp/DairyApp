import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/sync/sync_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/status_indicators.dart';
import 'package:dairycare_mobile/features/foundation_home/application/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class FoundationHomeScreen extends ConsumerWidget {
  const FoundationHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final sync = ref.watch(syncControllerProvider);
    final animalCount = ref.watch(cachedActiveAnimalCountProvider);
    final lastSync = sync.lastSuccessfulSyncAt == null
        ? 'Not synced yet'
        : DateFormat.yMMMd().add_jm().format(
            sync.lastSuccessfulSyncAt!.toLocal(),
          );

    return SingleChildScrollView(
      child: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              eyebrow: 'Farm overview',
              title: _greeting(session?.user.name),
              subtitle:
                  'A clear view of ${session?.activeFarm?.name ?? 'your active farm'} '
                  'and the records available on this device.',
              actions: MediaQuery.sizeOf(context).width < 760
                  ? const [OfflineStatusIndicator(), SyncStatusIndicator()]
                  : const [],
            ),
            const SizedBox(height: 26),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1050
                    ? 4
                    : constraints.maxWidth >= 620
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - ((columns - 1) * 14)) / columns;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    SizedBox(
                      width: width,
                      height: 176,
                      child: MetricCard(
                        label: 'Active animals',
                        value: animalCount.when(
                          data: (count) => '$count',
                          loading: () => '—',
                          error: (_, _) => '—',
                        ),
                        helper: 'Authorized records cached for this farm',
                        icon: Icons.pets_rounded,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      height: 176,
                      child: MetricCard(
                        label: 'Authorized farms',
                        value: '${session?.farms.length ?? 0}',
                        helper: session?.activeOrganization?.name,
                        icon: Icons.agriculture_rounded,
                        color: const Color(0xFF337A86),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      height: 176,
                      child: MetricCard(
                        label: 'Pending sync',
                        value: '${sync.pendingCount}',
                        helper: sync.pendingCount == 0
                            ? 'Everything is up to date'
                            : 'Operations waiting to synchronize',
                        icon: Icons.sync_rounded,
                        color: dashboardAccentGold,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      height: 176,
                      child: MetricCard(
                        label: 'Sync conflicts',
                        value: '${sync.conflictCount}',
                        helper: sync.conflictCount == 0
                            ? 'No action required'
                            : 'Review in sync diagnostics',
                        icon: Icons.rule_folder_outlined,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 850;
                final quickActions = SectionCard(
                  title: 'Quick actions',
                  subtitle: 'Go straight to your most common farm tasks.',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (session?.can('animals.view') ?? false)
                        _QuickAction(
                          icon: Icons.search_rounded,
                          label: 'Find animal',
                          onTap: () => context.go('/animals'),
                        ),
                      if (session?.can('animals.create') ?? false)
                        _QuickAction(
                          icon: Icons.add_rounded,
                          label: 'Add animal',
                          onTap: () => context.go('/animals/new'),
                        ),
                      if (session?.can('animals.record_weight') ?? false)
                        _QuickAction(
                          icon: Icons.monitor_weight_outlined,
                          label: 'Record weight',
                          onTap: () => context.go('/animals'),
                        ),
                      if (session?.can('inventory.view') ?? false)
                        _QuickAction(
                          icon: Icons.inventory_2_outlined,
                          label: 'Manage inventory',
                          onTap: () => context.go('/inventory'),
                        ),
                      _QuickAction(
                        icon: Icons.sync_rounded,
                        label: 'Sync diagnostics',
                        onTap: () => context.go('/sync'),
                      ),
                    ],
                  ),
                );
                final contextCard = SectionCard(
                  title: 'Current workspace',
                  subtitle: 'Your active access context and device status.',
                  child: Column(
                    children: [
                      _ContextRow(
                        icon: Icons.business_outlined,
                        label: 'Organization',
                        value:
                            session?.activeOrganization?.name ?? 'Not selected',
                      ),
                      const Divider(height: 28),
                      _ContextRow(
                        icon: Icons.agriculture_outlined,
                        label: 'Farm',
                        value: session?.activeFarm?.name ?? 'Not selected',
                      ),
                      const Divider(height: 28),
                      _ContextRow(
                        icon: Icons.schedule_rounded,
                        label: 'Last synchronization',
                        value: lastSync,
                      ),
                    ],
                  ),
                );
                if (!wide) {
                  return Column(
                    children: [
                      quickActions,
                      const SizedBox(height: 20),
                      contextCard,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: quickActions),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: contextCard),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon),
    label: Text(label),
  );
}

final class _ContextRow extends StatelessWidget {
  const _ContextRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, size: 21),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    ],
  );
}

String _greeting(String? name) {
  final words = name
      ?.trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words == null || words.isEmpty) return 'Welcome to DairyCare';
  return 'Welcome back, ${words.first}';
}

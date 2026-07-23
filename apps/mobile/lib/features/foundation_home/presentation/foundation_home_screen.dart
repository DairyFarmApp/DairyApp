import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/sync/sync_controller.dart';
import 'package:dairycare_mobile/core/widgets/status_indicators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final class FoundationHomeScreen extends ConsumerWidget {
  const FoundationHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final sync = ref.watch(syncControllerProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Application foundation',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text('This screen displays authenticated foundation data only.'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [OfflineStatusIndicator(), SyncStatusIndicator()],
        ),
        const SizedBox(height: 20),
        _InfoCard(
          label: 'Signed in as',
          value: session?.user.name ?? 'Unknown',
        ),
        _InfoCard(
          label: 'Organization',
          value: session?.activeOrganization?.name ?? 'Not selected',
        ),
        _InfoCard(
          label: 'Farm',
          value: session?.activeFarm?.name ?? 'Not selected',
        ),
        _InfoCard(
          label: 'Last synchronization',
          value: sync.lastSuccessfulSyncAt == null
              ? 'Not synchronized on this device'
              : DateFormat.yMMMd().add_jm().format(
                  sync.lastSuccessfulSyncAt!.toLocal(),
                ),
        ),
      ],
    );
  }
}

final class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(title: Text(label), subtitle: Text(value)),
  );
}

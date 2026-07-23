import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/core/sync/sync_controller.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SyncDiagnosticsScreen extends ConsumerWidget {
  const SyncDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncControllerProvider);
    final conflicts = ref.watch(appDatabaseProvider).watchUnresolvedConflicts();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Synchronization',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${status.pendingCount} pending · ${status.conflictCount} conflicts',
          ),
          if (status.lastError != null)
            Text(
              status.lastError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: status.isSynchronizing
                ? null
                : () => ref.read(syncControllerProvider.notifier).synchronize(),
            icon: const Icon(Icons.sync),
            label: const Text('Sync now'),
          ),
          const SizedBox(height: 20),
          Text(
            'Unresolved conflicts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Expanded(
            child: StreamBuilder(
              stream: conflicts,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LoadingStateView();
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const EmptyStateView(
                    message: 'No unresolved conflicts.',
                  );
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, index) => ListTile(
                    title: Text(
                      '${items[index].aggregateType} ${items[index].aggregateId}',
                    ),
                    subtitle: Text(items[index].reason),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

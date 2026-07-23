import 'package:dairycare_mobile/core/network/connectivity_provider.dart';
import 'package:dairycare_mobile/core/sync/sync_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class OfflineStatusIndicator extends ConsumerWidget {
  const OfflineStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(isOfflineProvider);
    return Semantics(
      label: offline ? 'Offline' : 'Online',
      child: Chip(
        avatar: Icon(offline ? Icons.cloud_off : Icons.cloud_done, size: 18),
        label: Text(offline ? 'Offline' : 'Online'),
      ),
    );
  }
}

final class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncControllerProvider);
    return Semantics(
      label: '${status.pendingCount} pending synchronization operations',
      child: Chip(
        avatar: status.isSynchronizing
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync, size: 18),
        label: Text('Pending ${status.pendingCount}'),
      ),
    );
  }
}

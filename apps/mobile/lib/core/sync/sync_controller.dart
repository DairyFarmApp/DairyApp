import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/core/sync/sync_models.dart';
import 'package:dairycare_mobile/core/sync/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final pendingSyncCountProvider = StreamProvider<int>(
  (ref) => ref.watch(appDatabaseProvider).watchPendingOperationCount(),
);

final unresolvedConflictCountProvider = StreamProvider<int>(
  (ref) => ref
      .watch(appDatabaseProvider)
      .watchUnresolvedConflicts()
      .map((items) => items.length),
);

final syncControllerProvider = NotifierProvider<SyncController, SyncStatus>(
  SyncController.new,
);

class SyncController extends Notifier<SyncStatus> {
  @override
  SyncStatus build() {
    final pending = ref.watch(pendingSyncCountProvider).value ?? 0;
    final conflicts = ref.watch(unresolvedConflictCountProvider).value ?? 0;
    return SyncStatus(pendingCount: pending, conflictCount: conflicts);
  }

  Future<void> synchronize() async {
    final organizationId = ref
        .read(authControllerProvider)
        .asData
        ?.value
        ?.activeOrganizationId;
    if (organizationId == null || state.isSynchronizing) return;
    state = state.copyWith(isSynchronizing: true, clearError: true);
    try {
      final database = ref.read(appDatabaseProvider);
      final existingDevice = await database
          .select(database.syncDevices)
          .getSingleOrNull();
      if (existingDevice == null) {
        await database
            .into(database.syncDevices)
            .insert(
              SyncDevicesCompanion.insert(
                id: const Uuid().v7(),
                name: 'DairyCare device',
                lastSeenAt: Value(DateTime.now().toUtc()),
              ),
            );
      }
      await SyncService(
        database: database,
        api: ref.read(apiClientProvider),
      ).synchronize(organizationId: organizationId);
      state = state.copyWith(
        isSynchronizing: false,
        lastSuccessfulSyncAt: DateTime.now().toUtc(),
      );
    } catch (error) {
      state = state.copyWith(
        isSynchronizing: false,
        lastError: error.toString(),
      );
    }
  }
}

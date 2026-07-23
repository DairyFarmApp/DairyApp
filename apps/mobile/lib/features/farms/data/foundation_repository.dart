import 'dart:convert';

import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class FoundationRepository {
  FoundationRepository(this._database, {Uuid uuid = const Uuid()})
    : _uuid = uuid;

  final AppDatabase _database;
  final Uuid _uuid;

  Stream<List<LocalFarm>> watchFarms(String organizationId) =>
      (_database.select(_database.localFarms)
            ..where(
              (row) =>
                  row.organizationId.equals(organizationId) &
                  row.isDeleted.equals(false),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .watch();

  Stream<List<LocalShed>> watchSheds(String organizationId, String farmId) =>
      (_database.select(_database.localSheds)
            ..where(
              (row) =>
                  row.organizationId.equals(organizationId) &
                  row.farmId.equals(farmId) &
                  row.isDeleted.equals(false),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .watch();

  Future<String> createFarmOffline({
    required String organizationId,
    required String deviceId,
    required String name,
    required String timezone,
  }) async {
    final id = _uuid.v7();
    final operationId = _uuid.v7();
    final key = _uuid.v7();
    final now = DateTime.now().toUtc();
    final payload = {'id': id, 'name': name, 'timezone': timezone};
    await _database.upsertFarmAndEnqueue(
      LocalFarmsCompanion.insert(
        id: id,
        organizationId: organizationId,
        name: name,
        timezone: Value(timezone),
        serverUpdatedAt: now,
      ),
      SyncOutboxCompanion.insert(
        id: operationId,
        organizationId: organizationId,
        deviceId: deviceId,
        idempotencyKey: key,
        aggregateType: 'farm',
        aggregateId: id,
        method: 'POST',
        path: '/farms',
        payloadJson: jsonEncode(payload),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  Future<String> createShedOffline({
    required String organizationId,
    required String farmId,
    required String deviceId,
    required String name,
  }) async {
    final id = _uuid.v7();
    final operationId = _uuid.v7();
    final now = DateTime.now().toUtc();
    await _database.upsertShedAndEnqueue(
      LocalShedsCompanion.insert(
        id: id,
        organizationId: organizationId,
        farmId: farmId,
        name: name,
        serverUpdatedAt: now,
      ),
      SyncOutboxCompanion.insert(
        id: operationId,
        organizationId: organizationId,
        farmId: Value(farmId),
        deviceId: deviceId,
        idempotencyKey: _uuid.v7(),
        aggregateType: 'shed',
        aggregateId: id,
        method: 'POST',
        path: '/farms/$farmId/sheds',
        payloadJson: jsonEncode({'id': id, 'name': name}),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }
}

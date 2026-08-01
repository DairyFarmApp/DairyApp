import 'dart:convert';

import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class FoundationRepository {
  FoundationRepository({
    required AppDatabase database,
    required ApiClient api,
    Uuid uuid = const Uuid(),
  }) : _database = database,
       _api = api,
       _uuid = uuid;

  final AppDatabase _database;
  final ApiClient _api;
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

  Future<LocalFarm> loadFarm({
    required String organizationId,
    required String farmId,
  }) async {
    try {
      final body = await _api.getJson('/farms/$farmId');
      return _cacheFarm(body['data'] as Map<String, dynamic>);
    } on NetworkException {
      return _cachedFarm(organizationId, farmId);
    } on TransientServerException {
      return _cachedFarm(organizationId, farmId);
    }
  }

  Future<LocalFarm> updateFarm({
    required LocalFarm farm,
    required String name,
    required String timezone,
  }) async {
    final body = await _api.patchJson(
      '/farms/${farm.id}',
      data: {'name': name, 'timezone': timezone},
    );
    return _cacheFarm(body['data'] as Map<String, dynamic>);
  }

  Future<LocalFarm> createFarm({
    required String name,
    required String timezone,
  }) async {
    final body = await _api.postJson(
      '/farms',
      data: {'id': _uuid.v7(), 'name': name, 'timezone': timezone},
      idempotencyKey: _uuid.v7(),
    );
    return _cacheFarm(body['data'] as Map<String, dynamic>);
  }

  Future<List<LocalShed>> loadSheds({
    required String organizationId,
    required String farmId,
  }) async {
    try {
      final body = await _api.getJson(
        '/farms/$farmId/sheds',
        query: {'page[size]': 100},
      );
      for (final raw in _maps(body['data'])) {
        await _cacheShed(raw);
      }
    } on NetworkException {
      // The local query below is the supported offline fallback.
    } on TransientServerException {
      // The local query below is the supported offline fallback.
    }
    return (_database.select(_database.localSheds)
          ..where(
            (row) =>
                row.organizationId.equals(organizationId) &
                row.farmId.equals(farmId) &
                row.isDeleted.equals(false),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .get();
  }

  Future<ShedCreateResult> createShed({
    required String organizationId,
    required String farmId,
    required String name,
  }) async {
    final id = _uuid.v7();
    try {
      final body = await _api.postJson(
        '/farms/$farmId/sheds',
        data: {'id': id, 'name': name},
        idempotencyKey: _uuid.v7(),
      );
      return ShedCreateResult(
        shed: await _cacheShed(body['data'] as Map<String, dynamic>),
        queuedOffline: false,
      );
    } on NetworkException {
      final shedId = await createShedOffline(
        organizationId: organizationId,
        farmId: farmId,
        name: name,
        id: id,
      );
      return ShedCreateResult(
        shed: await _cachedShed(shedId),
        queuedOffline: true,
      );
    } on TransientServerException {
      final shedId = await createShedOffline(
        organizationId: organizationId,
        farmId: farmId,
        name: name,
        id: id,
      );
      return ShedCreateResult(
        shed: await _cachedShed(shedId),
        queuedOffline: true,
      );
    }
  }

  Future<LocalShed> updateShed({
    required LocalShed shed,
    required String name,
  }) async {
    final body = await _api.patchJson(
      '/sheds/${shed.id}',
      data: {'name': name},
    );
    return _cacheShed(body['data'] as Map<String, dynamic>);
  }

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
    required String name,
    String? deviceId,
    String? id,
  }) async {
    final shedId = id ?? _uuid.v7();
    final operationId = _uuid.v7();
    final now = DateTime.now().toUtc();
    final resolvedDeviceId = deviceId ?? await _deviceId();
    await _database.upsertShedAndEnqueue(
      LocalShedsCompanion.insert(
        id: shedId,
        organizationId: organizationId,
        farmId: farmId,
        name: name,
        serverUpdatedAt: now,
      ),
      SyncOutboxCompanion.insert(
        id: operationId,
        organizationId: organizationId,
        farmId: Value(farmId),
        deviceId: resolvedDeviceId,
        idempotencyKey: _uuid.v7(),
        aggregateType: 'shed',
        aggregateId: shedId,
        method: 'POST',
        path: '/farms/$farmId/sheds',
        payloadJson: jsonEncode({'id': shedId, 'name': name}),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return shedId;
  }

  Future<LocalFarm> _cacheFarm(Map<String, dynamic> raw) async {
    final now = DateTime.now().toUtc();
    await _database
        .into(_database.localFarms)
        .insertOnConflictUpdate(
          LocalFarmsCompanion.insert(
            id: raw['id'] as String,
            organizationId: raw['organization_id'] as String,
            name: raw['name'] as String,
            timezone: Value(raw['timezone'] as String? ?? 'UTC'),
            version: Value(raw['version'] as int? ?? 1),
            serverUpdatedAt: _date(raw['updated_at'], now),
            isDeleted: Value(raw['is_deleted'] as bool? ?? false),
          ),
        );
    return _cachedFarm(raw['organization_id'] as String, raw['id'] as String);
  }

  Future<LocalShed> _cacheShed(Map<String, dynamic> raw) async {
    final now = DateTime.now().toUtc();
    await _database
        .into(_database.localSheds)
        .insertOnConflictUpdate(
          LocalShedsCompanion.insert(
            id: raw['id'] as String,
            organizationId: raw['organization_id'] as String,
            farmId: raw['farm_id'] as String,
            name: raw['name'] as String,
            version: Value(raw['version'] as int? ?? 1),
            serverUpdatedAt: _date(raw['updated_at'], now),
            isDeleted: Value(raw['is_deleted'] as bool? ?? false),
          ),
        );
    return _cachedShed(raw['id'] as String);
  }

  Future<LocalFarm> _cachedFarm(String organizationId, String farmId) async {
    final farm =
        await (_database.select(_database.localFarms)..where(
              (row) =>
                  row.id.equals(farmId) &
                  row.organizationId.equals(organizationId) &
                  row.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (farm == null) {
      throw const NetworkException(
        'The farm profile is not available offline on this device.',
      );
    }
    return farm;
  }

  Future<LocalShed> _cachedShed(String id) => (_database.select(
    _database.localSheds,
  )..where((row) => row.id.equals(id))).getSingle();

  Future<String> _deviceId() async {
    final existing = await _database
        .select(_database.syncDevices)
        .getSingleOrNull();
    if (existing != null) return existing.id;
    final id = _uuid.v7();
    await _database
        .into(_database.syncDevices)
        .insert(
          SyncDevicesCompanion.insert(
            id: id,
            name: 'DairyCare device',
            lastSeenAt: Value(DateTime.now().toUtc()),
          ),
        );
    return id;
  }

  List<Map<String, dynamic>> _maps(Object? value) =>
      (value as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  DateTime _date(Object? value, DateTime fallback) =>
      value is String ? DateTime.parse(value).toUtc() : fallback;
}

final class ShedCreateResult {
  const ShedCreateResult({required this.shed, required this.queuedOffline});

  final LocalShed shed;
  final bool queuedOffline;
}

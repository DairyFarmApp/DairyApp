import 'dart:convert';

import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/sync/retry_policy.dart';
import 'package:drift/drift.dart';

final class SyncService {
  SyncService({
    required AppDatabase database,
    required ApiClient api,
    ExponentialRetryPolicy? retryPolicy,
  }) : _database = database,
       _api = api,
       _retryPolicy = retryPolicy ?? ExponentialRetryPolicy();

  final AppDatabase _database;
  final ApiClient _api;
  final ExponentialRetryPolicy _retryPolicy;

  Future<void> synchronize({required String organizationId}) async {
    for (final operation in await _database.dueOperations(
      organizationId,
      DateTime.now().toUtc(),
    )) {
      if (!await _dependenciesSatisfied(operation)) continue;
      await _upload(operation);
    }
    await _pullChanges(organizationId);
  }

  Future<void> _upload(SyncOutboxData operation) async {
    await (_database.update(
      _database.syncOutbox,
    )..where((row) => row.id.equals(operation.id))).write(
      SyncOutboxCompanion(
        state: const Value('uploading'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    try {
      final payload = jsonDecode(operation.payloadJson) as Map<String, dynamic>;
      switch (operation.method.toUpperCase()) {
        case 'POST':
          await _api.postJson(
            operation.path,
            data: payload,
            idempotencyKey: operation.idempotencyKey,
          );
          break;
        case 'PATCH':
          await _api.patchJson(operation.path, data: payload);
          break;
        default:
          throw StateError('Unsupported outbox method ${operation.method}.');
      }
      await (_database.update(
        _database.syncOutbox,
      )..where((row) => row.id.equals(operation.id))).write(
        SyncOutboxCompanion(
          state: const Value('synced'),
          lastError: const Value(null),
          nextAttemptAt: const Value(null),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    } on ConflictException catch (error) {
      final now = DateTime.now().toUtc();
      await _database.transaction(() async {
        await (_database.update(
          _database.syncOutbox,
        )..where((row) => row.id.equals(operation.id))).write(
          SyncOutboxCompanion(
            state: const Value('conflict'),
            lastError: Value(error.code ?? 'CONFLICT'),
            nextAttemptAt: const Value(null),
            updatedAt: Value(now),
          ),
        );
        await _database
            .into(_database.syncConflicts)
            .insertOnConflictUpdate(
              SyncConflictsCompanion.insert(
                id: operation.id,
                operationId: operation.id,
                aggregateType: operation.aggregateType,
                aggregateId: operation.aggregateId,
                localPayloadJson: operation.payloadJson,
                serverPayloadJson: '{}',
                reason: error.code ?? 'CONFLICT',
                createdAt: now,
              ),
            );
      });
    } on NetworkException catch (error) {
      await _scheduleRetry(operation, error.code ?? 'NETWORK_UNAVAILABLE');
    } on TransientServerException catch (error) {
      await _scheduleRetry(operation, error.code ?? 'TRANSIENT_SERVER_ERROR');
    } on AppException catch (error) {
      await (_database.update(
        _database.syncOutbox,
      )..where((row) => row.id.equals(operation.id))).write(
        SyncOutboxCompanion(
          state: const Value('failed'),
          lastError: Value(error.code ?? 'REQUEST_REJECTED'),
          nextAttemptAt: const Value(null),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    } catch (_) {
      await (_database.update(
        _database.syncOutbox,
      )..where((row) => row.id.equals(operation.id))).write(
        SyncOutboxCompanion(
          state: const Value('failed'),
          lastError: const Value('UNEXPECTED_CLIENT_ERROR'),
          nextAttemptAt: const Value(null),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }
  }

  Future<void> _scheduleRetry(
    SyncOutboxData operation,
    String safeError,
  ) async {
    final retries = operation.retryCount + 1;
    await (_database.update(
      _database.syncOutbox,
    )..where((row) => row.id.equals(operation.id))).write(
      SyncOutboxCompanion(
        state: const Value('failed'),
        retryCount: Value(retries),
        nextAttemptAt: Value(
          DateTime.now().toUtc().add(_retryPolicy.delayForAttempt(retries)),
        ),
        lastError: Value(safeError),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<bool> _dependenciesSatisfied(SyncOutboxData operation) async {
    final dependencies = (jsonDecode(operation.dependencyIdsJson) as List)
        .map((value) => value.toString())
        .toList(growable: false);
    if (dependencies.isEmpty) return true;
    final pendingDependencies =
        await (_database.select(_database.syncOutbox)..where(
              (row) =>
                  row.organizationId.equals(operation.organizationId) &
                  row.aggregateId.isIn(dependencies) &
                  row.state.equals('synced').not(),
            ))
            .get();
    return pendingDependencies.isEmpty;
  }

  Future<void> _pullChanges(String organizationId) async {
    final cursorRow =
        await (_database.select(_database.syncCursors)..where(
              (row) =>
                  row.organizationId.equals(organizationId) &
                  row.collection.equals('foundation'),
            ))
            .getSingleOrNull();
    final response = await _api.getJson(
      cursorRow == null ? '/sync/bootstrap' : '/sync/changes',
      query: cursorRow?.cursor == null ? null : {'cursor': cursorRow!.cursor},
    );
    final data = response['data'] as Map<String, dynamic>;
    final authorizedFarmIds =
        (data['authorized_farm_ids'] as List<dynamic>? ?? const [])
            .cast<String>();
    final nextCursor = data['next_cursor'] as String?;
    final synchronizedAt = DateTime.now().toUtc();
    await _database.transaction(() async {
      await (_database.update(_database.localFarms)..where(
            (row) =>
                row.organizationId.equals(organizationId) &
                row.id.isNotIn(authorizedFarmIds),
          ))
          .write(const LocalFarmsCompanion(isDeleted: Value(true)));
      await (_database.update(_database.localSheds)..where(
            (row) =>
                row.organizationId.equals(organizationId) &
                row.farmId.isNotIn(authorizedFarmIds),
          ))
          .write(const LocalShedsCompanion(isDeleted: Value(true)));
      for (final raw in _maps(data['organizations'])) {
        await _database
            .into(_database.localOrganizations)
            .insertOnConflictUpdate(
              LocalOrganizationsCompanion.insert(
                id: raw['id'] as String,
                name: raw['name'] as String,
                version: Value(raw['version'] as int? ?? 1),
                serverUpdatedAt: _date(raw['updated_at'], synchronizedAt),
                isDeleted: Value(raw['is_deleted'] as bool? ?? false),
              ),
            );
      }
      for (final raw in _maps(data['farms'])) {
        await _database
            .into(_database.localFarms)
            .insertOnConflictUpdate(
              LocalFarmsCompanion.insert(
                id: raw['id'] as String,
                organizationId: raw['organization_id'] as String,
                name: raw['name'] as String,
                timezone: Value(raw['timezone'] as String? ?? 'UTC'),
                version: Value(raw['version'] as int? ?? 1),
                serverUpdatedAt: _date(raw['updated_at'], synchronizedAt),
                isDeleted: Value(raw['is_deleted'] as bool? ?? false),
              ),
            );
      }
      for (final raw in _maps(data['sheds'])) {
        await _database
            .into(_database.localSheds)
            .insertOnConflictUpdate(
              LocalShedsCompanion.insert(
                id: raw['id'] as String,
                organizationId: raw['organization_id'] as String,
                farmId: raw['farm_id'] as String,
                name: raw['name'] as String,
                version: Value(raw['version'] as int? ?? 1),
                serverUpdatedAt: _date(raw['updated_at'], synchronizedAt),
                isDeleted: Value(raw['is_deleted'] as bool? ?? false),
              ),
            );
      }
      await _database
          .into(_database.syncCursors)
          .insertOnConflictUpdate(
            SyncCursorsCompanion.insert(
              organizationId: organizationId,
              collection: 'foundation',
              cursor: Value(nextCursor),
              lastSuccessfulSyncAt: Value(synchronizedAt),
            ),
          );
    });
  }

  List<Map<String, dynamic>> _maps(Object? value) =>
      (value as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  DateTime _date(Object? value, DateTime fallback) =>
      value is String ? DateTime.parse(value).toUtc() : fallback;
}

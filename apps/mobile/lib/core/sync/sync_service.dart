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
    final animalMovementsAuthorized =
        data['animal_movements_authorized'] as bool? ?? false;
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
      await (_database.update(_database.localAnimalGroups)..where(
            (row) =>
                row.organizationId.equals(organizationId) &
                row.farmId.isNotIn(authorizedFarmIds),
          ))
          .write(const LocalAnimalGroupsCompanion(isAccessible: Value(false)));
      await (_database.update(_database.localAnimals)..where(
            (row) =>
                row.organizationId.equals(organizationId) &
                row.currentFarmId.isNotIn(authorizedFarmIds),
          ))
          .write(const LocalAnimalsCompanion(isAccessible: Value(false)));
      if (!animalMovementsAuthorized) {
        await (_database.update(
          _database.localAnimalMovements,
        )..where((row) => row.organizationId.equals(organizationId))).write(
          const LocalAnimalMovementsCompanion(isAccessible: Value(false)),
        );
      } else {
        await (_database.update(_database.localAnimalMovements)..where(
              (row) =>
                  row.organizationId.equals(organizationId) &
                  (row.sourceFarmId.isNotIn(authorizedFarmIds) |
                      row.destinationFarmId.isNotIn(authorizedFarmIds)),
            ))
            .write(
              const LocalAnimalMovementsCompanion(isAccessible: Value(false)),
            );
      }
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
      for (final raw in _maps(data['animal_species'])) {
        await _database
            .into(_database.localAnimalSpecies)
            .insertOnConflictUpdate(
              LocalAnimalSpeciesCompanion.insert(
                id: raw['id'] as String,
                code: raw['code'] as String,
                name: raw['name'] as String,
                isActive: Value(raw['is_active'] as bool? ?? true),
                version: Value(raw['version'] as int? ?? 1),
                serverUpdatedAt: _date(raw['updated_at'], synchronizedAt),
                cachedAt: synchronizedAt,
              ),
            );
      }
      for (final raw in _maps(data['animal_breeds'])) {
        await _database
            .into(_database.localAnimalBreeds)
            .insertOnConflictUpdate(
              LocalAnimalBreedsCompanion.insert(
                id: raw['id'] as String,
                organizationId: raw['organization_id'] as String,
                speciesId: raw['species_id'] as String,
                code: raw['code'] as String,
                name: raw['name'] as String,
                description: Value(raw['description'] as String?),
                isActive: Value(raw['is_active'] as bool? ?? true),
                version: Value(raw['version'] as int? ?? 1),
                serverUpdatedAt: _date(raw['updated_at'], synchronizedAt),
                cachedAt: synchronizedAt,
                isArchived: Value(raw['is_archived'] as bool? ?? false),
              ),
            );
      }
      for (final raw in _maps(data['animal_groups'])) {
        await _database
            .into(_database.localAnimalGroups)
            .insertOnConflictUpdate(
              LocalAnimalGroupsCompanion.insert(
                id: raw['id'] as String,
                organizationId: raw['organization_id'] as String,
                farmId: raw['farm_id'] as String,
                defaultShedId: Value(raw['default_shed_id'] as String?),
                code: raw['code'] as String,
                name: raw['name'] as String,
                description: Value(raw['description'] as String?),
                isActive: Value(raw['is_active'] as bool? ?? true),
                version: Value(raw['version'] as int? ?? 1),
                serverUpdatedAt: _date(raw['updated_at'], synchronizedAt),
                cachedAt: synchronizedAt,
                isArchived: Value(raw['is_archived'] as bool? ?? false),
                isAccessible: const Value(true),
              ),
            );
      }
      for (final raw in _maps(data['animals'])) {
        await _database
            .into(_database.localAnimals)
            .insertOnConflictUpdate(_animalCompanion(raw, synchronizedAt));
      }
      for (final raw in _maps(data['animal_movements'])) {
        await _database
            .into(_database.localAnimalMovements)
            .insertOnConflictUpdate(
              _animalMovementCompanion(raw, synchronizedAt),
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

  DateTime? _nullableDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    if (!value.contains('T')) {
      final parts = value.split('-').map(int.parse).toList(growable: false);
      return DateTime.utc(parts[0], parts[1], parts[2]);
    }
    return DateTime.parse(value).toUtc();
  }

  LocalAnimalsCompanion _animalCompanion(
    Map<String, dynamic> raw,
    DateTime synchronizedAt,
  ) => LocalAnimalsCompanion.insert(
    id: raw['id'] as String,
    organizationId: raw['organization_id'] as String,
    animalNumber: raw['animal_number'] as String,
    earTagNumber: Value(raw['ear_tag_number'] as String?),
    rfidNumber: Value(raw['rfid_number'] as String?),
    name: Value(raw['name'] as String?),
    registrationNumber: Value(raw['registration_number'] as String?),
    speciesId: raw['species_id'] as String,
    speciesName: raw['species_name'] as String? ?? '',
    breedId: raw['breed_id'] as String,
    breedName: raw['breed_name'] as String? ?? '',
    sex: raw['sex'] as String,
    lifeStage: raw['life_stage'] as String,
    dateOfBirth: Value(_nullableDate(raw['date_of_birth'])),
    isDateOfBirthEstimated: Value(
      raw['is_date_of_birth_estimated'] as bool? ?? false,
    ),
    colour: Value(raw['colour'] as String?),
    identifyingMarks: Value(raw['identifying_marks'] as String?),
    currentFarmId: raw['current_farm_id'] as String,
    currentFarmName: raw['current_farm_name'] as String? ?? '',
    currentShedId: raw['current_shed_id'] as String,
    currentShedName: raw['current_shed_name'] as String? ?? '',
    currentAnimalGroupId: Value(raw['current_animal_group_id'] as String?),
    currentAnimalGroupName: Value(raw['current_animal_group_name'] as String?),
    motherAnimalId: Value(raw['mother_animal_id'] as String?),
    motherAnimalNumber: Value(raw['mother_animal_number'] as String?),
    fatherAnimalId: Value(raw['father_animal_id'] as String?),
    fatherAnimalNumber: Value(raw['father_animal_number'] as String?),
    externalSireReference: Value(raw['external_sire_reference'] as String?),
    origin: raw['origin'] as String,
    acquisitionDate: Value(_nullableDate(raw['acquisition_date'])),
    sourceDescription: Value(raw['source_description'] as String?),
    notes: Value(raw['notes'] as String?),
    operationalStatus: raw['operational_status'] as String,
    version: Value(raw['version'] as int? ?? 1),
    serverUpdatedAt: _date(raw['updated_at'], synchronizedAt),
    cachedAt: synchronizedAt,
    isArchived: Value(raw['is_archived'] as bool? ?? false),
    isAccessible: const Value(true),
  );

  LocalAnimalMovementsCompanion _animalMovementCompanion(
    Map<String, dynamic> raw,
    DateTime synchronizedAt,
  ) => LocalAnimalMovementsCompanion.insert(
    id: raw['id'] as String,
    organizationId: raw['organization_id'] as String,
    animalId: raw['animal_id'] as String,
    animalNumber: raw['animal_number'] as String? ?? '',
    sourceFarmId: raw['source_farm_id'] as String,
    sourceFarmName: raw['source_farm_name'] as String? ?? '',
    sourceShedId: raw['source_shed_id'] as String,
    sourceShedName: raw['source_shed_name'] as String? ?? '',
    sourceAnimalGroupId: Value(raw['source_animal_group_id'] as String?),
    sourceAnimalGroupName: Value(raw['source_animal_group_name'] as String?),
    destinationFarmId: raw['destination_farm_id'] as String,
    destinationFarmName: raw['destination_farm_name'] as String? ?? '',
    destinationShedId: raw['destination_shed_id'] as String,
    destinationShedName: raw['destination_shed_name'] as String? ?? '',
    destinationAnimalGroupId: Value(
      raw['destination_animal_group_id'] as String?,
    ),
    destinationAnimalGroupName: Value(
      raw['destination_animal_group_name'] as String?,
    ),
    requestedEffectiveAt: _date(raw['requested_effective_at'], synchronizedAt),
    actualEffectiveAt: Value(_nullableDate(raw['actual_effective_at'])),
    reason: raw['reason'] as String,
    notes: Value(raw['notes'] as String?),
    status: raw['status'] as String,
    approvalRequired: Value(raw['approval_required'] as bool? ?? true),
    requestedBy: raw['requested_by'] as String,
    requestedByName: raw['requested_by_name'] as String? ?? '',
    decidedBy: Value(raw['decided_by'] as String?),
    decidedByName: Value(raw['decided_by_name'] as String?),
    decisionAt: Value(_nullableDate(raw['decision_at'])),
    rejectionReason: Value(raw['rejection_reason'] as String?),
    cancellationReason: Value(raw['cancellation_reason'] as String?),
    version: Value(raw['version'] as int? ?? 1),
    serverUpdatedAt: _date(raw['updated_at'], synchronizedAt),
    cachedAt: synchronizedAt,
    isAccessible: const Value(true),
  );
}

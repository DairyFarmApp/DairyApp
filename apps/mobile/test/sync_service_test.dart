import 'dart:convert';

import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/sync/retry_policy.dart';
import 'package:dairycare_mobile/core/sync/sync_service.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const organizationA = '018f0000-0000-7000-8000-000000000010';
  const organizationB = '018f0000-0000-7000-8000-000000000011';
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test(
    'sync processes only the active organization and does not retry 422',
    () async {
      await _enqueue(database, id: 'op-a', organizationId: organizationA);
      await _enqueue(database, id: 'op-b', organizationId: organizationB);
      final service = SyncService(
        database: database,
        api: _api(writeStatus: 422, errorCode: 'VALIDATION_FAILED'),
      );

      await service.synchronize(organizationId: organizationA);

      final operations = await database.select(database.syncOutbox).get();
      final active = operations.singleWhere((item) => item.id == 'op-a');
      final foreign = operations.singleWhere((item) => item.id == 'op-b');
      expect(active.state, 'failed');
      expect(active.nextAttemptAt, isNull);
      expect(active.lastError, 'VALIDATION_FAILED');
      expect(foreign.state, 'pending');
      expect(
        await database.dueOperations(organizationA, DateTime.now().toUtc()),
        isEmpty,
      );
    },
  );

  test(
    'conflict response creates a conflict record without retrying',
    () async {
      await _enqueue(
        database,
        id: 'op-conflict',
        organizationId: organizationA,
      );
      await SyncService(
        database: database,
        api: _api(writeStatus: 409, errorCode: 'STALE_VERSION'),
      ).synchronize(organizationId: organizationA);

      final operation = await database.select(database.syncOutbox).getSingle();
      final conflict = await database
          .select(database.syncConflicts)
          .getSingle();
      expect(operation.state, 'conflict');
      expect(operation.nextAttemptAt, isNull);
      expect(conflict.operationId, operation.id);
      expect(conflict.reason, 'STALE_VERSION');
    },
  );

  test('transient response schedules a bounded retry', () async {
    await _enqueue(database, id: 'op-retry', organizationId: organizationA);
    await SyncService(
      database: database,
      api: _api(writeStatus: 503, errorCode: 'SERVICE_UNAVAILABLE'),
      retryPolicy: ExponentialRetryPolicy(
        baseDelay: const Duration(seconds: 1),
        maximumDelay: const Duration(seconds: 1),
      ),
    ).synchronize(organizationId: organizationA);

    final operation = await database.select(database.syncOutbox).getSingle();
    expect(operation.state, 'failed');
    expect(operation.retryCount, 1);
    expect(operation.nextAttemptAt, isNotNull);
    expect(operation.lastError, 'SERVICE_UNAVAILABLE');
  });

  test('unsynchronized dependencies block child upload', () async {
    await _enqueue(database, id: 'parent', organizationId: organizationA);
    await _enqueue(
      database,
      id: 'child',
      organizationId: organizationA,
      dependencyIds: const ['aggregate-parent'],
      aggregateId: 'aggregate-child',
    );
    await (database.update(database.syncOutbox)
          ..where((row) => row.id.equals('parent')))
        .write(const SyncOutboxCompanion(state: Value('conflict')));

    await SyncService(
      database: database,
      api: _api(writeStatus: 201),
    ).synchronize(organizationId: organizationA);

    final child = await (database.select(
      database.syncOutbox,
    )..where((row) => row.id.equals('child'))).getSingle();
    expect(child.state, 'pending');
  });

  test(
    'pull marks cached farms outside the authorized set as unavailable',
    () async {
      final now = DateTime.now().toUtc();
      await database
          .into(database.localFarms)
          .insert(
            LocalFarmsCompanion.insert(
              id: 'farm-hidden',
              organizationId: organizationA,
              name: 'Hidden Farm',
              serverUpdatedAt: now,
            ),
          );

      await SyncService(
        database: database,
        api: _api(writeStatus: 201),
      ).synchronize(organizationId: organizationA);

      expect(
        (await database.select(database.localFarms).getSingle()).isDeleted,
        isTrue,
      );
    },
  );

  test('pull applies archive tombstones to cached sheds', () async {
    final now = DateTime.now().toUtc();
    await database
        .into(database.localSheds)
        .insert(
          LocalShedsCompanion.insert(
            id: 'shed-archived',
            organizationId: organizationA,
            farmId: 'farm-active',
            name: 'Archived Shed',
            serverUpdatedAt: now,
          ),
        );

    await SyncService(
      database: database,
      api: _api(
        writeStatus: 201,
        syncData: {
          'organizations': <Object>[],
          'farms': <Object>[],
          'sheds': [
            {
              'id': 'shed-archived',
              'organization_id': organizationA,
              'farm_id': 'farm-active',
              'name': 'Archived Shed',
              'version': 2,
              'updated_at': now.toIso8601String(),
              'is_deleted': true,
            },
          ],
          'authorized_farm_ids': ['farm-active'],
          'next_cursor': 'cursor',
        },
      ),
    ).synchronize(organizationId: organizationA);

    expect(
      (await database.select(database.localSheds).getSingle()).isDeleted,
      isTrue,
    );
  });

  test(
    'animal bootstrap caches registry records, tombstones, and farm access',
    () async {
      const farm = '018f0000-0000-7000-8000-000000000020';
      const shed = '018f0000-0000-7000-8000-000000000030';
      const species = '018f0000-0000-7000-8000-000000000040';
      const breed = '018f0000-0000-7000-8000-000000000050';
      const group = '018f0000-0000-7000-8000-000000000060';
      const animal = '018f0000-0000-7000-8000-000000000070';
      final now = DateTime.now().toUtc().toIso8601String();
      await SyncService(
        database: database,
        api: _api(
          writeStatus: 201,
          syncData: {
            'organizations': <Object>[],
            'farms': <Object>[],
            'sheds': <Object>[],
            'animal_species': [
              {
                'id': species,
                'code': 'CATTLE',
                'name': 'Cattle',
                'is_active': true,
                'updated_at': now,
              },
            ],
            'animal_breeds': [
              {
                'id': breed,
                'organization_id': organizationA,
                'species_id': species,
                'code': 'SAHIWAL',
                'name': 'Sahiwal',
                'is_active': true,
                'version': 1,
                'is_archived': false,
                'updated_at': now,
              },
            ],
            'animal_groups': [
              {
                'id': group,
                'organization_id': organizationA,
                'farm_id': farm,
                'default_shed_id': shed,
                'code': 'MAIN-HERD',
                'name': 'Main Herd',
                'is_active': true,
                'version': 1,
                'is_archived': false,
                'updated_at': now,
              },
            ],
            'animals': [
              {
                'id': animal,
                'organization_id': organizationA,
                'animal_number': 'AN-000001',
                'species_id': species,
                'species_name': 'Cattle',
                'breed_id': breed,
                'breed_name': 'Sahiwal',
                'sex': 'female',
                'life_stage': 'adult',
                'current_farm_id': farm,
                'current_farm_name': 'North Farm',
                'current_shed_id': shed,
                'current_shed_name': 'Main Shed',
                'current_animal_group_id': group,
                'current_animal_group_name': 'Main Herd',
                'origin': 'born_on_farm',
                'operational_status': 'active',
                'version': 2,
                'is_archived': true,
                'updated_at': now,
              },
            ],
            'authorized_farm_ids': [farm],
            'next_cursor': 'animal-cursor',
          },
        ),
      ).synchronize(organizationId: organizationA);

      expect(
        await database.select(database.localAnimalSpecies).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.localAnimalBreeds).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.localAnimalGroups).get(),
        hasLength(1),
      );
      final cachedAnimal = await database
          .select(database.localAnimals)
          .getSingle();
      expect(cachedAnimal.isArchived, isTrue);
      expect(cachedAnimal.isAccessible, isTrue);

      await SyncService(
        database: database,
        api: _api(
          writeStatus: 201,
          syncData: {
            'organizations': <Object>[],
            'farms': <Object>[],
            'sheds': <Object>[],
            'animal_species': <Object>[],
            'animal_breeds': <Object>[],
            'animal_groups': <Object>[],
            'animals': <Object>[],
            'authorized_farm_ids': <String>[],
            'next_cursor': 'access-revoked',
          },
        ),
      ).synchronize(organizationId: organizationA);

      expect(
        (await database.select(database.localAnimals).getSingle()).isAccessible,
        isFalse,
      );
      expect(
        (await database.select(database.localAnimalGroups).getSingle())
            .isAccessible,
        isFalse,
      );
    },
  );

  test(
    'movement sync upserts status changes and removes revoked farm access',
    () async {
      const sourceFarm = '018f0000-0000-7000-8000-000000000020';
      const destinationFarm = '018f0000-0000-7000-8000-000000000021';
      const animal = '018f0000-0000-7000-8000-000000000070';
      const movement = '018f0000-0000-7000-8000-000000000080';
      final now = DateTime.now().toUtc().toIso8601String();
      Map<String, Object?> movementData(String status, int version) => {
        'id': movement,
        'organization_id': organizationA,
        'animal_id': animal,
        'animal_number': 'AN-000001',
        'source_farm_id': sourceFarm,
        'source_farm_name': 'North Farm',
        'source_shed_id': 'source-shed',
        'source_shed_name': 'Main Shed',
        'destination_farm_id': destinationFarm,
        'destination_farm_name': 'South Farm',
        'destination_shed_id': 'destination-shed',
        'destination_shed_name': 'Receiving Shed',
        'requested_effective_at': now,
        'actual_effective_at': status == 'approved' ? now : null,
        'reason': 'Routine relocation',
        'status': status,
        'approval_required': true,
        'requested_by': 'requester',
        'requested_by_name': 'Bilal Ahmed',
        'version': version,
        'updated_at': now,
      };

      await SyncService(
        database: database,
        api: _api(
          writeStatus: 201,
          syncData: {
            'organizations': <Object>[],
            'farms': <Object>[],
            'sheds': <Object>[],
            'animal_movements': [movementData('pending', 1)],
            'animal_movements_authorized': true,
            'authorized_farm_ids': [sourceFarm, destinationFarm],
            'next_cursor': 'movement-pending',
          },
        ),
      ).synchronize(organizationId: organizationA);

      var cached = await database
          .select(database.localAnimalMovements)
          .getSingle();
      expect(cached.status, 'pending');
      expect(cached.isAccessible, isTrue);

      await SyncService(
        database: database,
        api: _api(
          writeStatus: 201,
          syncData: {
            'organizations': <Object>[],
            'farms': <Object>[],
            'sheds': <Object>[],
            'animal_movements': [movementData('approved', 2)],
            'animal_movements_authorized': true,
            'authorized_farm_ids': [sourceFarm, destinationFarm],
            'next_cursor': 'movement-approved',
          },
        ),
      ).synchronize(organizationId: organizationA);
      cached = await database.select(database.localAnimalMovements).getSingle();
      expect(cached.status, 'approved');
      expect(cached.version, 2);

      await SyncService(
        database: database,
        api: _api(
          writeStatus: 201,
          syncData: {
            'organizations': <Object>[],
            'farms': <Object>[],
            'sheds': <Object>[],
            'animal_movements': <Object>[],
            'animal_movements_authorized': true,
            'authorized_farm_ids': [destinationFarm],
            'next_cursor': 'movement-revoked',
          },
        ),
      ).synchronize(organizationId: organizationA);
      expect(
        (await database.select(database.localAnimalMovements).getSingle())
            .isAccessible,
        isFalse,
      );
    },
  );

  test(
    'weight corrections and status changes upsert then conceal permission removal',
    () async {
      const farm = '018f0000-0000-7000-8000-000000000020';
      const animal = '018f0000-0000-7000-8000-000000000070';
      const weight = '018f0000-0000-7000-8000-000000000090';
      const correction = '018f0000-0000-7000-8000-000000000091';
      const status = '018f0000-0000-7000-8000-000000000092';
      final now = DateTime.now().toUtc().toIso8601String();
      Map<String, Object?> weightData({
        required String id,
        bool superseded = false,
        String? supersedes,
        String? supersededBy,
      }) => {
        'id': id,
        'organization_id': organizationA,
        'farm_id': farm,
        'farm_name': 'North Farm',
        'animal_id': animal,
        'animal_number': 'AN-000001',
        'entered_value': id == correction ? '501.000000' : '500.000000',
        'entered_unit': 'kg',
        'normalized_kg': id == correction ? '501.000000' : '500.000000',
        'observed_at': now,
        'source': 'scale',
        'recorded_by': 'owner',
        'recorded_by_name': 'Ayesha Khan',
        'supersedes_weight_id': supersedes,
        'superseded_by_weight_id': supersededBy,
        'correction_reason': supersedes == null ? null : 'Paper log checked.',
        'is_superseded': superseded,
        'updated_at': now,
      };
      Map<String, Object?> statusData(int sequence, String newStatus) => {
        'id': sequence == 1 ? status : '${status}1',
        'organization_id': organizationA,
        'farm_id': farm,
        'farm_name': 'North Farm',
        'animal_id': animal,
        'animal_number': 'AN-000001',
        'previous_status': sequence == 1 ? 'active' : 'inactive',
        'new_status': newStatus,
        'effective_at': now,
        'reason': 'Status sync test.',
        'changed_by': 'owner',
        'changed_by_name': 'Ayesha Khan',
        'sequence': sequence,
        'updated_at': now,
      };

      await SyncService(
        database: database,
        api: _api(
          writeStatus: 201,
          syncData: {
            'organizations': <Object>[],
            'farms': <Object>[],
            'sheds': <Object>[],
            'animal_weights': [weightData(id: weight)],
            'animal_weights_authorized': true,
            'animal_status_changes': [statusData(1, 'inactive')],
            'animal_status_changes_authorized': true,
            'authorized_farm_ids': [farm],
            'next_cursor': 'measurement-one',
          },
        ),
      ).synchronize(organizationId: organizationA);

      expect(
        (await database.select(database.localAnimalWeights).getSingle())
            .isAccessible,
        isTrue,
      );
      expect(
        (await database.select(database.localAnimalStatusChanges).getSingle())
            .newStatus,
        'inactive',
      );

      await SyncService(
        database: database,
        api: _api(
          writeStatus: 201,
          syncData: {
            'organizations': <Object>[],
            'farms': <Object>[],
            'sheds': <Object>[],
            'animal_weights': [
              weightData(
                id: weight,
                superseded: true,
                supersededBy: correction,
              ),
              weightData(id: correction, supersedes: weight),
            ],
            'animal_weights_authorized': true,
            'animal_status_changes': [statusData(2, 'active')],
            'animal_status_changes_authorized': true,
            'authorized_farm_ids': [farm],
            'next_cursor': 'measurement-two',
          },
        ),
      ).synchronize(organizationId: organizationA);

      final weights = await database.select(database.localAnimalWeights).get();
      expect(weights, hasLength(2));
      expect(
        weights.firstWhere((row) => row.id == weight).isSuperseded,
        isTrue,
      );
      expect(
        (await database.select(database.localAnimalStatusChanges).get()).map(
          (row) => row.sequence,
        ),
        containsAll([1, 2]),
      );

      await SyncService(
        database: database,
        api: _api(
          writeStatus: 201,
          syncData: {
            'organizations': <Object>[],
            'farms': <Object>[],
            'sheds': <Object>[],
            'animal_weights': <Object>[],
            'animal_weights_authorized': false,
            'animal_status_changes': <Object>[],
            'animal_status_changes_authorized': false,
            'authorized_farm_ids': [farm],
            'next_cursor': 'measurement-revoked',
          },
        ),
      ).synchronize(organizationId: organizationA);
      expect(
        (await database.select(database.localAnimalWeights).get()).every(
          (row) => !row.isAccessible,
        ),
        isTrue,
      );
      expect(
        (await database.select(database.localAnimalStatusChanges).get()).every(
          (row) => !row.isAccessible,
        ),
        isTrue,
      );
    },
  );

  test('stored cursor selects incremental endpoint on the next pull', () async {
    final requests = <RequestOptions>[];
    final service = SyncService(
      database: database,
      api: _api(writeStatus: 201, requests: requests),
    );

    await service.synchronize(organizationId: organizationA);
    await service.synchronize(organizationId: organizationA);

    final getRequests = requests.where((request) => request.method == 'GET');
    expect(getRequests.first.path, '/sync/bootstrap');
    expect(getRequests.last.path, '/sync/changes');
    expect(getRequests.last.queryParameters['cursor'], 'cursor');
  });
}

Future<void> _enqueue(
  AppDatabase database, {
  required String id,
  required String organizationId,
  String aggregateId = 'aggregate-parent',
  List<String> dependencyIds = const [],
}) {
  final now = DateTime.now().toUtc();
  return database
      .into(database.syncOutbox)
      .insert(
        SyncOutboxCompanion.insert(
          id: id,
          organizationId: organizationId,
          deviceId: '018f0000-0000-7000-8000-000000000099',
          idempotencyKey: 'key-$id',
          aggregateType: 'farm',
          aggregateId: aggregateId,
          method: 'POST',
          path: '/farms',
          payloadJson: '{}',
          dependencyIdsJson: Value(jsonEncode(dependencyIds)),
          createdAt: now,
          updatedAt: now,
        ),
      );
}

ApiClient _api({
  required int writeStatus,
  String? errorCode,
  Map<String, Object?>? syncData,
  List<RequestOptions>? requests,
}) {
  final dio = Dio();
  final api = ApiClient(
    config: EnvironmentConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: Uri.parse('http://example.test/api/v1'),
    ),
    readAccessToken: () async => null,
    dio: dio,
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests?.add(options);
        if (options.method == 'GET') {
          handler.resolve(
            Response<Object>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'data':
                    syncData ??
                    {
                      'organizations': <Object>[],
                      'farms': <Object>[],
                      'sheds': <Object>[],
                      'authorized_farm_ids': <String>[],
                      'next_cursor': 'cursor',
                    },
              },
            ),
          );
          return;
        }
        if (writeStatus >= 400) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<Object>(
                requestOptions: options,
                statusCode: writeStatus,
                data: {
                  'error': {
                    'code': errorCode,
                    'message': 'Safe server message.',
                    'fields': <String, Object>{},
                  },
                },
              ),
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: writeStatus,
            data: {'data': <String, Object>{}, 'meta': <String, Object>{}},
          ),
        );
      },
    ),
  );
  return api;
}

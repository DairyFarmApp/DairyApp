import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/features/animals/data/animal_measurement_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_status_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_weight_models.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/animal_fixtures.dart';

void main() {
  late AppDatabase database;
  late List<RequestOptions> requests;
  late _MeasurementApiState apiState;
  late AnimalMeasurementRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    requests = [];
    apiState = _MeasurementApiState();
    repository = AnimalMeasurementRepository(
      database: database,
      api: _api(requests, apiState),
    );
  });

  tearDown(() => database.close());

  test('remote weight and status histories remain available offline', () async {
    apiState.lastPage = 2;
    final weights = await repository.getWeights(
      organizationId: organizationId,
      animalId: animalId,
    );
    final statuses = await repository.getStatusHistory(
      organizationId: organizationId,
      animalId: animalId,
    );
    expect(weights.isCached, isFalse);
    expect(weights.hasMore, isTrue);
    expect(statuses.isCached, isFalse);
    expect(statuses.hasMore, isTrue);
    expect(requests.first.queryParameters['page[size]'], 25);
    expect(requests.first.queryParameters['page[page]'], 1);

    apiState.offline = true;
    final cachedWeights = await repository.getWeights(
      organizationId: organizationId,
      animalId: animalId,
    );
    final cachedStatuses = await repository.getStatusHistory(
      organizationId: organizationId,
      animalId: animalId,
    );
    expect(cachedWeights.isCached, isTrue);
    expect(cachedWeights.items.single.id, weightId);
    expect(cachedStatuses.isCached, isTrue);
    expect(cachedStatuses.items.single.id, statusChangeId);
  });

  test('weight record and correction are online idempotent commands', () async {
    await _seedAnimal(database);
    final recorded = await repository.recordWeight(
      animalId,
      AnimalWeightDraft(
        farmId: farmId,
        value: '500.000000',
        unit: 'kg',
        observedAt: DateTime.utc(2026, 7, 23, 8),
        source: 'scale',
      ),
    );
    final corrected = await repository.correctWeight(
      recorded,
      const AnimalWeightCorrectionDraft(
        value: '501.000000',
        unit: 'kg',
        correctionReason: 'Verified paper log.',
      ),
    );

    expect(recorded.id, weightId);
    expect(corrected.id, correctedWeightId);
    expect(
      requests
          .where((request) => request.method == 'POST')
          .every((request) => request.headers['Idempotency-Key'] != null),
      isTrue,
    );
    expect(
      (requests.last.data as Map<String, dynamic>)['correction_reason'],
      'Verified paper log.',
    );
    expect(
      (requests
              .firstWhere(
                (request) =>
                    request.method == 'POST' &&
                    request.path.endsWith('/animals/$animalId/weights'),
              )
              .data
          as Map<String, dynamic>)['farm_id'],
      farmId,
    );
    final original = await (database.select(
      database.localAnimalWeights,
    )..where((row) => row.id.equals(weightId))).getSingle();
    expect(original.isSuperseded, isTrue);
    expect(original.supersededByWeightId, correctedWeightId);
    final animal = await (database.select(
      database.localAnimals,
    )..where((row) => row.id.equals(animalId))).getSingle();
    expect(animal.latestWeightId, correctedWeightId);
    expect(animal.latestWeightKg, '501.000000');
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });

  test(
    'status change updates the cached animal projection without outbox',
    () async {
      await _seedAnimal(database);

      final change = await repository.changeStatus(
        animalId,
        AnimalStatusChangeDraft(
          newStatus: 'inactive',
          effectiveAt: DateTime.utc(2026, 7, 23, 8),
          reason: 'Temporary operational hold.',
          version: 1,
        ),
      );

      expect(change.newStatus, 'inactive');
      final animal = await (database.select(
        database.localAnimals,
      )..where((row) => row.id.equals(animalId))).getSingle();
      expect(animal.operationalStatus, 'inactive');
      expect(animal.version, 2);
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    },
  );
}

final class _MeasurementApiState {
  bool offline = false;
  int lastPage = 1;
}

ApiClient _api(List<RequestOptions> requests, _MeasurementApiState state) {
  final dio = Dio();
  final api = ApiClient(
    config: EnvironmentConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: Uri.parse('http://example.test/api/v1'),
    ),
    readAccessToken: () async => 'token',
    dio: dio,
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        if (state.offline) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              error: 'offline',
            ),
          );
          return;
        }
        Object data;
        if (options.path.endsWith('/weights') && options.method == 'GET') {
          data = {
            'data': [weightJson()],
            'meta': {
              'pagination': {
                'current_page': options.queryParameters['page[page]'],
                'last_page': state.lastPage,
              },
            },
          };
        } else if (options.path.endsWith('/status-history')) {
          data = {
            'data': [statusChangeJson()],
            'meta': {
              'pagination': {
                'current_page': options.queryParameters['page[page]'],
                'last_page': state.lastPage,
              },
            },
          };
        } else if (options.path.contains('/correct')) {
          data = {
            'data': weightJson(
              id: correctedWeightId,
              enteredValue: '501.000000',
              normalizedKg: '501.000000',
              supersedesWeightId: weightId,
              correctionReason: 'Verified paper log.',
            ),
          };
        } else if (options.path.endsWith('/status-changes')) {
          data = {'data': statusChangeJson()};
        } else {
          data = {'data': weightJson()};
        }
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: options.method == 'POST' ? 201 : 200,
            data: data,
          ),
        );
      },
    ),
  );
  return api;
}

Future<void> _seedAnimal(AppDatabase database) async {
  final now = DateTime.utc(2026, 7, 23);
  await database
      .into(database.localAnimals)
      .insert(
        LocalAnimalsCompanion.insert(
          id: animalId,
          organizationId: organizationId,
          animalNumber: 'AN-000001',
          speciesId: speciesId,
          speciesName: 'Cattle',
          breedId: breedId,
          breedName: 'Sahiwal',
          sex: 'female',
          lifeStage: 'adult',
          currentFarmId: farmId,
          currentFarmName: 'North Farm',
          currentShedId: shedId,
          currentShedName: 'Main Shed',
          origin: 'born_on_farm',
          operationalStatus: 'active',
          serverUpdatedAt: now,
          cachedAt: now,
        ),
      );
}

import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/features/animals/data/animal_movement_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_movement_models.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/animal_fixtures.dart';

void main() {
  late AppDatabase database;
  late List<RequestOptions> requests;
  late _MovementApiState apiState;
  late AnimalMovementRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    requests = [];
    apiState = _MovementApiState();
    repository = AnimalMovementRepository(
      database: database,
      api: _api(requests, apiState),
    );
  });

  tearDown(() => database.close());

  test(
    'remote history is cached and displayed when the API is offline',
    () async {
      final remote = await repository.getMovements(
        organizationId: organizationId,
        animalId: animalId,
      );
      expect(remote.items, hasLength(1));
      expect(remote.isCached, isFalse);

      apiState.offline = true;
      final cached = await repository.getMovements(
        organizationId: organizationId,
        animalId: animalId,
      );
      expect(cached.items.single.id, movementId);
      expect(cached.isCached, isTrue);
    },
  );

  test('movement request sends source snapshot and idempotency key', () async {
    final movement = await repository.requestMovement(
      animalId,
      AnimalMovementDraft(
        sourceFarmId: farmId,
        sourceShedId: shedId,
        sourceAnimalGroupId: groupId,
        destinationFarmId: destinationFarmId,
        destinationShedId: destinationShedId,
        destinationAnimalGroupId: destinationGroupId,
        requestedEffectiveAt: DateTime.utc(2026, 7, 23, 9),
        reason: 'Routine relocation',
      ),
    );

    final request = requests.single;
    expect(request.path, '/animals/$animalId/movements');
    expect(request.headers['Idempotency-Key'], isNotEmpty);
    expect((request.data as Map<String, dynamic>)['source_farm_id'], farmId);
    expect(movement.status, 'pending');
  });

  test('approve reject and cancel use online idempotent decisions', () async {
    final pending = movementFixture();
    final approved = await repository.approve(pending);
    final rejected = await repository.reject(pending, 'Invalid destination');
    final cancelled = await repository.cancel(pending, 'Entered in error');

    expect(approved.status, 'approved');
    expect(rejected.status, 'rejected');
    expect(cancelled.status, 'cancelled');
    expect(
      requests.every((request) => request.headers['Idempotency-Key'] != null),
      isTrue,
    );
    expect(requests.singleWhere((item) => item.path.endsWith('/reject')).data, {
      'version': 1,
      'reason': 'Invalid destination',
    });
  });

  test('movement API conflicts are exposed as safe typed errors', () async {
    apiState.conflict = true;

    await expectLater(
      repository.approve(movementFixture()),
      throwsA(
        isA<ConflictException>().having(
          (error) => error.code,
          'code',
          'STALE_MOVEMENT',
        ),
      ),
    );
  });
}

final class _MovementApiState {
  bool offline = false;
  bool conflict = false;
}

ApiClient _api(List<RequestOptions> requests, _MovementApiState state) {
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
        if (state.conflict) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<Object>(
                requestOptions: options,
                statusCode: 409,
                data: {
                  'error': {
                    'code': 'STALE_MOVEMENT',
                    'message': 'The animal already moved.',
                    'fields': <String, Object>{},
                  },
                },
              ),
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
        final status = options.path.endsWith('/approve')
            ? 'approved'
            : options.path.endsWith('/reject')
            ? 'rejected'
            : options.path.endsWith('/cancel')
            ? 'cancelled'
            : 'pending';
        final body = movementJson(
          status: status,
          version: status == 'pending' ? 1 : 2,
        );
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: options.method == 'POST' ? 201 : 200,
            data: options.method == 'GET' && options.path.endsWith('/movements')
                ? {
                    'data': [body],
                    'meta': {
                      'pagination': {
                        'current_page': 1,
                        'last_page': 1,
                        'page_size': 100,
                        'total': 1,
                      },
                    },
                  }
                : {'data': body, 'meta': <String, Object>{}},
          ),
        );
      },
    ),
  );
  return api;
}

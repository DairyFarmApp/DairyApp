import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/features/animals/data/animal_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/animal_fixtures.dart';

void main() {
  late AppDatabase database;
  late List<RequestOptions> requests;
  late AnimalRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    requests = [];
    repository = AnimalRepository(database: database, api: _api(requests));
  });

  tearDown(() => database.close());

  test(
    'refresh caches animals and local search respects archive state',
    () async {
      final refreshed = await repository.refreshAnimals(
        organizationId: organizationId,
        filters: const AnimalFilters(),
      );

      expect(refreshed.single.name, 'Gulabo');
      expect(
        await repository
            .watchCachedAnimals(
              organizationId: organizationId,
              filters: const AnimalFilters(search: 'gul'),
            )
            .first,
        hasLength(1),
      );
      expect(
        await repository
            .watchCachedAnimals(
              organizationId: organizationId,
              filters: const AnimalFilters(archiveState: 'archived'),
            )
            .first,
        isEmpty,
      );
    },
  );

  test('online create sends an idempotency key and updates cache', () async {
    final animal = await repository.createAnimal(_draft());

    final request = requests.singleWhere((item) => item.method == 'POST');
    expect(request.path, '/animals');
    expect(request.headers['Idempotency-Key'], isNotEmpty);
    expect(animal.animalNumber, 'AN-000001');
    expect(
      await repository
          .watchCachedAnimals(
            organizationId: organizationId,
            filters: const AnimalFilters(),
          )
          .first,
      hasLength(1),
    );
  });

  test(
    'ordinary edit omits protected identifiers and all location fields',
    () async {
      final updated = await repository.updateAnimal(
        animalFixture(),
        _draft(),
        canManageIdentifiers: false,
      );

      final request = requests.singleWhere((item) => item.method == 'PATCH');
      final payload = request.data! as Map<String, dynamic>;
      expect(payload, isNot(contains('animal_number')));
      expect(payload, isNot(contains('ear_tag_number')));
      expect(payload, isNot(contains('rfid_number')));
      expect(payload, isNot(contains('current_farm_id')));
      expect(payload, isNot(contains('current_shed_id')));
      expect(payload['version'], 1);
      expect(updated.version, 2);
    },
  );

  test('archive and restore use versioned online actions', () async {
    final archived = await repository.archiveAnimal(animalFixture());
    final restored = await repository.restoreAnimal(archived);

    final delete = requests.singleWhere((item) => item.method == 'DELETE');
    expect(delete.path, '/animals/$animalId');
    expect(delete.data, {'version': 1});
    final restore = requests.lastWhere((item) => item.method == 'POST');
    expect(restore.path, '/animals/$animalId/restore');
    expect(restore.data, {'version': 2});
    expect(restored.isArchived, isFalse);
  });

  test('breed and group management use online versioned endpoints', () async {
    final breed = await repository.createBreed(
      speciesId: speciesId,
      code: 'SAHIWAL',
      name: 'Sahiwal',
    );
    final updatedBreed = await repository.updateBreed(
      breed,
      code: breed.code,
      name: breed.name,
      isActive: false,
    );
    await repository.archiveBreed(updatedBreed);
    final group = await repository.createGroup(
      farmId: farmId,
      defaultShedId: shedId,
      code: 'MAIN-HERD',
      name: 'Main Herd',
    );
    final updatedGroup = await repository.updateGroup(
      group,
      defaultShedId: null,
      code: group.code,
      name: group.name,
      isActive: false,
    );
    await repository.archiveGroup(updatedGroup);

    expect(
      requests
          .where((item) => item.path == '/animal-breeds')
          .single
          .headers['Idempotency-Key'],
      isNotEmpty,
    );
    expect(
      requests
          .where((item) => item.path == '/animal-groups')
          .single
          .headers['Idempotency-Key'],
      isNotEmpty,
    );
    expect(
      requests.any(
        (item) =>
            item.method == 'DELETE' && item.path == '/animal-breeds/$breedId',
      ),
      isTrue,
    );
    expect(
      requests.any(
        (item) =>
            item.method == 'DELETE' && item.path == '/animal-groups/$groupId',
      ),
      isTrue,
    );
  });
}

AnimalDraft _draft() => const AnimalDraft(
  animalNumber: 'CUSTOM-1',
  earTagNumber: 'EAR-001',
  rfidNumber: 'RFID001',
  name: 'Gulabo',
  speciesId: speciesId,
  breedId: breedId,
  sex: 'female',
  lifeStage: 'adult',
  currentFarmId: farmId,
  currentShedId: shedId,
  currentAnimalGroupId: groupId,
  origin: 'born_on_farm',
);

ApiClient _api(List<RequestOptions> requests) {
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
        Map<String, dynamic> body;
        if (options.path.startsWith('/animal-breeds')) {
          body = {
            'id': breedId,
            'organization_id': organizationId,
            'species_id': speciesId,
            'code': 'SAHIWAL',
            'name': 'Sahiwal',
            'description': null,
            'is_active': options.method != 'PATCH',
            'version': options.method == 'PATCH' ? 2 : 1,
            'is_archived': options.method == 'DELETE',
          };
        } else if (options.path.startsWith('/animal-groups')) {
          body = {
            'id': groupId,
            'organization_id': organizationId,
            'farm_id': farmId,
            'default_shed_id': shedId,
            'code': 'MAIN-HERD',
            'name': 'Main Herd',
            'description': null,
            'is_active': options.method != 'PATCH',
            'version': options.method == 'PATCH' ? 2 : 1,
            'is_archived': options.method == 'DELETE',
          };
        } else if (options.method == 'PATCH') {
          body = animalJson(version: 2);
        } else if (options.method == 'DELETE') {
          body = animalJson(archived: true, version: 2);
        } else if (options.path.endsWith('/restore')) {
          body = animalJson(version: 3);
        } else {
          body = animalJson();
        }
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: options.method == 'POST' ? 201 : 200,
            data: options.method == 'GET' && options.path == '/animals'
                ? {
                    'data': [body],
                    'meta': {
                      'pagination': {
                        'current_page': 1,
                        'last_page': 1,
                        'page_size': 50,
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

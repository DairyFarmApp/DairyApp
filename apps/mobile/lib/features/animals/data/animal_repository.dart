import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_weight_models.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class AnimalReferenceData {
  const AnimalReferenceData({
    required this.species,
    required this.breeds,
    required this.groups,
    required this.farms,
    required this.sheds,
    required this.animals,
  });

  final List<AnimalSpecies> species;
  final List<AnimalBreed> breeds;
  final List<AnimalGroup> groups;
  final List<LocalFarm> farms;
  final List<LocalShed> sheds;
  final List<Animal> animals;
}

final class AnimalRepository {
  AnimalRepository({
    required AppDatabase database,
    required ApiClient api,
    Uuid uuid = const Uuid(),
  }) : _database = database,
       _api = api,
       _uuid = uuid;

  final AppDatabase _database;
  final ApiClient _api;
  final Uuid _uuid;

  Stream<List<Animal>> watchCachedAnimals({
    required String organizationId,
    required AnimalFilters filters,
  }) => _database
      .watchAnimals(
        organizationId: organizationId,
        farmId: filters.farmId,
        search: filters.search,
        speciesId: filters.speciesId,
        breedId: filters.breedId,
        sex: filters.sex,
        lifeStage: filters.lifeStage,
        shedId: filters.shedId,
        groupId: filters.groupId,
        operationalStatus: filters.operationalStatus,
        archiveState: filters.archiveState,
      )
      .map((rows) => rows.map(_fromLocal).toList(growable: false));

  Future<List<Animal>> refreshAnimals({
    required String organizationId,
    required AnimalFilters filters,
  }) async {
    final body = await _api.getJson('/animals', query: filters.toQuery());
    final items = _maps(body['data']).map(Animal.fromJson).toList();
    await _database.transaction(() async {
      for (final animal in items) {
        await _upsertAnimal(animal);
      }
    });
    return items;
  }

  Future<Animal> getAnimal(String id) async {
    try {
      final body = await _api.getJson('/animals/$id');
      final animal = Animal.fromJson(body['data'] as Map<String, dynamic>);
      await _upsertAnimal(animal);
      return animal;
    } on NetworkException {
      return _cachedAnimal(id);
    } on TransientServerException {
      return _cachedAnimal(id);
    }
  }

  Future<Animal> createAnimal(AnimalDraft draft) async {
    final body = await _api.postJson(
      '/animals',
      data: draft.toJson(),
      idempotencyKey: _uuid.v7(),
    );
    final animal = Animal.fromJson(body['data'] as Map<String, dynamic>);
    await _upsertAnimal(animal);
    return animal;
  }

  Future<Animal> updateAnimal(
    Animal animal,
    AnimalDraft draft, {
    required bool canManageIdentifiers,
  }) async {
    final payload = draft.toJson(
      includeLocation: false,
      includeIdentifiers: canManageIdentifiers,
      includeOperationalStatus: false,
    )..['version'] = animal.version;
    final body = await _api.patchJson('/animals/${animal.id}', data: payload);
    final updated = Animal.fromJson(body['data'] as Map<String, dynamic>);
    await _upsertAnimal(updated);
    return updated;
  }

  Future<Animal> archiveAnimal(Animal animal) async {
    final body = await _api.deleteJson(
      '/animals/${animal.id}',
      data: {'version': animal.version},
    );
    final archived = Animal.fromJson(body['data'] as Map<String, dynamic>);
    await _upsertAnimal(archived);
    return archived;
  }

  Future<Animal> restoreAnimal(Animal animal) async {
    final body = await _api.postJson(
      '/animals/${animal.id}/restore',
      data: {'version': animal.version},
    );
    final restored = Animal.fromJson(body['data'] as Map<String, dynamic>);
    await _upsertAnimal(restored);
    return restored;
  }

  Future<AnimalReferenceData> loadReferences(String organizationId) async {
    final responses = await Future.wait([
      _api.getJson('/animal-species'),
      _api.getJson(
        '/animal-breeds',
        query: {'filter[archive_state]': 'all', 'page[size]': 100},
      ),
      _api.getJson(
        '/animal-groups',
        query: {'filter[archive_state]': 'all', 'page[size]': 100},
      ),
      _api.getJson(
        '/animals',
        query: {'filter[archive_state]': 'all', 'page[size]': 100},
      ),
    ]);
    final species = _maps(
      responses[0]['data'],
    ).map(AnimalSpecies.fromJson).toList();
    final breeds = _maps(
      responses[1]['data'],
    ).map(AnimalBreed.fromJson).toList();
    final groups = _maps(
      responses[2]['data'],
    ).map(AnimalGroup.fromJson).toList();
    final animals = _maps(responses[3]['data']).map(Animal.fromJson).toList();
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      for (final item in species) {
        await _database
            .into(_database.localAnimalSpecies)
            .insertOnConflictUpdate(
              LocalAnimalSpeciesCompanion.insert(
                id: item.id,
                code: item.code,
                name: item.name,
                isActive: Value(item.isActive),
                serverUpdatedAt: now,
                cachedAt: now,
              ),
            );
      }
      for (final item in breeds) {
        await _database
            .into(_database.localAnimalBreeds)
            .insertOnConflictUpdate(
              LocalAnimalBreedsCompanion.insert(
                id: item.id,
                organizationId: item.organizationId,
                speciesId: item.speciesId,
                code: item.code,
                name: item.name,
                description: Value(item.description),
                isActive: Value(item.isActive),
                version: Value(item.version),
                serverUpdatedAt: now,
                cachedAt: now,
                isArchived: Value(item.isArchived),
              ),
            );
      }
      for (final item in groups) {
        await _database
            .into(_database.localAnimalGroups)
            .insertOnConflictUpdate(
              LocalAnimalGroupsCompanion.insert(
                id: item.id,
                organizationId: item.organizationId,
                farmId: item.farmId,
                defaultShedId: Value(item.defaultShedId),
                code: item.code,
                name: item.name,
                description: Value(item.description),
                isActive: Value(item.isActive),
                version: Value(item.version),
                serverUpdatedAt: now,
                cachedAt: now,
                isArchived: Value(item.isArchived),
              ),
            );
      }
      for (final animal in animals) {
        await _upsertAnimal(animal);
      }
    });
    final farms =
        await (_database.select(_database.localFarms)..where(
              (row) =>
                  row.organizationId.equals(organizationId) &
                  row.isDeleted.equals(false),
            ))
            .get();
    final sheds =
        await (_database.select(_database.localSheds)..where(
              (row) =>
                  row.organizationId.equals(organizationId) &
                  row.isDeleted.equals(false),
            ))
            .get();
    return AnimalReferenceData(
      species: species,
      breeds: breeds,
      groups: groups,
      farms: farms,
      sheds: sheds,
      animals: animals,
    );
  }

  Future<AnimalBreed> createBreed({
    required String speciesId,
    required String code,
    required String name,
    String? description,
  }) async {
    final body = await _api.postJson(
      '/animal-breeds',
      data: {
        'species_id': speciesId,
        'code': code,
        'name': name,
        'description': description,
      },
      idempotencyKey: _uuid.v7(),
    );
    return AnimalBreed.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<AnimalBreed> updateBreed(
    AnimalBreed breed, {
    required String code,
    required String name,
    String? description,
    required bool isActive,
  }) async {
    final body = await _api.patchJson(
      '/animal-breeds/${breed.id}',
      data: {
        'code': code,
        'name': name,
        'description': description,
        'is_active': isActive,
        'version': breed.version,
      },
    );
    return AnimalBreed.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> archiveBreed(AnimalBreed breed) async {
    await _api.deleteJson(
      '/animal-breeds/${breed.id}',
      data: {'version': breed.version},
    );
  }

  Future<AnimalGroup> createGroup({
    required String farmId,
    String? defaultShedId,
    required String code,
    required String name,
    String? description,
  }) async {
    final body = await _api.postJson(
      '/animal-groups',
      data: {
        'farm_id': farmId,
        'default_shed_id': defaultShedId,
        'code': code,
        'name': name,
        'description': description,
      },
      idempotencyKey: _uuid.v7(),
    );
    return AnimalGroup.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<AnimalGroup> updateGroup(
    AnimalGroup group, {
    String? defaultShedId,
    required String code,
    required String name,
    String? description,
    required bool isActive,
  }) async {
    final body = await _api.patchJson(
      '/animal-groups/${group.id}',
      data: {
        'default_shed_id': defaultShedId,
        'code': code,
        'name': name,
        'description': description,
        'is_active': isActive,
        'version': group.version,
      },
    );
    return AnimalGroup.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> archiveGroup(AnimalGroup group) async {
    await _api.deleteJson(
      '/animal-groups/${group.id}',
      data: {'version': group.version},
    );
  }

  Future<Animal> _cachedAnimal(String id) async {
    final row =
        await (_database.select(_database.localAnimals)..where(
              (item) => item.id.equals(id) & item.isAccessible.equals(true),
            ))
            .getSingleOrNull();
    if (row == null) {
      throw const NetworkException(
        'The animal is unavailable offline on this device.',
      );
    }
    return _fromLocal(row);
  }

  Future<void> _upsertAnimal(Animal animal) => _database
      .into(_database.localAnimals)
      .insertOnConflictUpdate(
        LocalAnimalsCompanion.insert(
          id: animal.id,
          organizationId: animal.organizationId,
          animalNumber: animal.animalNumber,
          earTagNumber: Value(animal.earTagNumber),
          rfidNumber: Value(animal.rfidNumber),
          name: Value(animal.name),
          registrationNumber: Value(animal.registrationNumber),
          speciesId: animal.speciesId,
          speciesName: animal.speciesName,
          breedId: animal.breedId,
          breedName: animal.breedName,
          sex: animal.sex,
          lifeStage: animal.lifeStage,
          dateOfBirth: Value(animal.dateOfBirth),
          isDateOfBirthEstimated: Value(animal.isDateOfBirthEstimated),
          colour: Value(animal.colour),
          identifyingMarks: Value(animal.identifyingMarks),
          currentFarmId: animal.currentFarmId,
          currentFarmName: animal.currentFarmName,
          currentShedId: animal.currentShedId,
          currentShedName: animal.currentShedName,
          currentAnimalGroupId: Value(animal.currentAnimalGroupId),
          currentAnimalGroupName: Value(animal.currentAnimalGroupName),
          motherAnimalId: Value(animal.motherAnimalId),
          motherAnimalNumber: Value(animal.motherAnimalNumber),
          fatherAnimalId: Value(animal.fatherAnimalId),
          fatherAnimalNumber: Value(animal.fatherAnimalNumber),
          externalSireReference: Value(animal.externalSireReference),
          origin: animal.origin,
          acquisitionDate: Value(animal.acquisitionDate),
          sourceDescription: Value(animal.sourceDescription),
          notes: Value(animal.notes),
          operationalStatus: animal.operationalStatus,
          latestWeightId: Value(animal.latestWeight?.id),
          latestWeightKg: Value(animal.latestWeight?.normalizedKg),
          latestWeightObservedAt: Value(animal.latestWeight?.observedAt),
          version: Value(animal.version),
          serverUpdatedAt: animal.serverUpdatedAt,
          cachedAt: DateTime.now().toUtc(),
          isArchived: Value(animal.isArchived),
          isAccessible: const Value(true),
        ),
      );

  Animal _fromLocal(LocalAnimal row) => Animal(
    id: row.id,
    organizationId: row.organizationId,
    animalNumber: row.animalNumber,
    earTagNumber: row.earTagNumber,
    rfidNumber: row.rfidNumber,
    name: row.name,
    registrationNumber: row.registrationNumber,
    speciesId: row.speciesId,
    speciesName: row.speciesName,
    breedId: row.breedId,
    breedName: row.breedName,
    sex: row.sex,
    lifeStage: row.lifeStage,
    dateOfBirth: row.dateOfBirth,
    isDateOfBirthEstimated: row.isDateOfBirthEstimated,
    colour: row.colour,
    identifyingMarks: row.identifyingMarks,
    currentFarmId: row.currentFarmId,
    currentFarmName: row.currentFarmName,
    currentShedId: row.currentShedId,
    currentShedName: row.currentShedName,
    currentAnimalGroupId: row.currentAnimalGroupId,
    currentAnimalGroupName: row.currentAnimalGroupName,
    motherAnimalId: row.motherAnimalId,
    motherAnimalNumber: row.motherAnimalNumber,
    fatherAnimalId: row.fatherAnimalId,
    fatherAnimalNumber: row.fatherAnimalNumber,
    externalSireReference: row.externalSireReference,
    origin: row.origin,
    acquisitionDate: row.acquisitionDate,
    sourceDescription: row.sourceDescription,
    notes: row.notes,
    operationalStatus: row.operationalStatus,
    latestWeight:
        row.latestWeightId == null ||
            row.latestWeightKg == null ||
            row.latestWeightObservedAt == null
        ? null
        : AnimalWeight(
            id: row.latestWeightId!,
            organizationId: row.organizationId,
            farmId: row.currentFarmId,
            farmName: row.currentFarmName,
            animalId: row.id,
            animalNumber: row.animalNumber,
            enteredValue: row.latestWeightKg!,
            enteredUnit: 'kg',
            normalizedKg: row.latestWeightKg!,
            observedAt: row.latestWeightObservedAt!,
            source: 'cached_projection',
            recordedBy: '',
            recordedByName: '',
            isSuperseded: false,
            serverUpdatedAt: row.serverUpdatedAt,
          ),
    version: row.version,
    isArchived: row.isArchived,
    serverUpdatedAt: row.serverUpdatedAt,
  );

  List<Map<String, dynamic>> _maps(Object? value) =>
      (value as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
}

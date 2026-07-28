import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/animal_fixtures.dart';

void main() {
  test(
    'animal serialization preserves registry terminology and timestamps',
    () {
      final animal = Animal.fromJson(animalJson());

      expect(animal.animalNumber, 'AN-000001');
      expect(animal.speciesName, 'Cattle');
      expect(animal.sex, 'female');
      expect(animal.lifeStage, 'adult');
      expect(animal.operationalStatus, 'active');
      expect(animal.isArchived, isFalse);
      expect(animal.dateOfBirth, DateTime.utc(2022, 1, 2));
    },
  );

  test(
    'draft excludes protected identifiers and location during ordinary edit',
    () {
      const draft = AnimalDraft(
        animalNumber: 'CUSTOM-1',
        earTagNumber: 'EAR-1',
        rfidNumber: 'RFID-1',
        speciesId: speciesId,
        breedId: breedId,
        sex: 'female',
        lifeStage: 'adult',
        currentFarmId: farmId,
        currentShedId: shedId,
        origin: 'born_on_farm',
      );

      final json = draft.toJson(
        includeLocation: false,
        includeIdentifiers: false,
        includeOperationalStatus: false,
      );

      expect(json, isNot(contains('animal_number')));
      expect(json, isNot(contains('ear_tag_number')));
      expect(json, isNot(contains('rfid_number')));
      expect(json, isNot(contains('current_farm_id')));
      expect(json, isNot(contains('current_shed_id')));
      expect(json, isNot(contains('operational_status')));
    },
  );

  test('filters serialize only bounded API query parameters', () {
    const filters = AnimalFilters(
      search: 'AN-1',
      speciesId: speciesId,
      farmId: farmId,
      archiveState: 'archived',
    );

    expect(
      filters.toQuery(pageSize: 25),
      containsPair('filter[search]', 'AN-1'),
    );
    expect(
      filters.toQuery(pageSize: 25),
      containsPair('filter[archive_state]', 'archived'),
    );
    expect(filters.toQuery(pageSize: 25), containsPair('page[size]', 25));
  });
}

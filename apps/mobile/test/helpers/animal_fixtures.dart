import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/features/animals/data/animal_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';

const organizationId = '018f0000-0000-7000-8000-000000000010';
const farmId = '018f0000-0000-7000-8000-000000000020';
const shedId = '018f0000-0000-7000-8000-000000000030';
const speciesId = '018f0000-0000-7000-8000-000000000040';
const breedId = '018f0000-0000-7000-8000-000000000050';
const groupId = '018f0000-0000-7000-8000-000000000060';
const animalId = '018f0000-0000-7000-8000-000000000070';

Map<String, dynamic> animalJson({
  String id = animalId,
  String number = 'AN-000001',
  String sex = 'female',
  String status = 'active',
  bool archived = false,
  int version = 1,
}) => {
  'id': id,
  'organization_id': organizationId,
  'animal_number': number,
  'ear_tag_number': 'EAR-001',
  'rfid_number': 'RFID001',
  'name': 'Gulabo',
  'registration_number': 'REG-001',
  'species_id': speciesId,
  'species_name': 'Cattle',
  'breed_id': breedId,
  'breed_name': 'Sahiwal',
  'sex': sex,
  'life_stage': 'adult',
  'date_of_birth': '2022-01-02',
  'is_date_of_birth_estimated': false,
  'colour': 'Red',
  'identifying_marks': 'White forehead',
  'current_farm_id': farmId,
  'current_farm_name': 'North Farm',
  'current_shed_id': shedId,
  'current_shed_name': 'Main Shed',
  'current_animal_group_id': groupId,
  'current_animal_group_name': 'Main Herd',
  'mother_animal_id': null,
  'mother_animal_number': null,
  'father_animal_id': null,
  'father_animal_number': null,
  'external_sire_reference': null,
  'origin': 'born_on_farm',
  'acquisition_date': null,
  'source_description': null,
  'notes': 'Calm temperament',
  'operational_status': status,
  'version': version,
  'is_archived': archived,
  'updated_at': '2026-07-23T10:00:00Z',
};

Animal animalFixture({
  String id = animalId,
  String number = 'AN-000001',
  bool archived = false,
}) => Animal.fromJson(animalJson(id: id, number: number, archived: archived));

AnimalReferenceData referenceFixture() => AnimalReferenceData(
  species: const [
    AnimalSpecies(
      id: speciesId,
      code: 'CATTLE',
      name: 'Cattle',
      isActive: true,
    ),
  ],
  breeds: const [
    AnimalBreed(
      id: breedId,
      organizationId: organizationId,
      speciesId: speciesId,
      code: 'SAHIWAL',
      name: 'Sahiwal',
      isActive: true,
      version: 1,
      isArchived: false,
    ),
  ],
  groups: const [
    AnimalGroup(
      id: groupId,
      organizationId: organizationId,
      farmId: farmId,
      defaultShedId: shedId,
      code: 'MAIN-HERD',
      name: 'Main Herd',
      isActive: true,
      version: 1,
      isArchived: false,
    ),
  ],
  farms: [
    LocalFarm(
      id: farmId,
      organizationId: organizationId,
      name: 'North Farm',
      timezone: 'UTC',
      version: 1,
      serverUpdatedAt: DateTime.utc(2026, 7, 23),
      isDeleted: false,
    ),
  ],
  sheds: [
    LocalShed(
      id: shedId,
      organizationId: organizationId,
      farmId: farmId,
      name: 'Main Shed',
      version: 1,
      serverUpdatedAt: DateTime.utc(2026, 7, 23),
      isDeleted: false,
    ),
  ],
  animals: [animalFixture()],
);

Future<void> seedFoundationCache(AppDatabase database) async {
  final now = DateTime.utc(2026, 7, 23);
  await database
      .into(database.localFarms)
      .insert(
        LocalFarmsCompanion.insert(
          id: farmId,
          organizationId: organizationId,
          name: 'North Farm',
          serverUpdatedAt: now,
        ),
      );
  await database
      .into(database.localSheds)
      .insert(
        LocalShedsCompanion.insert(
          id: shedId,
          organizationId: organizationId,
          farmId: farmId,
          name: 'Main Shed',
          serverUpdatedAt: now,
        ),
      );
}

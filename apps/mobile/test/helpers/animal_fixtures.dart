import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/features/animals/data/animal_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_movement_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_status_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_weight_models.dart';

const organizationId = '018f0000-0000-7000-8000-000000000010';
const farmId = '018f0000-0000-7000-8000-000000000020';
const shedId = '018f0000-0000-7000-8000-000000000030';
const speciesId = '018f0000-0000-7000-8000-000000000040';
const breedId = '018f0000-0000-7000-8000-000000000050';
const groupId = '018f0000-0000-7000-8000-000000000060';
const animalId = '018f0000-0000-7000-8000-000000000070';
const movementId = '018f0000-0000-7000-8000-000000000080';
const weightId = '018f0000-0000-7000-8000-000000000090';
const correctedWeightId = '018f0000-0000-7000-8000-000000000091';
const statusChangeId = '018f0000-0000-7000-8000-000000000092';
const destinationFarmId = '018f0000-0000-7000-8000-000000000021';
const destinationShedId = '018f0000-0000-7000-8000-000000000031';
const destinationGroupId = '018f0000-0000-7000-8000-000000000061';

Map<String, dynamic> animalJson({
  String id = animalId,
  String number = 'AN-000001',
  String sex = 'female',
  String status = 'active',
  bool archived = false,
  int version = 1,
  Map<String, dynamic>? latestWeight,
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
  'latest_weight': latestWeight,
  'version': version,
  'is_archived': archived,
  'updated_at': '2026-07-23T10:00:00Z',
};

Map<String, dynamic> weightJson({
  String id = weightId,
  String enteredValue = '500.000000',
  String enteredUnit = 'kg',
  String normalizedKg = '500.000000',
  bool superseded = false,
  String? supersedesWeightId,
  String? supersededByWeightId,
  String? correctionReason,
}) => {
  'id': id,
  'organization_id': organizationId,
  'farm_id': farmId,
  'farm_name': 'North Farm',
  'animal_id': animalId,
  'animal_number': 'AN-000001',
  'entered_value': enteredValue,
  'entered_unit': enteredUnit,
  'normalized_kg': normalizedKg,
  'observed_at': '2026-07-23T08:00:00Z',
  'source': 'scale',
  'notes': 'Routine measurement',
  'recorded_by': '018f0000-0000-7000-8000-000000000001',
  'recorded_by_name': 'Ayesha Khan',
  'supersedes_weight_id': supersedesWeightId,
  'superseded_by_weight_id': supersededByWeightId,
  'correction_reason': correctionReason,
  'is_superseded': superseded,
  'created_at': '2026-07-23T08:01:00Z',
  'updated_at': '2026-07-23T08:01:00Z',
};

AnimalWeight weightFixture({
  String id = weightId,
  bool superseded = false,
  String? supersedesWeightId,
  String? supersededByWeightId,
  String? correctionReason,
}) => AnimalWeight.fromJson(
  weightJson(
    id: id,
    superseded: superseded,
    supersedesWeightId: supersedesWeightId,
    supersededByWeightId: supersededByWeightId,
    correctionReason: correctionReason,
  ),
);

Map<String, dynamic> statusChangeJson({
  String id = statusChangeId,
  String previousStatus = 'active',
  String newStatus = 'inactive',
  int sequence = 1,
  int? animalVersion = 2,
}) => {
  'id': id,
  'organization_id': organizationId,
  'farm_id': farmId,
  'farm_name': 'North Farm',
  'animal_id': animalId,
  'animal_number': 'AN-000001',
  'previous_status': previousStatus,
  'new_status': newStatus,
  'effective_at': '2026-07-23T08:00:00Z',
  'reason': 'Operational status test.',
  'changed_by': '018f0000-0000-7000-8000-000000000001',
  'changed_by_name': 'Ayesha Khan',
  'sequence': sequence,
  'animal_version': animalVersion,
  'created_at': '2026-07-23T08:01:00Z',
  'updated_at': '2026-07-23T08:01:00Z',
};

AnimalStatusChange statusChangeFixture({
  String id = statusChangeId,
  String previousStatus = 'active',
  String newStatus = 'inactive',
  int sequence = 1,
}) => AnimalStatusChange.fromJson(
  statusChangeJson(
    id: id,
    previousStatus: previousStatus,
    newStatus: newStatus,
    sequence: sequence,
  ),
);

Animal animalFixture({
  String id = animalId,
  String number = 'AN-000001',
  bool archived = false,
}) => Animal.fromJson(animalJson(id: id, number: number, archived: archived));

Map<String, dynamic> movementJson({
  String id = movementId,
  String status = 'pending',
  bool approvalRequired = true,
  String requestedBy = '018f0000-0000-7000-8000-000000000002',
  int version = 1,
}) => {
  'id': id,
  'organization_id': organizationId,
  'animal_id': animalId,
  'animal_number': 'AN-000001',
  'source_farm_id': farmId,
  'source_farm_name': 'North Farm',
  'source_shed_id': shedId,
  'source_shed_name': 'Main Shed',
  'source_animal_group_id': groupId,
  'source_animal_group_name': 'Main Herd',
  'destination_farm_id': destinationFarmId,
  'destination_farm_name': 'South Farm',
  'destination_shed_id': destinationShedId,
  'destination_shed_name': 'Receiving Shed',
  'destination_animal_group_id': destinationGroupId,
  'destination_animal_group_name': 'Receiving Group',
  'requested_effective_at': '2026-07-23T09:00:00Z',
  'actual_effective_at': status == 'approved' ? '2026-07-23T10:00:00Z' : null,
  'reason': 'Routine herd relocation',
  'notes': 'Move after inspection.',
  'status': status,
  'approval_required': approvalRequired,
  'requested_by': requestedBy,
  'requested_by_name': 'Bilal Ahmed',
  'decided_by': status == 'pending'
      ? null
      : '018f0000-0000-7000-8000-000000000001',
  'decided_by_name': status == 'pending' ? null : 'Ayesha Khan',
  'decision_at': status == 'pending' ? null : '2026-07-23T10:00:00Z',
  'rejection_reason': status == 'rejected' ? 'Destination unavailable' : null,
  'cancellation_reason': status == 'cancelled'
      ? 'Request entered in error'
      : null,
  'version': version,
  'updated_at': '2026-07-23T10:00:00Z',
};

AnimalMovement movementFixture({
  String id = movementId,
  String status = 'pending',
  bool approvalRequired = true,
  String requestedBy = '018f0000-0000-7000-8000-000000000002',
  int version = 1,
}) => AnimalMovement.fromJson(
  movementJson(
    id: id,
    status: status,
    approvalRequired: approvalRequired,
    requestedBy: requestedBy,
    version: version,
  ),
);

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

AnimalReferenceData movementReferenceFixture() {
  final base = referenceFixture();
  return AnimalReferenceData(
    species: base.species,
    breeds: base.breeds,
    groups: [
      ...base.groups,
      const AnimalGroup(
        id: destinationGroupId,
        organizationId: organizationId,
        farmId: destinationFarmId,
        defaultShedId: destinationShedId,
        code: 'RECEIVING',
        name: 'Receiving Group',
        isActive: true,
        version: 1,
        isArchived: false,
      ),
    ],
    farms: [
      ...base.farms,
      LocalFarm(
        id: destinationFarmId,
        organizationId: organizationId,
        name: 'South Farm',
        timezone: 'UTC',
        version: 1,
        serverUpdatedAt: DateTime.utc(2026, 7, 23),
        isDeleted: false,
      ),
    ],
    sheds: [
      ...base.sheds,
      LocalShed(
        id: destinationShedId,
        organizationId: organizationId,
        farmId: destinationFarmId,
        name: 'Receiving Shed',
        version: 1,
        serverUpdatedAt: DateTime.utc(2026, 7, 23),
        isDeleted: false,
      ),
    ],
    animals: base.animals,
  );
}

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

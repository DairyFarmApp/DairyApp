import 'package:dairycare_mobile/features/animals/domain/animal_weight_models.dart';

final class AnimalSpecies {
  const AnimalSpecies({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
  });

  factory AnimalSpecies.fromJson(Map<String, dynamic> json) => AnimalSpecies(
    id: json['id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    isActive: json['is_active'] as bool? ?? true,
  );

  final String id;
  final String code;
  final String name;
  final bool isActive;
}

final class AnimalBreed {
  const AnimalBreed({
    required this.id,
    required this.organizationId,
    required this.speciesId,
    required this.code,
    required this.name,
    required this.isActive,
    required this.version,
    required this.isArchived,
    this.description,
  });

  factory AnimalBreed.fromJson(Map<String, dynamic> json) => AnimalBreed(
    id: json['id'] as String,
    organizationId: json['organization_id'] as String,
    speciesId: json['species_id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    isActive: json['is_active'] as bool? ?? true,
    version: json['version'] as int? ?? 1,
    isArchived: json['is_archived'] as bool? ?? false,
  );

  final String id;
  final String organizationId;
  final String speciesId;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
  final int version;
  final bool isArchived;
}

final class AnimalGroup {
  const AnimalGroup({
    required this.id,
    required this.organizationId,
    required this.farmId,
    required this.code,
    required this.name,
    required this.isActive,
    required this.version,
    required this.isArchived,
    this.defaultShedId,
    this.description,
  });

  factory AnimalGroup.fromJson(Map<String, dynamic> json) => AnimalGroup(
    id: json['id'] as String,
    organizationId: json['organization_id'] as String,
    farmId: json['farm_id'] as String,
    defaultShedId: json['default_shed_id'] as String?,
    code: json['code'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    isActive: json['is_active'] as bool? ?? true,
    version: json['version'] as int? ?? 1,
    isArchived: json['is_archived'] as bool? ?? false,
  );

  final String id;
  final String organizationId;
  final String farmId;
  final String? defaultShedId;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
  final int version;
  final bool isArchived;
}

final class Animal {
  const Animal({
    required this.id,
    required this.organizationId,
    required this.animalNumber,
    required this.speciesId,
    required this.speciesName,
    required this.breedId,
    required this.breedName,
    required this.sex,
    required this.lifeStage,
    required this.isDateOfBirthEstimated,
    required this.currentFarmId,
    required this.currentFarmName,
    required this.currentShedId,
    required this.currentShedName,
    required this.origin,
    required this.operationalStatus,
    required this.version,
    required this.isArchived,
    required this.serverUpdatedAt,
    this.earTagNumber,
    this.rfidNumber,
    this.name,
    this.registrationNumber,
    this.dateOfBirth,
    this.colour,
    this.identifyingMarks,
    this.currentAnimalGroupId,
    this.currentAnimalGroupName,
    this.motherAnimalId,
    this.motherAnimalNumber,
    this.fatherAnimalId,
    this.fatherAnimalNumber,
    this.externalSireReference,
    this.acquisitionDate,
    this.sourceDescription,
    this.notes,
    this.latestWeight,
  });

  factory Animal.fromJson(Map<String, dynamic> json) => Animal(
    id: json['id'] as String,
    organizationId: json['organization_id'] as String,
    animalNumber: json['animal_number'] as String,
    earTagNumber: json['ear_tag_number'] as String?,
    rfidNumber: json['rfid_number'] as String?,
    name: json['name'] as String?,
    registrationNumber: json['registration_number'] as String?,
    speciesId: json['species_id'] as String,
    speciesName: json['species_name'] as String? ?? '',
    breedId: json['breed_id'] as String,
    breedName: json['breed_name'] as String? ?? '',
    sex: json['sex'] as String,
    lifeStage: json['life_stage'] as String,
    dateOfBirth: _date(json['date_of_birth']),
    isDateOfBirthEstimated:
        json['is_date_of_birth_estimated'] as bool? ?? false,
    colour: json['colour'] as String?,
    identifyingMarks: json['identifying_marks'] as String?,
    currentFarmId: json['current_farm_id'] as String,
    currentFarmName: json['current_farm_name'] as String? ?? '',
    currentShedId: json['current_shed_id'] as String,
    currentShedName: json['current_shed_name'] as String? ?? '',
    currentAnimalGroupId: json['current_animal_group_id'] as String?,
    currentAnimalGroupName: json['current_animal_group_name'] as String?,
    motherAnimalId: json['mother_animal_id'] as String?,
    motherAnimalNumber: json['mother_animal_number'] as String?,
    fatherAnimalId: json['father_animal_id'] as String?,
    fatherAnimalNumber: json['father_animal_number'] as String?,
    externalSireReference: json['external_sire_reference'] as String?,
    origin: json['origin'] as String,
    acquisitionDate: _date(json['acquisition_date']),
    sourceDescription: json['source_description'] as String?,
    notes: json['notes'] as String?,
    latestWeight: json['latest_weight'] is Map<String, dynamic>
        ? AnimalWeight.fromJson(json['latest_weight'] as Map<String, dynamic>)
        : null,
    operationalStatus: json['operational_status'] as String,
    version: json['version'] as int? ?? 1,
    isArchived: json['is_archived'] as bool? ?? false,
    serverUpdatedAt:
        _date(json['updated_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
  );

  final String id;
  final String organizationId;
  final String animalNumber;
  final String? earTagNumber;
  final String? rfidNumber;
  final String? name;
  final String? registrationNumber;
  final String speciesId;
  final String speciesName;
  final String breedId;
  final String breedName;
  final String sex;
  final String lifeStage;
  final DateTime? dateOfBirth;
  final bool isDateOfBirthEstimated;
  final String? colour;
  final String? identifyingMarks;
  final String currentFarmId;
  final String currentFarmName;
  final String currentShedId;
  final String currentShedName;
  final String? currentAnimalGroupId;
  final String? currentAnimalGroupName;
  final String? motherAnimalId;
  final String? motherAnimalNumber;
  final String? fatherAnimalId;
  final String? fatherAnimalNumber;
  final String? externalSireReference;
  final String origin;
  final DateTime? acquisitionDate;
  final String? sourceDescription;
  final String? notes;
  final AnimalWeight? latestWeight;
  final String operationalStatus;
  final int version;
  final bool isArchived;
  final DateTime serverUpdatedAt;
}

final class AnimalDraft {
  const AnimalDraft({
    required this.speciesId,
    required this.breedId,
    required this.sex,
    required this.lifeStage,
    required this.currentFarmId,
    required this.currentShedId,
    required this.origin,
    this.animalNumber,
    this.earTagNumber,
    this.rfidNumber,
    this.name,
    this.registrationNumber,
    this.dateOfBirth,
    this.isDateOfBirthEstimated = false,
    this.colour,
    this.identifyingMarks,
    this.currentAnimalGroupId,
    this.motherAnimalId,
    this.fatherAnimalId,
    this.externalSireReference,
    this.acquisitionDate,
    this.sourceDescription,
    this.notes,
    this.operationalStatus = 'active',
  });

  final String? animalNumber;
  final String? earTagNumber;
  final String? rfidNumber;
  final String? name;
  final String? registrationNumber;
  final String speciesId;
  final String breedId;
  final String sex;
  final String lifeStage;
  final DateTime? dateOfBirth;
  final bool isDateOfBirthEstimated;
  final String? colour;
  final String? identifyingMarks;
  final String currentFarmId;
  final String currentShedId;
  final String? currentAnimalGroupId;
  final String? motherAnimalId;
  final String? fatherAnimalId;
  final String? externalSireReference;
  final String origin;
  final DateTime? acquisitionDate;
  final String? sourceDescription;
  final String? notes;
  final String operationalStatus;

  Map<String, dynamic> toJson({
    bool includeLocation = true,
    bool includeIdentifiers = true,
    bool includeOperationalStatus = true,
  }) => {
    if (includeIdentifiers &&
        animalNumber != null &&
        animalNumber!.trim().isNotEmpty)
      'animal_number': animalNumber,
    if (includeIdentifiers) 'ear_tag_number': _nullIfEmpty(earTagNumber),
    if (includeIdentifiers) 'rfid_number': _nullIfEmpty(rfidNumber),
    'name': _nullIfEmpty(name),
    'registration_number': _nullIfEmpty(registrationNumber),
    'species_id': speciesId,
    'breed_id': breedId,
    'sex': sex,
    'life_stage': lifeStage,
    'date_of_birth': _dateString(dateOfBirth),
    'is_date_of_birth_estimated': isDateOfBirthEstimated,
    'colour': _nullIfEmpty(colour),
    'identifying_marks': _nullIfEmpty(identifyingMarks),
    if (includeLocation) 'current_farm_id': currentFarmId,
    if (includeLocation) 'current_shed_id': currentShedId,
    if (includeLocation)
      'current_animal_group_id': _nullIfEmpty(currentAnimalGroupId),
    'mother_animal_id': _nullIfEmpty(motherAnimalId),
    'father_animal_id': _nullIfEmpty(fatherAnimalId),
    'external_sire_reference': _nullIfEmpty(externalSireReference),
    'origin': origin,
    'acquisition_date': _dateString(acquisitionDate),
    'source_description': _nullIfEmpty(sourceDescription),
    'notes': _nullIfEmpty(notes),
    if (includeOperationalStatus) 'operational_status': operationalStatus,
  };
}

final class AnimalFilters {
  const AnimalFilters({
    this.search = '',
    this.speciesId,
    this.breedId,
    this.sex,
    this.lifeStage,
    this.farmId,
    this.shedId,
    this.groupId,
    this.operationalStatus,
    this.archiveState = 'active',
  });

  final String search;
  final String? speciesId;
  final String? breedId;
  final String? sex;
  final String? lifeStage;
  final String? farmId;
  final String? shedId;
  final String? groupId;
  final String? operationalStatus;
  final String archiveState;

  AnimalFilters copyWith({
    String? search,
    String? speciesId,
    String? breedId,
    String? sex,
    String? lifeStage,
    String? farmId,
    String? shedId,
    String? groupId,
    String? operationalStatus,
    String? archiveState,
    bool clearSex = false,
    bool clearLifeStage = false,
    bool clearOperationalStatus = false,
    bool clearSpecies = false,
    bool clearBreed = false,
    bool clearFarm = false,
    bool clearShed = false,
    bool clearGroup = false,
  }) => AnimalFilters(
    search: search ?? this.search,
    speciesId: clearSpecies ? null : (speciesId ?? this.speciesId),
    breedId: clearBreed ? null : (breedId ?? this.breedId),
    sex: clearSex ? null : (sex ?? this.sex),
    lifeStage: clearLifeStage ? null : (lifeStage ?? this.lifeStage),
    farmId: clearFarm ? null : (farmId ?? this.farmId),
    shedId: clearShed ? null : (shedId ?? this.shedId),
    groupId: clearGroup ? null : (groupId ?? this.groupId),
    operationalStatus: clearOperationalStatus
        ? null
        : (operationalStatus ?? this.operationalStatus),
    archiveState: archiveState ?? this.archiveState,
  );

  Map<String, dynamic> toQuery({int pageSize = 50}) => {
    if (search.trim().isNotEmpty) 'filter[search]': search.trim(),
    if (speciesId != null) 'filter[species_id]': speciesId,
    if (breedId != null) 'filter[breed_id]': breedId,
    if (sex != null) 'filter[sex]': sex,
    if (lifeStage != null) 'filter[life_stage]': lifeStage,
    if (farmId != null) 'filter[farm_id]': farmId,
    if (shedId != null) 'filter[shed_id]': shedId,
    if (groupId != null) 'filter[group_id]': groupId,
    if (operationalStatus != null)
      'filter[operational_status]': operationalStatus,
    'filter[archive_state]': archiveState,
    'page[size]': pageSize,
  };
}

DateTime? _date(Object? value) {
  if (value is! String || value.isEmpty) return null;
  if (!value.contains('T')) {
    final parts = value.split('-').map(int.parse).toList(growable: false);
    return DateTime.utc(parts[0], parts[1], parts[2]);
  }
  return DateTime.parse(value).toUtc();
}

String? _dateString(DateTime? value) =>
    value?.toIso8601String().split('T').first;

String? _nullIfEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

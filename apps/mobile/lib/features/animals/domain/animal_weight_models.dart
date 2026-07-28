final class AnimalWeight {
  const AnimalWeight({
    required this.id,
    required this.organizationId,
    required this.farmId,
    required this.farmName,
    required this.animalId,
    required this.animalNumber,
    required this.enteredValue,
    required this.enteredUnit,
    required this.normalizedKg,
    required this.observedAt,
    required this.source,
    required this.recordedBy,
    required this.recordedByName,
    required this.isSuperseded,
    required this.serverUpdatedAt,
    this.notes,
    this.supersedesWeightId,
    this.supersededByWeightId,
    this.correctionReason,
  });

  factory AnimalWeight.fromJson(Map<String, dynamic> json) => AnimalWeight(
    id: json['id'] as String,
    organizationId: json['organization_id'] as String,
    farmId: json['farm_id'] as String,
    farmName: json['farm_name'] as String? ?? '',
    animalId: json['animal_id'] as String,
    animalNumber: json['animal_number'] as String? ?? '',
    enteredValue: json['entered_value'] as String,
    enteredUnit: json['entered_unit'] as String,
    normalizedKg: json['normalized_kg'] as String,
    observedAt: DateTime.parse(json['observed_at'] as String).toUtc(),
    source: json['source'] as String,
    notes: json['notes'] as String?,
    recordedBy: json['recorded_by'] as String,
    recordedByName: json['recorded_by_name'] as String? ?? '',
    supersedesWeightId: json['supersedes_weight_id'] as String?,
    supersededByWeightId: json['superseded_by_weight_id'] as String?,
    correctionReason: json['correction_reason'] as String?,
    isSuperseded: json['is_superseded'] as bool? ?? false,
    serverUpdatedAt:
        _weightDate(json['updated_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );

  final String id;
  final String organizationId;
  final String farmId;
  final String farmName;
  final String animalId;
  final String animalNumber;
  final String enteredValue;
  final String enteredUnit;
  final String normalizedKg;
  final DateTime observedAt;
  final String source;
  final String? notes;
  final String recordedBy;
  final String recordedByName;
  final String? supersedesWeightId;
  final String? supersededByWeightId;
  final String? correctionReason;
  final bool isSuperseded;
  final DateTime serverUpdatedAt;

  bool get isCorrection => supersedesWeightId != null;
}

final class AnimalWeightDraft {
  const AnimalWeightDraft({
    required this.farmId,
    required this.value,
    required this.unit,
    required this.observedAt,
    required this.source,
    this.notes,
  });

  final String farmId;
  final String value;
  final String unit;
  final DateTime observedAt;
  final String source;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'farm_id': farmId,
    'value': value.trim(),
    'unit': unit,
    'observed_at': observedAt.toUtc().toIso8601String(),
    'source': source,
    'notes': _weightNullIfEmpty(notes),
  };
}

final class AnimalWeightCorrectionDraft {
  const AnimalWeightCorrectionDraft({
    required this.value,
    required this.unit,
    required this.correctionReason,
    this.notes,
  });

  final String value;
  final String unit;
  final String correctionReason;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'value': value.trim(),
    'unit': unit,
    'correction_reason': correctionReason.trim(),
    'notes': _weightNullIfEmpty(notes),
  };
}

DateTime? _weightDate(Object? value) =>
    value is String && value.isNotEmpty ? DateTime.parse(value).toUtc() : null;

String? _weightNullIfEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

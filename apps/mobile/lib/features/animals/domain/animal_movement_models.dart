final class AnimalMovement {
  const AnimalMovement({
    required this.id,
    required this.organizationId,
    required this.animalId,
    required this.animalNumber,
    required this.sourceFarmId,
    required this.sourceFarmName,
    required this.sourceShedId,
    required this.sourceShedName,
    required this.destinationFarmId,
    required this.destinationFarmName,
    required this.destinationShedId,
    required this.destinationShedName,
    required this.requestedEffectiveAt,
    required this.reason,
    required this.status,
    required this.approvalRequired,
    required this.requestedBy,
    required this.requestedByName,
    required this.version,
    required this.serverUpdatedAt,
    this.sourceAnimalGroupId,
    this.sourceAnimalGroupName,
    this.destinationAnimalGroupId,
    this.destinationAnimalGroupName,
    this.actualEffectiveAt,
    this.notes,
    this.decidedBy,
    this.decidedByName,
    this.decisionAt,
    this.rejectionReason,
    this.cancellationReason,
  });

  factory AnimalMovement.fromJson(Map<String, dynamic> json) => AnimalMovement(
    id: json['id'] as String,
    organizationId: json['organization_id'] as String,
    animalId: json['animal_id'] as String,
    animalNumber: json['animal_number'] as String? ?? '',
    sourceFarmId: json['source_farm_id'] as String,
    sourceFarmName: json['source_farm_name'] as String? ?? '',
    sourceShedId: json['source_shed_id'] as String,
    sourceShedName: json['source_shed_name'] as String? ?? '',
    sourceAnimalGroupId: json['source_animal_group_id'] as String?,
    sourceAnimalGroupName: json['source_animal_group_name'] as String?,
    destinationFarmId: json['destination_farm_id'] as String,
    destinationFarmName: json['destination_farm_name'] as String? ?? '',
    destinationShedId: json['destination_shed_id'] as String,
    destinationShedName: json['destination_shed_name'] as String? ?? '',
    destinationAnimalGroupId: json['destination_animal_group_id'] as String?,
    destinationAnimalGroupName:
        json['destination_animal_group_name'] as String?,
    requestedEffectiveAt: _movementDate(json['requested_effective_at'])!,
    actualEffectiveAt: _movementDate(json['actual_effective_at']),
    reason: json['reason'] as String,
    notes: json['notes'] as String?,
    status: json['status'] as String,
    approvalRequired: json['approval_required'] as bool? ?? true,
    requestedBy: json['requested_by'] as String,
    requestedByName: json['requested_by_name'] as String? ?? '',
    decidedBy: json['decided_by'] as String?,
    decidedByName: json['decided_by_name'] as String?,
    decisionAt: _movementDate(json['decision_at']),
    rejectionReason: json['rejection_reason'] as String?,
    cancellationReason: json['cancellation_reason'] as String?,
    version: json['version'] as int? ?? 1,
    serverUpdatedAt:
        _movementDate(json['updated_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );

  final String id;
  final String organizationId;
  final String animalId;
  final String animalNumber;
  final String sourceFarmId;
  final String sourceFarmName;
  final String sourceShedId;
  final String sourceShedName;
  final String? sourceAnimalGroupId;
  final String? sourceAnimalGroupName;
  final String destinationFarmId;
  final String destinationFarmName;
  final String destinationShedId;
  final String destinationShedName;
  final String? destinationAnimalGroupId;
  final String? destinationAnimalGroupName;
  final DateTime requestedEffectiveAt;
  final DateTime? actualEffectiveAt;
  final String reason;
  final String? notes;
  final String status;
  final bool approvalRequired;
  final String requestedBy;
  final String requestedByName;
  final String? decidedBy;
  final String? decidedByName;
  final DateTime? decisionAt;
  final String? rejectionReason;
  final String? cancellationReason;
  final int version;
  final DateTime serverUpdatedAt;

  bool get isPending => status == 'pending';
}

final class AnimalMovementDraft {
  const AnimalMovementDraft({
    required this.sourceFarmId,
    required this.sourceShedId,
    required this.destinationFarmId,
    required this.destinationShedId,
    required this.requestedEffectiveAt,
    required this.reason,
    this.sourceAnimalGroupId,
    this.destinationAnimalGroupId,
    this.notes,
  });

  final String sourceFarmId;
  final String sourceShedId;
  final String? sourceAnimalGroupId;
  final String destinationFarmId;
  final String destinationShedId;
  final String? destinationAnimalGroupId;
  final DateTime requestedEffectiveAt;
  final String reason;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'source_farm_id': sourceFarmId,
    'source_shed_id': sourceShedId,
    'source_animal_group_id': sourceAnimalGroupId,
    'destination_farm_id': destinationFarmId,
    'destination_shed_id': destinationShedId,
    'destination_animal_group_id': destinationAnimalGroupId,
    'requested_effective_at': requestedEffectiveAt.toUtc().toIso8601String(),
    'reason': reason.trim(),
    'notes': _movementNullIfEmpty(notes),
  };
}

DateTime? _movementDate(Object? value) =>
    value is String && value.isNotEmpty ? DateTime.parse(value).toUtc() : null;

String? _movementNullIfEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

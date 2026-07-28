final class AnimalStatusChange {
  const AnimalStatusChange({
    required this.id,
    required this.organizationId,
    required this.farmId,
    required this.farmName,
    required this.animalId,
    required this.animalNumber,
    required this.previousStatus,
    required this.newStatus,
    required this.effectiveAt,
    required this.reason,
    required this.changedBy,
    required this.changedByName,
    required this.sequence,
    required this.serverUpdatedAt,
    this.animalVersion,
  });

  factory AnimalStatusChange.fromJson(Map<String, dynamic> json) =>
      AnimalStatusChange(
        id: json['id'] as String,
        organizationId: json['organization_id'] as String,
        farmId: json['farm_id'] as String,
        farmName: json['farm_name'] as String? ?? '',
        animalId: json['animal_id'] as String,
        animalNumber: json['animal_number'] as String? ?? '',
        previousStatus: json['previous_status'] as String,
        newStatus: json['new_status'] as String,
        effectiveAt: DateTime.parse(json['effective_at'] as String).toUtc(),
        reason: json['reason'] as String,
        changedBy: json['changed_by'] as String,
        changedByName: json['changed_by_name'] as String? ?? '',
        sequence: json['sequence'] as int,
        animalVersion: json['animal_version'] as int?,
        serverUpdatedAt:
            _statusDate(json['updated_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );

  final String id;
  final String organizationId;
  final String farmId;
  final String farmName;
  final String animalId;
  final String animalNumber;
  final String previousStatus;
  final String newStatus;
  final DateTime effectiveAt;
  final String reason;
  final String changedBy;
  final String changedByName;
  final int sequence;
  final int? animalVersion;
  final DateTime serverUpdatedAt;
}

final class AnimalStatusChangeDraft {
  const AnimalStatusChangeDraft({
    required this.newStatus,
    required this.effectiveAt,
    required this.reason,
    required this.version,
  });

  final String newStatus;
  final DateTime effectiveAt;
  final String reason;
  final int version;

  Map<String, dynamic> toJson() => {
    'new_status': newStatus,
    'effective_at': effectiveAt.toUtc().toIso8601String(),
    'reason': reason.trim(),
    'version': version,
  };
}

DateTime? _statusDate(Object? value) =>
    value is String && value.isNotEmpty ? DateTime.parse(value).toUtc() : null;

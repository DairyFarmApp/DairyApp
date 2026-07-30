enum MilkingSession {
  morning('morning', 'Morning'),
  afternoon('afternoon', 'Afternoon'),
  evening('evening', 'Evening');

  const MilkingSession(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static MilkingSession fromApi(String value) => values.firstWhere(
    (item) => item.apiValue == value,
    orElse: () => morning,
  );
}

final class MilkEligibleAnimal {
  const MilkEligibleAnimal({
    required this.id,
    required this.animalNumber,
    required this.shedId,
    this.name,
    this.shedName,
  });

  factory MilkEligibleAnimal.fromJson(Map<String, dynamic> json) =>
      MilkEligibleAnimal(
        id: json['id'] as String,
        animalNumber: json['animal_number'] as String,
        name: json['name'] as String?,
        shedId: json['shed_id'] as String,
        shedName: json['shed_name'] as String?,
      );

  final String id;
  final String animalNumber;
  final String? name;
  final String shedId;
  final String? shedName;
}

final class MilkEntry {
  const MilkEntry({
    required this.id,
    required this.slotId,
    required this.organizationId,
    required this.farmId,
    required this.shedId,
    required this.animalId,
    required this.animalNumber,
    required this.productionDate,
    required this.session,
    required this.quantityLitres,
    required this.rejectedQuantityLitres,
    required this.revision,
    required this.syncState,
    required this.updatedAt,
    this.shedName,
    this.animalName,
    this.rejectionReason,
    this.notes,
    this.correctionReason,
    this.recordedBy,
    this.recordedByName,
  });

  factory MilkEntry.fromJson(Map<String, dynamic> json) => MilkEntry(
    id: json['id'] as String,
    slotId: json['slot_id'] as String,
    organizationId: json['organization_id'] as String,
    farmId: json['farm_id'] as String,
    shedId: json['shed_id'] as String,
    shedName: json['shed_name'] as String?,
    animalId: json['animal_id'] as String,
    animalNumber: json['animal_number'] as String? ?? '',
    animalName: json['animal_name'] as String?,
    productionDate: DateTime.parse(json['production_date'] as String),
    session: MilkingSession.fromApi(json['session'] as String),
    quantityLitres: json['quantity_litres'] as String,
    rejectedQuantityLitres:
        json['rejected_quantity_litres'] as String? ?? '0.000',
    rejectionReason: json['rejection_reason'] as String?,
    notes: json['notes'] as String?,
    revision: json['revision'] as int? ?? 1,
    correctionReason: json['correction_reason'] as String?,
    recordedBy: json['recorded_by'] as String?,
    recordedByName: json['recorded_by_name'] as String?,
    syncState: 'synced',
    updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
  );

  final String id;
  final String slotId;
  final String organizationId;
  final String farmId;
  final String shedId;
  final String? shedName;
  final String animalId;
  final String animalNumber;
  final String? animalName;
  final DateTime productionDate;
  final MilkingSession session;
  final String quantityLitres;
  final String rejectedQuantityLitres;
  final String? rejectionReason;
  final String? notes;
  final int revision;
  final String? correctionReason;
  final String? recordedBy;
  final String? recordedByName;
  final String syncState;
  final DateTime updatedAt;

  double get quantity => double.parse(quantityLitres);
  double get rejectedQuantity => double.parse(rejectedQuantityLitres);
  double get sellableQuantity => quantity - rejectedQuantity;
}

final class MilkDailySummary {
  const MilkDailySummary({
    required this.totalLitres,
    required this.rejectedLitres,
    required this.sellableLitres,
    required this.entryCount,
    required this.animalsRecorded,
    required this.yesterdaySellableLitres,
    required this.sevenDayDailyAverageLitres,
  });

  factory MilkDailySummary.fromJson(Map<String, dynamic> json) =>
      MilkDailySummary(
        totalLitres: json['total_litres'] as String,
        rejectedLitres: json['rejected_litres'] as String,
        sellableLitres: json['sellable_litres'] as String,
        entryCount: json['entry_count'] as int,
        animalsRecorded: json['animals_recorded'] as int,
        yesterdaySellableLitres: json['yesterday_sellable_litres'] as String,
        sevenDayDailyAverageLitres:
            json['seven_day_daily_average_litres'] as String,
      );

  final String totalLitres;
  final String rejectedLitres;
  final String sellableLitres;
  final int entryCount;
  final int animalsRecorded;
  final String yesterdaySellableLitres;
  final String sevenDayDailyAverageLitres;
}

final class MilkDailyData {
  const MilkDailyData({
    required this.date,
    required this.session,
    required this.summary,
    required this.eligibleAnimals,
    required this.entries,
    required this.isCached,
  });

  final DateTime date;
  final MilkingSession session;
  final MilkDailySummary summary;
  final List<MilkEligibleAnimal> eligibleAnimals;
  final List<MilkEntry> entries;
  final bool isCached;
}

final class MilkEntryDraft {
  const MilkEntryDraft({
    required this.animal,
    required this.quantityLitres,
    this.rejectedQuantityLitres = '0.000',
    this.rejectionReason,
    this.notes,
  });

  final MilkEligibleAnimal animal;
  final String quantityLitres;
  final String rejectedQuantityLitres;
  final String? rejectionReason;
  final String? notes;
}

final class MilkSaveResult {
  const MilkSaveResult({required this.entries, required this.queuedOffline});

  final List<MilkEntry> entries;
  final bool queuedOffline;
}

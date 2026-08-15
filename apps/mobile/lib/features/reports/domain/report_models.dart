class AnimalDailyRecord {
  const AnimalDailyRecord({
    required this.animalId,
    required this.animalNumber,
    this.animalName,
    required this.date,
    required this.totalFeedKg,
    required this.totalMilkLitres,
  });

  final String animalId;
  final String animalNumber;
  final String? animalName;
  final DateTime date;
  final double totalFeedKg;
  final double totalMilkLitres;

  factory AnimalDailyRecord.fromJson(Map<String, dynamic> json) {
    return AnimalDailyRecord(
      animalId: json['animal_id'] as String,
      animalNumber: json['animal_number'] as String,
      animalName: json['animal_name'] as String?,
      date: DateTime.parse(json['date'] as String),
      totalFeedKg: (json['total_feed_kg'] as num).toDouble(),
      totalMilkLitres: (json['total_milk_litres'] as num).toDouble(),
    );
  }
}

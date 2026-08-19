final class AnimalFeedConsumption {
  const AnimalFeedConsumption({
    required this.id,
    required this.animalId,
    required this.inventoryItemId,
    this.inventoryItemName,
    required this.date,
    required this.session,
    required this.quantity,
    required this.unit,
    this.notes,
    required this.recordedBy,
    this.recordedByName,
    required this.createdAt,
  });

  factory AnimalFeedConsumption.fromJson(Map<String, dynamic> json) =>
      AnimalFeedConsumption(
        id: json['id'] as String,
        animalId: json['animal_id'] as String,
        inventoryItemId: json['inventory_item_id'] as String,
        inventoryItemName: json['inventory_item_name'] as String?,
        date: DateTime.parse(json['date'] as String),
        session: json['session'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        notes: json['notes'] as String?,
        recordedBy: json['recorded_by'] as String,
        recordedByName: json['recorded_by_name'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final String id;
  final String animalId;
  final String inventoryItemId;
  final String? inventoryItemName;
  final DateTime date;
  final String session;
  final double quantity;
  final String unit;
  final String? notes;
  final String recordedBy;
  final String? recordedByName;
  final DateTime createdAt;
}

final class AnimalFeedHistoryLoadResult {
  const AnimalFeedHistoryLoadResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory AnimalFeedHistoryLoadResult.fromJson(Map<String, dynamic> json) =>
      AnimalFeedHistoryLoadResult(
        items: (json['data'] as List<dynamic>)
            .map(
              (e) => AnimalFeedConsumption.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        currentPage: json['meta']['current_page'] as int,
        lastPage: json['meta']['last_page'] as int,
        total: json['meta']['total'] as int,
      );

  final List<AnimalFeedConsumption> items;
  final int currentPage;
  final int lastPage;
  final int total;
}

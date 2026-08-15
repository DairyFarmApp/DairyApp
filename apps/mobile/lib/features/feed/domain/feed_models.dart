final class FeedRationIngredient {
  const FeedRationIngredient({
    required this.id,
    required this.inventoryItemId,
    required this.quantityPerAnimal,
    required this.unit,
  });

  factory FeedRationIngredient.fromJson(Map<String, dynamic> json) =>
      FeedRationIngredient(
        id: json['id'] as String,
        inventoryItemId: json['inventory_item_id'] as String,
        quantityPerAnimal: json['quantity_per_animal'].toString(),
        unit: json['unit'] as String,
      );

  final String id;
  final String inventoryItemId;
  final String quantityPerAnimal;
  final String unit;
}

final class FeedRationPlan {
  const FeedRationPlan({
    required this.id,
    required this.name,
    this.animalGroupId,
    this.productionStage,
    required this.effectiveDate,
    this.endDate,
    required this.feedingFrequency,
    required this.version,
    required this.ingredients,
  });

  factory FeedRationPlan.fromJson(Map<String, dynamic> json) => FeedRationPlan(
    id: json['id'] as String,
    name: json['name'] as String,
    animalGroupId: json['animal_group_id'] as String?,
    productionStage: json['production_stage'] as String?,
    effectiveDate: DateTime.parse(json['effective_date'] as String),
    endDate: json['end_date'] != null
        ? DateTime.parse(json['end_date'] as String)
        : null,
    feedingFrequency: (json['feeding_frequency'] as num).toInt(),
    version: (json['version'] as num).toInt(),
    ingredients: (json['ingredients'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(FeedRationIngredient.fromJson)
        .toList(growable: false),
  );

  final String id;
  final String name;
  final String? animalGroupId;
  final String? productionStage;
  final DateTime effectiveDate;
  final DateTime? endDate;
  final int feedingFrequency;
  final int version;
  final List<FeedRationIngredient> ingredients;
}

final class DailyFeedIssue {
  const DailyFeedIssue({
    required this.id,
    this.shedId,
    this.animalGroupId,
    required this.date,
    required this.inventoryItemId,
    required this.plannedQuantity,
    required this.issuedQuantity,
    required this.consumedQuantity,
    required this.wastedQuantity,
    required this.returnedQuantity,
    this.employeeId,
    this.notes,
    required this.version,
    this.inventoryPosted = false,
    this.inventoryNetQuantity = '0',
  });

  factory DailyFeedIssue.fromJson(Map<String, dynamic> json) => DailyFeedIssue(
    id: json['id'] as String,
    shedId: json['shed_id'] as String?,
    animalGroupId: json['animal_group_id'] as String?,
    date: DateTime.parse(json['date'] as String),
    inventoryItemId: json['inventory_item_id'] as String,
    plannedQuantity: json['planned_quantity'].toString(),
    issuedQuantity: json['issued_quantity'].toString(),
    consumedQuantity: json['consumed_quantity'].toString(),
    wastedQuantity: json['wasted_quantity'].toString(),
    returnedQuantity: json['returned_quantity'].toString(),
    employeeId: json['employee_id'] as String?,
    notes: json['notes'] as String?,
    version: (json['version'] as num).toInt(),
    inventoryPosted: json['inventory_posted'] as bool? ?? false,
    inventoryNetQuantity: json['inventory_net_quantity']?.toString() ?? '0',
  );

  final String id;
  final String? shedId;
  final String? animalGroupId;
  final DateTime date;
  final String inventoryItemId;
  final String plannedQuantity;
  final String issuedQuantity;
  final String consumedQuantity;
  final String wastedQuantity;
  final String returnedQuantity;
  final String? employeeId;
  final String? notes;
  final int version;
  final bool inventoryPosted;
  final String inventoryNetQuantity;
}

import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';

class AnimalPurchase {
  final String id;
  final String? animalId;
  final String purchaseNumber;
  final DateTime purchaseDate;
  final String? supplier;
  final double purchasePrice;
  final double transportationCost;
  final double veterinaryCost;
  final double totalCost;
  final String? reference;
  final String? notes;
  final Animal? animal;

  AnimalPurchase({
    required this.id,
    this.animalId,
    required this.purchaseNumber,
    required this.purchaseDate,
    this.supplier,
    required this.purchasePrice,
    required this.transportationCost,
    required this.veterinaryCost,
    required this.totalCost,
    this.reference,
    this.notes,
    this.animal,
  });

  factory AnimalPurchase.fromJson(Map<String, dynamic> json) {
    final animalObj = json['animal'] != null
        ? Animal.fromJson(json['animal'] as Map<String, dynamic>)
        : null;
    return AnimalPurchase(
      id: json['id'] as String,
      animalId: (json['animal_id'] as String?) ?? animalObj?.id,
      purchaseNumber: json['purchase_number'] as String,
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      supplier: json['supplier'] as String?,
      purchasePrice: double.parse(json['purchase_price'].toString()),
      transportationCost: double.parse(json['transportation_cost'].toString()),
      veterinaryCost: double.parse(json['veterinary_cost'].toString()),
      totalCost: double.parse(json['total_cost'].toString()),
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      animal: animalObj,
    );
  }
}

class AnimalSale {
  final String id;
  final String? animalId;
  final String saleNumber;
  final DateTime saleDate;
  final String? buyer;
  final double salePrice;
  final double commission;
  final double transportationCost;
  final double netRevenue;
  final String? reason;
  final String? reference;
  final String? notes;
  final Animal? animal;

  AnimalSale({
    required this.id,
    this.animalId,
    required this.saleNumber,
    required this.saleDate,
    this.buyer,
    required this.salePrice,
    required this.commission,
    required this.transportationCost,
    required this.netRevenue,
    this.reason,
    this.reference,
    this.notes,
    this.animal,
  });

  factory AnimalSale.fromJson(Map<String, dynamic> json) {
    final animalObj = json['animal'] != null
        ? Animal.fromJson(json['animal'] as Map<String, dynamic>)
        : null;
    return AnimalSale(
      id: json['id'] as String,
      animalId: (json['animal_id'] as String?) ?? animalObj?.id,
      saleNumber: json['sale_number'] as String,
      saleDate: DateTime.parse(json['sale_date'] as String),
      buyer: json['buyer'] as String?,
      salePrice: double.parse(json['sale_price'].toString()),
      commission: double.parse(json['commission'].toString()),
      transportationCost: double.parse(json['transportation_cost'].toString()),
      netRevenue: double.parse(json['net_revenue'].toString()),
      reason: json['reason'] as String?,
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      animal: animalObj,
    );
  }
}

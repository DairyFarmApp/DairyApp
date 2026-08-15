import 'dart:typed_data';

enum InventoryKind {
  medicine,
  semen,
  feed;

  String get apiValue => name;

  String get label => switch (this) {
    medicine => 'Medicine',
    semen => 'Semen',
    feed => 'Feed',
  };

  static InventoryKind? fromPath(String value) {
    for (final kind in values) {
      if (kind.name == value) return kind;
    }
    return null;
  }
}

enum InventoryExportFormat {
  receipt,
  spreadsheet;

  String get path => switch (this) {
    receipt => 'receipt',
    spreadsheet => 'spreadsheet',
  };

  String get extension => switch (this) {
    receipt => 'pdf',
    spreadsheet => 'xlsx',
  };

  String get mimeType => switch (this) {
    receipt => 'application/pdf',
    spreadsheet =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  };
}

final class InventoryExportFile {
  const InventoryExportFile({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String filename;
  final String mimeType;
}

final class InventorySummary {
  const InventorySummary({
    required this.itemCount,
    required this.totalStock,
    required this.totalValue,
    required this.lowStockItems,
    required this.expiringSoonBatches,
    required this.expiredBatches,
  });

  factory InventorySummary.fromJson(Map<String, dynamic> json) =>
      InventorySummary(
        itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
        totalStock: json['total_stock']?.toString() ?? '0.000',
        totalValue: json['total_value']?.toString() ?? '0.0000',
        lowStockItems: (json['low_stock_items'] as num?)?.toInt() ?? 0,
        expiringSoonBatches:
            (json['expiring_soon_batches'] as num?)?.toInt() ?? 0,
        expiredBatches: (json['expired_batches'] as num?)?.toInt() ?? 0,
      );

  final int itemCount;
  final String totalStock;
  final String totalValue;
  final int lowStockItems;
  final int expiringSoonBatches;
  final int expiredBatches;
}

final class InventoryBatch {
  const InventoryBatch({
    required this.id,
    required this.batchNumber,
    required this.unitCost,
    required this.currentQuantity,
    this.supplier,
    this.purchaseDate,
    this.expiryDate,
  });

  factory InventoryBatch.fromJson(Map<String, dynamic> json) => InventoryBatch(
    id: json['id'] as String,
    batchNumber: json['batch_number'] as String,
    supplier: json['supplier'] as String?,
    purchaseDate: _date(json['purchase_date']),
    expiryDate: _date(json['expiry_date']),
    unitCost: json['unit_cost'].toString(),
    currentQuantity: json['current_quantity'].toString(),
  );

  final String id;
  final String batchNumber;
  final String? supplier;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final String unitCost;
  final String currentQuantity;

  bool get isExpired =>
      expiryDate != null &&
      expiryDate!.isBefore(DateTime.now().toUtc().copyWith(hour: 0));
}

final class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.kind,
    required this.itemCode,
    required this.name,
    required this.category,
    required this.unit,
    required this.minimumStock,
    required this.currentStock,
    required this.totalValue,
    required this.version,
    required this.batches,
    this.barcode,
    this.brand,
    this.genericName,
    this.drapRegistrationNumber,
    this.concentration,
    this.milkWithdrawalHours,
    this.meatWithdrawalDays,
    this.regulatoryVerifiedOn,
    this.maximumStock,
    this.notes,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'] as String,
    kind: InventoryKind.fromPath(json['kind'] as String)!,
    itemCode: json['item_code'] as String,
    barcode: json['barcode'] as String?,
    name: json['name'] as String,
    category: json['category'] as String,
    brand: json['brand'] as String?,
    genericName: json['generic_name'] as String?,
    drapRegistrationNumber: json['drap_registration_number'] as String?,
    concentration: json['concentration'] as String?,
    milkWithdrawalHours: (json['milk_withdrawal_hours'] as num?)?.toInt(),
    meatWithdrawalDays: (json['meat_withdrawal_days'] as num?)?.toInt(),
    regulatoryVerifiedOn: json['regulatory_verified_on'] == null
        ? null
        : DateTime.parse(json['regulatory_verified_on'] as String),
    unit: json['unit'] as String,
    minimumStock: json['minimum_stock'].toString(),
    maximumStock: json['maximum_stock']?.toString(),
    currentStock: json['current_stock'].toString(),
    totalValue: json['total_value'].toString(),
    notes: json['notes'] as String?,
    version: (json['version'] as num).toInt(),
    batches: (json['batches'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(InventoryBatch.fromJson)
        .toList(growable: false),
  );

  final String id;
  final InventoryKind kind;
  final String itemCode;
  final String? barcode;
  final String name;
  final String category;
  final String? brand;
  final String? genericName;
  final String? drapRegistrationNumber;
  final String? concentration;
  final int? milkWithdrawalHours;
  final int? meatWithdrawalDays;
  final DateTime? regulatoryVerifiedOn;
  final String unit;
  final String minimumStock;
  final String? maximumStock;
  final String currentStock;
  final String totalValue;
  final String? notes;
  final int version;
  final List<InventoryBatch> batches;

  bool get isLowStock =>
      double.parse(currentStock) <= double.parse(minimumStock);
}

final class InventoryOverview {
  const InventoryOverview({
    required this.summary,
    required this.items,
    required this.categories,
    required this.suppliers,
  });

  factory InventoryOverview.fromJson(Map<String, dynamic> json) =>
      InventoryOverview(
        summary: InventorySummary.fromJson(
          json['summary'] as Map<String, dynamic>,
        ),
        items: (json['items'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(InventoryItem.fromJson)
            .toList(growable: false),
        categories:
            (json['filters'] as Map<String, dynamic>?)?['categories']
                ?.cast<String>() ??
            const [],
        suppliers:
            (json['filters'] as Map<String, dynamic>?)?['suppliers']
                ?.cast<String>() ??
            const [],
      );

  final InventorySummary summary;
  final List<InventoryItem> items;
  final List<String> categories;
  final List<String> suppliers;
}

final class StockUsageRecord {
  const StockUsageRecord({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.itemCode,
    required this.kind,
    required this.unit,
    required this.quantity,
    required this.occurredAt,
    required this.purpose,
    required this.batchNumber,
  });

  factory StockUsageRecord.fromJson(Map<String, dynamic> json) =>
      StockUsageRecord(
        id: json['id'] as String,
        itemId: json['item_id'] as String,
        itemName: json['item_name'] as String? ?? 'Inventory item',
        itemCode: json['item_code'] as String? ?? '',
        kind:
            InventoryKind.fromPath(json['kind'] as String? ?? '') ??
            InventoryKind.feed,
        unit: json['unit'] as String? ?? '',
        quantity: json['quantity_change'].toString().replaceFirst('-', ''),
        occurredAt: DateTime.parse(json['occurred_at'] as String).toLocal(),
        purpose: json['reason'] as String? ?? '',
        batchNumber: json['batch_number'] as String? ?? '',
      );

  final String id;
  final String itemId;
  final String itemName;
  final String itemCode;
  final InventoryKind kind;
  final String unit;
  final String quantity;
  final DateTime occurredAt;
  final String purpose;
  final String batchNumber;
}

final class InventoryMovement {
  const InventoryMovement({
    required this.id,
    required this.movementType,
    required this.quantityChange,
    required this.occurredAt,
    required this.balanceAfter,
    this.batchNumber,
    this.reason,
  });

  factory InventoryMovement.fromJson(
    Map<String, dynamic> json, {
    required String balanceAfter,
  }) => InventoryMovement(
    id: json['id'] as String,
    movementType: json['movement_type'] as String,
    quantityChange: json['quantity_change'].toString(),
    occurredAt: DateTime.parse(json['occurred_at'] as String).toLocal(),
    balanceAfter: balanceAfter,
    batchNumber: json['batch_number'] as String?,
    reason: json['reason'] as String?,
  );

  final String id;
  final String movementType;
  final String quantityChange;
  final DateTime occurredAt;
  final String balanceAfter;
  final String? batchNumber;
  final String? reason;

  bool get isAddition => double.parse(quantityChange) >= 0;
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString())?.toUtc();

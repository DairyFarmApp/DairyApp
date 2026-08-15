final class PurchaseOrderLine {
  const PurchaseOrderLine({
    required this.id,
    required this.inventoryItemId,
    required this.itemName,
    required this.unit,
    required this.orderedQuantity,
    required this.receivedQuantity,
    required this.unitRate,
    required this.lineTotal,
  });
  final String id,
      inventoryItemId,
      itemName,
      unit,
      orderedQuantity,
      receivedQuantity,
      unitRate,
      lineTotal;
  double get remaining =>
      double.parse(orderedQuantity) - double.parse(receivedQuantity);
  factory PurchaseOrderLine.fromJson(Map<String, dynamic> j) =>
      PurchaseOrderLine(
        id: j['id'] as String,
        inventoryItemId: j['inventory_item_id'] as String,
        itemName: j['item_name'] as String,
        unit: j['unit'] as String,
        orderedQuantity: '${j['ordered_quantity']}',
        receivedQuantity: '${j['received_quantity']}',
        unitRate: '${j['unit_rate']}',
        lineTotal: '${j['line_total']}',
      );
}

final class PurchaseReceipt {
  const PurchaseReceipt({
    required this.number,
    required this.receivedAt,
    required this.qualityStatus,
  });
  final String number, qualityStatus;
  final DateTime receivedAt;
  factory PurchaseReceipt.fromJson(Map<String, dynamic> j) => PurchaseReceipt(
    number: j['receipt_number'] as String,
    receivedAt: DateTime.parse(j['received_at'] as String),
    qualityStatus: j['quality_status'] as String,
  );
}

final class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.number,
    required this.supplierId,
    required this.supplierName,
    required this.purchaseDate,
    required this.status,
    required this.subtotal,
    required this.total,
    required this.lines,
    required this.receipts,
  });
  final String id, number, supplierId, supplierName, status, subtotal, total;
  final DateTime purchaseDate;
  final List<PurchaseOrderLine> lines;
  final List<PurchaseReceipt> receipts;
  factory PurchaseOrder.fromJson(Map<String, dynamic> j) {
    final s = j['supplier'] as Map<String, dynamic>;
    return PurchaseOrder(
      id: j['id'] as String,
      number: j['purchase_number'] as String,
      supplierId: s['id'] as String,
      supplierName: s['name'] as String,
      purchaseDate: DateTime.parse(j['purchase_date'] as String),
      status: j['status'] as String,
      subtotal: '${j['subtotal']}',
      total: '${j['total']}',
      lines: (j['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(PurchaseOrderLine.fromJson)
          .toList(),
      receipts: (j['receipts'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(PurchaseReceipt.fromJson)
          .toList(),
    );
  }
}

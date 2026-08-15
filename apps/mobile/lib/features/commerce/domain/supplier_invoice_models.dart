final class SupplierPayment {
  const SupplierPayment({
    required this.id,
    required this.number,
    required this.date,
    required this.amount,
    required this.method,
    this.reference,
  });
  final String id, number, amount, method;
  final DateTime date;
  final String? reference;
  factory SupplierPayment.fromJson(Map<String, dynamic> j) => SupplierPayment(
    id: j['id'] as String,
    number: j['payment_number'] as String,
    date: DateTime.parse(j['payment_date'] as String),
    amount: '${j['amount']}',
    method: j['payment_method'] as String,
    reference: j['reference'] as String?,
  );
}

final class SupplierInvoice {
  const SupplierInvoice({
    required this.id,
    required this.number,
    required this.externalNumber,
    required this.supplierId,
    required this.supplierName,
    required this.purchaseOrderId,
    required this.purchaseNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.total,
    required this.paid,
    required this.balance,
    required this.status,
    required this.payments,
  });
  final String id,
      number,
      externalNumber,
      supplierId,
      supplierName,
      purchaseOrderId,
      purchaseNumber,
      total,
      paid,
      balance,
      status;
  final DateTime invoiceDate, dueDate;
  final List<SupplierPayment> payments;
  bool get overdue =>
      status != 'paid' &&
      dueDate.isBefore(
        DateTime.now().copyWith(
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        ),
      );
  factory SupplierInvoice.fromJson(Map<String, dynamic> j) {
    final s = j['supplier'] as Map<String, dynamic>,
        p = j['purchase_order'] as Map<String, dynamic>;
    return SupplierInvoice(
      id: j['id'] as String,
      number: j['invoice_number'] as String,
      externalNumber: j['supplier_invoice_number'] as String,
      supplierId: s['id'] as String,
      supplierName: s['name'] as String,
      purchaseOrderId: p['id'] as String,
      purchaseNumber: p['purchase_number'] as String,
      invoiceDate: DateTime.parse(j['invoice_date'] as String),
      dueDate: DateTime.parse(j['due_date'] as String),
      total: '${j['total_amount']}',
      paid: '${j['paid_amount']}',
      balance: '${j['balance_amount']}',
      status: j['payment_status'] as String,
      payments: (j['payments'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(SupplierPayment.fromJson)
          .toList(),
    );
  }
}

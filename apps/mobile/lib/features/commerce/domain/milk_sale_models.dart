final class MilkBatchAvailability {
  const MilkBatchAvailability({required this.date, required this.available});
  final DateTime date;
  final String available;
  factory MilkBatchAvailability.fromJson(Map<String, dynamic> j) =>
      MilkBatchAvailability(
        date: DateTime.parse(j['date'] as String),
        available: '${j['available_sellable_litres']}',
      );
}

final class CustomerSalePayment {
  const CustomerSalePayment({
    required this.number,
    required this.date,
    required this.amount,
    required this.method,
  });
  final String number, amount, method;
  final DateTime date;
  factory CustomerSalePayment.fromJson(Map<String, dynamic> j) =>
      CustomerSalePayment(
        number: j['payment_number'] as String,
        date: DateTime.parse(j['payment_date'] as String),
        amount: '${j['amount']}',
        method: j['payment_method'] as String,
      );
}

final class MilkSale {
  const MilkSale({
    required this.id,
    required this.number,
    required this.customerId,
    required this.customerName,
    required this.soldAt,
    required this.batchDate,
    required this.quantity,
    required this.baseRate,
    required this.total,
    required this.paid,
    required this.balance,
    required this.paymentStatus,
    required this.status,
    required this.deliveryStatus,
    required this.payments,
  });
  final String id,
      number,
      customerId,
      customerName,
      quantity,
      baseRate,
      total,
      paid,
      balance,
      paymentStatus,
      status,
      deliveryStatus;
  final DateTime soldAt, batchDate;
  final List<CustomerSalePayment> payments;
  factory MilkSale.fromJson(Map<String, dynamic> j) {
    final c = j['customer'] as Map<String, dynamic>;
    return MilkSale(
      id: j['id'] as String,
      number: j['invoice_number'] as String,
      customerId: c['id'] as String,
      customerName: c['name'] as String,
      soldAt: DateTime.parse(j['sold_at'] as String),
      batchDate: DateTime.parse(j['milk_batch_date'] as String),
      quantity: '${j['quantity_litres']}',
      baseRate: '${j['base_rate']}',
      total: '${j['total_amount']}',
      paid: '${j['paid_amount']}',
      balance: '${j['balance_amount']}',
      paymentStatus: j['payment_status'] as String,
      status: j['status'] as String,
      deliveryStatus: j['delivery_status'] as String,
      payments: (j['payments'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(CustomerSalePayment.fromJson)
          .toList(),
    );
  }
}

final class MilkSalesOverview {
  const MilkSalesOverview({required this.batches, required this.sales});
  final List<MilkBatchAvailability> batches;
  final List<MilkSale> sales;
  factory MilkSalesOverview.fromJson(Map<String, dynamic> j) =>
      MilkSalesOverview(
        batches: (j['available_batches'] as List)
            .cast<Map<String, dynamic>>()
            .map(MilkBatchAvailability.fromJson)
            .toList(),
        sales: (j['sales'] as List)
            .cast<Map<String, dynamic>>()
            .map(MilkSale.fromJson)
            .toList(),
      );
}

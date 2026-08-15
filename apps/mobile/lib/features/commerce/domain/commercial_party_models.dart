final class CommercialParty {
  const CommercialParty({
    required this.id,
    required this.farmId,
    required this.code,
    required this.name,
    required this.type,
    required this.creditLimit,
    required this.openingBalance,
    required this.currentBalance,
    required this.version,
    required this.active,
    this.phone,
    this.email,
    this.address,
    this.deliveryAddress,
    this.contactPerson,
    this.routeName,
    this.defaultMilkRate,
    this.paymentTermsDays = 0,
    this.qualityBasedPricing = false,
    this.notes,
  });

  final String id,
      farmId,
      code,
      name,
      type,
      creditLimit,
      openingBalance,
      currentBalance;
  final String? phone,
      email,
      address,
      deliveryAddress,
      contactPerson,
      routeName,
      defaultMilkRate,
      notes;
  final int paymentTermsDays, version;
  final bool qualityBasedPricing, active;

  factory CommercialParty.fromJson(
    Map<String, dynamic> json, {
    required String fallbackType,
  }) => CommercialParty(
    id: json['id'] as String,
    farmId: json['farm_id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    type: (json['customer_type'] as String?) ?? fallbackType,
    creditLimit: '${json['credit_limit'] ?? '0.00'}',
    openingBalance: '${json['opening_balance'] ?? '0.00'}',
    currentBalance: '${json['current_balance'] ?? '0.00'}',
    version: (json['version'] as num?)?.toInt() ?? 1,
    active: json['is_active'] as bool? ?? true,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    address: json['address'] as String?,
    deliveryAddress: json['delivery_address'] as String?,
    contactPerson: json['contact_person'] as String?,
    routeName: json['route_name'] as String?,
    defaultMilkRate: json['default_milk_rate']?.toString(),
    paymentTermsDays: (json['payment_terms_days'] as num?)?.toInt() ?? 0,
    qualityBasedPricing: json['quality_based_pricing'] as bool? ?? false,
    notes: json['notes'] as String?,
  );
}

final class CommercialLedgerEntry {
  const CommercialLedgerEntry({
    required this.occurredAt,
    required this.type,
    required this.debit,
    required this.credit,
    required this.balanceAfter,
    required this.description,
  });
  final DateTime occurredAt;
  final String type, debit, credit, balanceAfter, description;
  factory CommercialLedgerEntry.fromJson(Map<String, dynamic> json) =>
      CommercialLedgerEntry(
        occurredAt: DateTime.parse(json['occurred_at'] as String),
        type: json['entry_type'] as String,
        debit: '${json['debit']}',
        credit: '${json['credit']}',
        balanceAfter: '${json['balance_after']}',
        description: json['description'] as String,
      );
}

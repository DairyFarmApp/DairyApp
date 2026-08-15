final class DeliveryCustomer {
  const DeliveryCustomer({required this.id, required this.name});
  final String id, name;
  factory DeliveryCustomer.fromJson(Map<String, dynamic> j) =>
      DeliveryCustomer(id: '${j['id']}', name: '${j['name']}');
}

final class DeliveryRouteStop {
  const DeliveryRouteStop({
    required this.id,
    required this.customer,
    required this.order,
    this.address,
  });
  final String id;
  final DeliveryCustomer customer;
  final int order;
  final String? address;
  factory DeliveryRouteStop.fromJson(Map<String, dynamic> j) =>
      DeliveryRouteStop(
        id: '${j['id']}',
        customer: DeliveryCustomer.fromJson(
          j['customer'] as Map<String, dynamic>,
        ),
        order: (j['stop_order'] as num).toInt(),
        address: j['delivery_address'] as String?,
      );
}

final class DeliveryRoute {
  const DeliveryRoute({
    required this.id,
    required this.code,
    required this.name,
    required this.stops,
  });
  final String id, code, name;
  final List<DeliveryRouteStop> stops;
  factory DeliveryRoute.fromJson(Map<String, dynamic> j) => DeliveryRoute(
    id: '${j['id']}',
    code: '${j['code']}',
    name: '${j['name']}',
    stops: (j['stops'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(DeliveryRouteStop.fromJson)
        .toList(),
  );
}

final class DeliveryVehicle {
  const DeliveryVehicle({
    required this.id,
    required this.code,
    required this.registration,
    required this.capacity,
  });
  final String id, code, registration, capacity;
  factory DeliveryVehicle.fromJson(Map<String, dynamic> j) => DeliveryVehicle(
    id: '${j['id']}',
    code: '${j['code']}',
    registration: '${j['registration_number']}',
    capacity: '${j['capacity_litres']}',
  );
}

final class DeliveryDriver {
  const DeliveryDriver({
    required this.id,
    required this.code,
    required this.name,
    this.phone,
  });
  final String id, code, name;
  final String? phone;
  factory DeliveryDriver.fromJson(Map<String, dynamic> j) => DeliveryDriver(
    id: '${j['id']}',
    code: '${j['code']}',
    name: '${j['name']}',
    phone: j['phone'] as String?,
  );
}

final class EligibleDeliverySale {
  const EligibleDeliverySale({
    required this.id,
    required this.number,
    required this.customer,
    required this.quantity,
  });
  final String id, number, quantity;
  final DeliveryCustomer customer;
  factory EligibleDeliverySale.fromJson(Map<String, dynamic> j) =>
      EligibleDeliverySale(
        id: '${j['id']}',
        number: '${j['invoice_number']}',
        quantity: '${j['quantity_litres']}',
        customer: DeliveryCustomer.fromJson(
          j['customer'] as Map<String, dynamic>,
        ),
      );
}

final class ManifestStop {
  const ManifestStop({
    required this.id,
    required this.customer,
    required this.planned,
    required this.status,
    required this.hasProof,
    required this.refundDue,
    required this.refundedAmount,
  });
  final String id, planned, status;
  final DeliveryCustomer customer;
  final bool hasProof;
  final String refundDue, refundedAmount;
  factory ManifestStop.fromJson(Map<String, dynamic> j) => ManifestStop(
    id: '${j['id']}',
    customer: DeliveryCustomer.fromJson(j['customer'] as Map<String, dynamic>),
    planned: '${j['planned_quantity']}',
    status: '${j['status']}',
    hasProof: j['proof_storage_path'] != null,
    refundDue:
        '${(j['sale_return'] as Map<String, dynamic>?)?['refund_due'] ?? 0}',
    refundedAmount:
        '${(j['sale_return'] as Map<String, dynamic>?)?['refunded_amount'] ?? 0}',
  );
}

final class DeliveryManifest {
  const DeliveryManifest({
    required this.id,
    required this.number,
    required this.date,
    required this.status,
    required this.planned,
    required this.route,
    required this.vehicle,
    required this.driver,
    required this.stops,
  });
  final String id, number, status, planned;
  final DateTime date;
  final DeliveryRoute route;
  final DeliveryVehicle vehicle;
  final DeliveryDriver driver;
  final List<ManifestStop> stops;
  factory DeliveryManifest.fromJson(Map<String, dynamic> j) => DeliveryManifest(
    id: '${j['id']}',
    number: '${j['delivery_number']}',
    date: DateTime.parse('${j['delivery_date']}'),
    status: '${j['status']}',
    planned: '${j['planned_quantity']}',
    route: DeliveryRoute.fromJson(j['route'] as Map<String, dynamic>),
    vehicle: DeliveryVehicle.fromJson(j['vehicle'] as Map<String, dynamic>),
    driver: DeliveryDriver.fromJson(j['driver'] as Map<String, dynamic>),
    stops: (j['stops'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(ManifestStop.fromJson)
        .toList(),
  );
}

final class DeliveryOverview {
  const DeliveryOverview({
    required this.routes,
    required this.vehicles,
    required this.drivers,
    required this.sales,
    required this.manifests,
  });
  final List<DeliveryRoute> routes;
  final List<DeliveryVehicle> vehicles;
  final List<DeliveryDriver> drivers;
  final List<EligibleDeliverySale> sales;
  final List<DeliveryManifest> manifests;
  factory DeliveryOverview.fromJson(Map<String, dynamic> j) => DeliveryOverview(
    routes: (j['routes'] as List)
        .cast<Map<String, dynamic>>()
        .map(DeliveryRoute.fromJson)
        .toList(),
    vehicles: (j['vehicles'] as List)
        .cast<Map<String, dynamic>>()
        .map(DeliveryVehicle.fromJson)
        .toList(),
    drivers: (j['drivers'] as List)
        .cast<Map<String, dynamic>>()
        .map(DeliveryDriver.fromJson)
        .toList(),
    sales: (j['eligible_sales'] as List)
        .cast<Map<String, dynamic>>()
        .map(EligibleDeliverySale.fromJson)
        .toList(),
    manifests: (j['manifests'] as List)
        .cast<Map<String, dynamic>>()
        .map(DeliveryManifest.fromJson)
        .toList(),
  );
}

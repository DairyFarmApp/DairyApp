import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/commerce/data/purchase_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'purchase repository lists creates approves and receives idempotently',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio();
      final api = ApiClient(
        config: EnvironmentConfig(
          environment: AppEnvironment.development,
          apiBaseUrl: Uri.parse('http://example.test/api/v1'),
        ),
        readAccessToken: () async => 'token',
        dio: dio,
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            requests.add(o);
            final order = _order();
            final data = o.path.endsWith('/receipts')
                ? {'purchase_order': order}
                : o.method == 'GET'
                ? [order]
                : order;
            h.resolve(
              Response<Object>(
                requestOptions: o,
                statusCode: o.method == 'POST' ? 201 : 200,
                data: {'data': data},
              ),
            );
          },
        ),
      );
      final repo = PurchaseRepository(api: api);
      final listed = await repo.list();
      await repo.create({'supplier_id': 's1'});
      await repo.approve('po1');
      await repo.receive('po1', {'quality_status': 'accepted'});
      expect(listed.single.total, '2400.00');
      expect(requests.map((r) => '${r.method} ${r.path}'), [
        'GET /purchase-orders',
        'POST /purchase-orders',
        'POST /purchase-orders/po1/approve',
        'POST /purchase-orders/po1/receipts',
      ]);
      expect(
        requests
            .where((r) => r.method == 'POST')
            .every((r) => r.headers['Idempotency-Key'] != null),
        isTrue,
      );
    },
  );
}

Map<String, dynamic> _order() => {
  'id': 'po1',
  'purchase_number': 'PO-000001',
  'supplier': {'id': 's1', 'name': 'Feed Supplier'},
  'purchase_date': '2026-08-12',
  'status': 'draft',
  'subtotal': '2400.00',
  'total': '2400.00',
  'items': [
    {
      'id': 'l1',
      'inventory_item_id': 'i1',
      'item_name': 'Feed',
      'unit': 'kg',
      'ordered_quantity': '24.000',
      'received_quantity': '0.000',
      'unit_rate': '100.0000',
      'line_total': '2400.00',
    },
  ],
  'receipts': [],
};

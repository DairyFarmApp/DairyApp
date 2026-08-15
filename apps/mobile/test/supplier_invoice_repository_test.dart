import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/commerce/data/supplier_invoice_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'supplier invoice repository lists creates and pays with idempotency',
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
            h.resolve(
              Response<Object>(
                requestOptions: o,
                statusCode: o.method == 'POST' ? 201 : 200,
                data: {
                  'data': o.method == 'GET' ? [_invoice()] : _invoice(),
                },
              ),
            );
          },
        ),
      );
      final repo = SupplierInvoiceRepository(api: api);
      final rows = await repo.list();
      await repo.create({'purchase_order_id': 'po1'});
      await repo.pay('inv1', {'amount': '500'});
      expect(rows.single.balance, '1500.00');
      expect(rows.single.payments.single.number, 'SPAY-000001');
      expect(requests.map((r) => '${r.method} ${r.path}'), [
        'GET /supplier-invoices',
        'POST /supplier-invoices',
        'POST /supplier-invoices/inv1/payments',
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

Map<String, dynamic> _invoice() => {
  'id': 'inv1',
  'invoice_number': 'SINV-000001',
  'supplier_invoice_number': 'EXT-9',
  'supplier': {'id': 's1', 'code': 'SUP-00001', 'name': 'Feed Supplier'},
  'purchase_order': {'id': 'po1', 'purchase_number': 'PO-000001'},
  'invoice_date': '2026-08-12',
  'due_date': '2026-09-12',
  'total_amount': '2000.00',
  'paid_amount': '500.00',
  'balance_amount': '1500.00',
  'payment_status': 'partially_paid',
  'payments': [
    {
      'id': 'pay1',
      'payment_number': 'SPAY-000001',
      'payment_date': '2026-08-13',
      'amount': '500.00',
      'payment_method': 'cash',
      'reference': null,
    },
  ],
};

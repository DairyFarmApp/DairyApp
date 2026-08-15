import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/commerce/data/milk_sales_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'milk sales repository covers list draft confirm payment and cancellation',
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
                  'data': o.method == 'GET'
                      ? {
                          'available_batches': [
                            {
                              'date': '2026-08-12',
                              'available_sellable_litres': '8.000',
                            },
                          ],
                          'sales': [_sale()],
                        }
                      : _sale(),
                },
              ),
            );
          },
        ),
      );
      final repo = MilkSalesRepository(api: api);
      final overview = await repo.list();
      await repo.create({'quantity_litres': '5'});
      await repo.confirm('s1');
      await repo.pay('s1', {'amount': '500'});
      await repo.cancel('s1', 'Wrong customer');
      expect(overview.batches.single.available, '8.000');
      expect(overview.sales.single.balance, '1500.00');
      expect(requests.map((r) => '${r.method} ${r.path}'), [
        'GET /milk-sales',
        'POST /milk-sales',
        'POST /milk-sales/s1/confirm',
        'POST /milk-sales/s1/payments',
        'POST /milk-sales/s1/cancel',
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

Map<String, dynamic> _sale() => {
  'id': 's1',
  'invoice_number': 'MS-000001',
  'customer': {'id': 'c1', 'code': 'CUS-1', 'name': 'Milk Shop'},
  'sold_at': '2026-08-12T10:00:00Z',
  'milk_batch_date': '2026-08-12',
  'quantity_litres': '5.000',
  'base_rate': '200.00',
  'total_amount': '2000.00',
  'paid_amount': '500.00',
  'balance_amount': '1500.00',
  'payment_status': 'partially_paid',
  'status': 'confirmed',
  'delivery_status': 'pending',
  'payments': [
    {
      'payment_number': 'CPAY-1',
      'payment_date': '2026-08-12',
      'amount': '500.00',
      'payment_method': 'cash',
    },
  ],
};

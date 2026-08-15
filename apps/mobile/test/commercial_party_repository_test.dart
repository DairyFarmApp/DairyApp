import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/commerce/data/commercial_party_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'commercial repository lists creates updates archives and reads ledger',
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
            final data = o.path.endsWith('/ledger')
                ? [_ledger()]
                : o.method == 'GET' && o.path == '/customers'
                ? [_party()]
                : _party();
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
      final repo = CommercialPartyRepository(api: api);
      final list = await repo.list('customers');
      final created = await repo.create('customers', {'name': 'Buyer'});
      await repo.update('customers', created, {'name': 'Updated'});
      await repo.ledger('customers', created.id);
      await repo.archive('customers', created.id);
      expect(list.single.code, 'CUS-00001');
      expect(list.single.currentBalance, '1200.00');
      expect(requests.map((r) => '${r.method} ${r.path}'), [
        'GET /customers',
        'POST /customers',
        'PATCH /customers/customer-1',
        'GET /customers/customer-1/ledger',
        'DELETE /customers/customer-1',
      ]);
      expect(requests[1].headers['Idempotency-Key'], isNotEmpty);
      expect((requests[2].data as Map)['version'], 1);
    },
  );
}

Map<String, dynamic> _party() => {
  'id': 'customer-1',
  'farm_id': 'farm-1',
  'code': 'CUS-00001',
  'name': 'Milk Buyer',
  'customer_type': 'shop',
  'credit_limit': '5000.00',
  'opening_balance': '1200.00',
  'current_balance': '1200.00',
  'version': 1,
  'is_active': true,
};
Map<String, dynamic> _ledger() => {
  'occurred_at': '2026-08-12T10:00:00Z',
  'entry_type': 'opening_balance',
  'debit': '1200.00',
  'credit': '0.00',
  'balance_after': '1200.00',
  'description': 'Opening balance',
};

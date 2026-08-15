import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/commerce/data/delivery_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

void main() {
  test(
    'delivery repository covers setup planning dispatch and completion',
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
            if (o.path == '/deliveries/export.xlsx') {
              h.resolve(
                Response<Object>(
                  requestOptions: o,
                  statusCode: 200,
                  data: Uint8List.fromList([80, 75, 3, 4]),
                ),
              );
              return;
            }
            h.resolve(
              Response<Object>(
                requestOptions: o,
                statusCode: 200,
                data: {
                  'data': o.path.endsWith('/refunds')
                      ? {'id': 'ref1'}
                      : o.method == 'GET'
                      ? _overview()
                      : {},
                },
              ),
            );
          },
        ),
      );
      final repo = DeliveryRepository(api: api);
      final result = await repo.overview();
      await repo.createRoute({'name': 'City', 'stops': []});
      await repo.createVehicle({
        'registration_number': 'ABC-1',
        'capacity_litres': '20',
      });
      await repo.createDriver({'name': 'Ali'});
      await repo.createManifest({
        'milk_sale_ids': ['s1'],
      });
      await repo.dispatch('m1', '10');
      await repo.completeStop('m1', 'ms1', {'status': 'delivered'});
      await repo.uploadProof(
        'm1',
        'ms1',
        Uint8List.fromList([1, 2, 3]),
        'proof.jpg',
      );
      expect(await repo.refund('m1', 'ms1', {'amount': '100'}), 'ref1');
      await repo.export(
        from: DateTime(2026, 8, 1),
        to: DateTime(2026, 8, 31),
        status: 'delivered',
      );
      expect(result.sales.single.number, 'MS-1');
      expect(requests.map((x) => '${x.method} ${x.path}'), [
        'GET /deliveries',
        'POST /delivery-routes',
        'POST /delivery-vehicles',
        'POST /delivery-drivers',
        'POST /delivery-manifests',
        'POST /delivery-manifests/m1/dispatch',
        'POST /delivery-manifests/m1/stops/ms1/complete',
        'POST /delivery-manifests/m1/stops/ms1/proof',
        'POST /delivery-manifests/m1/stops/ms1/refunds',
        'GET /deliveries/export.xlsx',
      ]);
      expect(
        requests
            .where((x) => x.method == 'POST')
            .every((x) => x.headers['Idempotency-Key'] != null),
        isTrue,
      );
    },
  );
}

Map<String, dynamic> _overview() => {
  'routes': [],
  'vehicles': [],
  'drivers': [],
  'manifests': [],
  'eligible_sales': [
    {
      'id': 's1',
      'invoice_number': 'MS-1',
      'quantity_litres': '10.000',
      'customer': {'id': 'c1', 'name': 'Shop'},
    },
  ],
};

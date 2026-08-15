import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/animals/data/animal_sales_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('purchase and sale submissions use authenticated API routes', () async {
    final requests = <RequestOptions>[];
    final dio = Dio();
    final api = ApiClient(
      config: EnvironmentConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: Uri.parse('http://example.test/api/v1'),
      ),
      readAccessToken: () async => 'session-token',
      dio: dio,
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response<Object>(
              requestOptions: options,
              statusCode: 201,
              data: {
                'data': options.path == '/animal-purchases'
                    ? {
                        'id': 'purchase-1',
                        'animal_id': 'animal-1',
                        'animal_number': 'AN-000001',
                      }
                    : {'id': 'sale-1'},
              },
            ),
          );
        },
      ),
    );
    final repository = AnimalSalesRepository(apiClient: api);

    final purchase = await repository.createPurchase({'purchase_price': 1});
    await repository.createSale({'sale_price': 1});

    expect(purchase['animal_number'], 'AN-000001');
    expect(requests.map((request) => request.path), [
      '/animal-purchases',
      '/animal-sales',
    ]);
    expect(
      requests.every(
        (request) => request.headers['Authorization'] == 'Bearer session-token',
      ),
      isTrue,
    );
  });
}

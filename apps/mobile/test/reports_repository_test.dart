import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/reports/data/reports_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'daily report uses the authenticated API-relative route and query',
    () async {
      RequestOptions? request;
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
            request = options;
            handler.resolve(
              Response<Object>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    {
                      'animal_id': 'animal-1',
                      'animal_number': 'AN-000001',
                      'animal_name': 'Noor',
                      'date': '2026-08-10',
                      'total_feed_kg': 8.5,
                      'total_milk_litres': 12.25,
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final records = await ReportsRepository(
        api,
      ).getDailyProduction(DateTime(2026, 8, 10));

      expect(request?.path, '/reports/daily-animal-production');
      expect(request?.queryParameters, {'date': '2026-08-10'});
      expect(request?.headers['Authorization'], 'Bearer session-token');
      expect(records.single.totalMilkLitres, 12.25);
    },
  );
}

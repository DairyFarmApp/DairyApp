import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/feed/data/feed_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'feed repository creates and reloads ration plans and daily issues',
    () async {
      final requests = <RequestOptions>[];
      final repository = FeedRepository(api: _api(requests));

      final plans = await repository.fetchRationPlans();
      final plan = await repository.createRationPlan(const {
        'name': 'Morning ration',
        'effective_date': '2026-08-11',
        'feeding_frequency': 2,
        'ingredients': <Map<String, dynamic>>[],
      });
      final loadedPlan = await repository.fetchRationPlan(plan.id);
      final issues = await repository.fetchDailyFeedIssues();
      final issue = await repository.createDailyFeedIssue(const {
        'date': '2026-08-11',
        'inventory_item_id': 'feed-1',
        'planned_quantity': '50.000',
        'issued_quantity': '48.000',
        'consumed_quantity': '45.000',
        'wasted_quantity': '2.000',
        'returned_quantity': '1.000',
      });

      expect(plans.single.name, 'Morning ration');
      expect(loadedPlan.id, plan.id);
      expect(issues.single.issuedQuantity, '48.000');
      expect(issue.consumedQuantity, '45.000');
      expect(
        requests.map((request) => '${request.method} ${request.path}'),
        containsAll([
          'GET /feed-ration-plans',
          'POST /feed-ration-plans',
          'GET /feed-ration-plans/plan-1',
          'GET /daily-feed-issues',
          'POST /daily-feed-issues',
        ]),
      );
      expect(
        requests.where((request) => request.method == 'POST'),
        everyElement(
          predicate<RequestOptions>(
            (request) => request.headers['Idempotency-Key'] != null,
          ),
        ),
      );
    },
  );
}

ApiClient _api(List<RequestOptions> requests) {
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
      onRequest: (options, handler) {
        requests.add(options);
        final data = options.path.startsWith('/feed-ration-plans')
            ? _plan()
            : _issue();
        handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: options.method == 'POST' ? 201 : 200,
            data: {
              'data':
                  options.method == 'GET' &&
                      (options.path == '/feed-ration-plans' ||
                          options.path == '/daily-feed-issues')
                  ? [data]
                  : data,
            },
          ),
        );
      },
    ),
  );
  return api;
}

Map<String, dynamic> _plan() => {
  'id': 'plan-1',
  'name': 'Morning ration',
  'animal_group_id': 'group-1',
  'production_stage': 'lactating',
  'effective_date': '2026-08-11',
  'end_date': null,
  'feeding_frequency': 2,
  'version': 1,
  'ingredients': <Map<String, dynamic>>[],
};

Map<String, dynamic> _issue() => {
  'id': 'issue-1',
  'shed_id': 'shed-1',
  'animal_group_id': 'group-1',
  'date': '2026-08-11',
  'inventory_item_id': 'feed-1',
  'planned_quantity': '50.000',
  'issued_quantity': '48.000',
  'consumed_quantity': '45.000',
  'wasted_quantity': '2.000',
  'returned_quantity': '1.000',
  'employee_id': null,
  'notes': 'Morning issue',
  'version': 1,
};

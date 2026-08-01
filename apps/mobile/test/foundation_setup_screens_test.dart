import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/features/farms/application/foundation_providers.dart';
import 'package:dairycare_mobile/features/farms/data/foundation_repository.dart';
import 'package:dairycare_mobile/features/farms/presentation/farm_list_screen.dart';
import 'package:dairycare_mobile/features/sheds/presentation/shed_list_screen.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/animal_fixtures.dart';
import 'helpers/fakes.dart';

void main() {
  late AppDatabase database;
  late FoundationRepository repository;

  setUp(() {
    _TestAuthController.switchedFarmId = null;
    database = AppDatabase(NativeDatabase.memory());
    repository = FoundationRepository(database: database, api: _api());
    FakeAuthController.session = foundationSession(
      permissions: const {
        'farms.view',
        'farms.create',
        'farms.update',
        'sheds.view',
        'sheds.create',
        'sheds.update',
      },
      membershipType: 'primary_owner',
    );
  });

  tearDown(() => database.close());

  testWidgets('farm menu displays the active farm and add farm action', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const FarmListScreen(), repository));
    await tester.pumpAndSettle();

    expect(find.text('Farm profile'), findsOneWidget);
    expect(find.text('North Farm'), findsOneWidget);
    expect(find.byKey(const Key('add_farm_action')), findsOneWidget);
    expect(find.byKey(const Key('edit_farm_action')), findsOneWidget);
  });

  testWidgets('farm menu hides add farm without create permission', (
    tester,
  ) async {
    FakeAuthController.session = foundationSession(
      permissions: const {'farms.view', 'farms.update'},
    );
    await tester.pumpWidget(_app(const FarmListScreen(), repository));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('add_farm_action')), findsNothing);
    expect(find.byKey(const Key('edit_farm_action')), findsOneWidget);
  });

  testWidgets('add farm creates and selects a second farm', (tester) async {
    await tester.pumpWidget(_app(const FarmListScreen(), repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add_farm_action')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('farm_name_field')),
      'South Farm',
    );
    await tester.tap(find.byKey(const Key('save_farm_button')));
    await tester.pumpAndSettle();

    expect(_TestAuthController.switchedFarmId, secondFarmId);
    expect(find.text('South Farm created and selected.'), findsOneWidget);
  });

  testWidgets('add shed creates and immediately displays a farm shed', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const ShedListScreen(), repository));
    await tester.pumpAndSettle();

    expect(find.text('Create your first shed'), findsOneWidget);
    await tester.tap(find.byKey(const Key('add_shed_action')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('shed_name_field')),
      'Main Cow Shed',
    );
    await tester.tap(find.byKey(const Key('save_shed_button')));
    await tester.pumpAndSettle();

    expect(find.text('Main Cow Shed'), findsOneWidget);
    expect(find.text('1 shed'), findsOneWidget);
  });
}

Widget _app(Widget home, FoundationRepository repository) => ProviderScope(
  overrides: [
    authControllerProvider.overrideWith(_TestAuthController.new),
    foundationRepositoryProvider.overrideWithValue(repository),
  ],
  child: MaterialApp(home: home),
);

ApiClient _api() {
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
        final now = '2026-08-01T10:00:00Z';
        final farm = {
          'id': farmId,
          'organization_id': organizationId,
          'name': 'North Farm',
          'timezone': 'Asia/Karachi',
          'version': 1,
          'updated_at': now,
          'is_deleted': false,
        };
        if (options.method == 'POST' && options.path == '/farms') {
          final data = options.data as Map<String, dynamic>;
          handler.resolve(
            Response<Object>(
              requestOptions: options,
              statusCode: 201,
              data: {
                'data': {
                  'id': secondFarmId,
                  'organization_id': organizationId,
                  'name': data['name'],
                  'timezone': data['timezone'],
                  'version': 1,
                  'updated_at': now,
                  'is_deleted': false,
                },
              },
            ),
          );
          return;
        }
        if (options.path == '/farms/$farmId') {
          handler.resolve(
            Response<Object>(
              requestOptions: options,
              statusCode: 200,
              data: {'data': farm},
            ),
          );
          return;
        }
        if (options.method == 'GET') {
          handler.resolve(
            Response<Object>(
              requestOptions: options,
              statusCode: 200,
              data: {'data': <Object>[]},
            ),
          );
          return;
        }
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: 201,
            data: {
              'data': {
                'id': (options.data as Map<String, dynamic>)['id'],
                'organization_id': organizationId,
                'farm_id': farmId,
                'name': (options.data as Map<String, dynamic>)['name'],
                'version': 1,
                'updated_at': now,
                'is_deleted': false,
              },
            },
          ),
        );
      },
    ),
  );
  return api;
}

const secondFarmId = '018f0000-0000-7000-8000-000000000030';

final class _TestAuthController extends FakeAuthController {
  static String? switchedFarmId;

  @override
  Future<void> reload() async {}

  @override
  Future<void> switchFarm(String farmId) async {
    switchedFarmId = farmId;
  }
}

import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/features/farms/data/foundation_repository.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test(
    'offline farm write and outbox enqueue are persisted together',
    () async {
      final repository = FoundationRepository(
        database: database,
        api: _offlineApi(),
      );
      final farmId = await repository.createFarmOffline(
        organizationId: '018f0000-0000-7000-8000-000000000010',
        deviceId: '018f0000-0000-7000-8000-000000000099',
        name: 'North Farm',
        timezone: 'Asia/Karachi',
      );

      final farm = await (database.select(
        database.localFarms,
      )..where((row) => row.id.equals(farmId))).getSingle();
      final operation = await database.select(database.syncOutbox).getSingle();
      expect(farm.name, 'North Farm');
      expect(operation.aggregateId, farmId);
      expect(operation.state, 'pending');
      expect(await database.watchPendingOperationCount().first, 1);
    },
  );

  test(
    'offline shed creation initializes its device and queues the shed',
    () async {
      final repository = FoundationRepository(
        database: database,
        api: _offlineApi(),
      );

      final result = await repository.createShed(
        organizationId: '018f0000-0000-7000-8000-000000000010',
        farmId: '018f0000-0000-7000-8000-000000000020',
        name: 'Main Cow Shed',
      );

      expect(result.queuedOffline, isTrue);
      expect(result.shed.name, 'Main Cow Shed');
      expect(await database.select(database.syncDevices).get(), hasLength(1));
      final operation = await database.select(database.syncOutbox).getSingle();
      expect(operation.aggregateType, 'shed');
      expect(
        operation.path,
        '/farms/018f0000-0000-7000-8000-000000000020/sheds',
      );
    },
  );
}

ApiClient _offlineApi() {
  final dio = Dio();
  final api = ApiClient(
    config: EnvironmentConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: Uri.parse('http://offline.test/api/v1'),
    ),
    readAccessToken: () async => 'token',
    dio: dio,
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'offline',
        ),
      ),
    ),
  );
  return api;
}

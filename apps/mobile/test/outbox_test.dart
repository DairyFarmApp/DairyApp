import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/features/farms/data/foundation_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test(
    'offline farm write and outbox enqueue are persisted together',
    () async {
      final repository = FoundationRepository(database);
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
}

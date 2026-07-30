import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/sync/sync_service.dart';
import 'package:dairycare_mobile/features/milk/data/milk_repository.dart';
import 'package:dairycare_mobile/features/milk/domain/milk_models.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('daily milk repository loads totals and saves a bulk entry', () async {
    final requests = <RequestOptions>[];
    final repository = MilkRepository(database: database, api: _api(requests));

    final daily = await repository.daily(
      organizationId: 'org-1',
      farmId: 'farm-1',
      date: DateTime(2026, 7, 30),
      session: MilkingSession.morning,
    );
    final result = await repository.saveBulk(
      organizationId: 'org-1',
      farmId: 'farm-1',
      productionDate: DateTime(2026, 7, 30),
      session: MilkingSession.morning,
      drafts: const [
        MilkEntryDraft(
          animal: MilkEligibleAnimal(
            id: 'animal-1',
            animalNumber: 'AN-001',
            name: 'Noor',
            shedId: 'shed-1',
            shedName: 'Milking Shed',
          ),
          quantityLitres: '12.500',
          rejectedQuantityLitres: '0.500',
          rejectionReason: 'Quality sample',
        ),
      ],
    );

    expect(daily.summary.sellableLitres, '12.000');
    expect(daily.eligibleAnimals.single.animalNumber, 'AN-001');
    expect(result.queuedOffline, isFalse);
    expect(requests.map((request) => '${request.method} ${request.path}'), [
      'GET /milk/daily',
      'POST /milk/entries/bulk',
    ]);
    expect(requests.last.headers['Idempotency-Key'], isNotEmpty);
    expect((requests.last.data as Map<String, dynamic>)['session'], 'morning');
    expect(
      await database.select(database.localMilkEntries).get(),
      hasLength(1),
    );
  });

  test('network failure stores milk and outbox atomically for retry', () async {
    final repository = MilkRepository(
      database: database,
      api: _api(<RequestOptions>[], offline: true),
    );

    final result = await repository.saveBulk(
      organizationId: 'org-1',
      farmId: 'farm-1',
      productionDate: DateTime(2026, 7, 30),
      session: MilkingSession.evening,
      drafts: const [
        MilkEntryDraft(
          animal: MilkEligibleAnimal(
            id: 'animal-1',
            animalNumber: 'AN-001',
            shedId: 'shed-1',
          ),
          quantityLitres: '9.250',
        ),
      ],
    );

    final local = await database.select(database.localMilkEntries).getSingle();
    final outbox = await database.select(database.syncOutbox).getSingle();
    expect(result.queuedOffline, isTrue);
    expect(local.quantityLitres, '9.250');
    expect(local.syncState, 'pending');
    expect(outbox.path, '/milk/entries/bulk');
    expect(outbox.aggregateType, 'milk_entry_batch');
    expect(outbox.payloadJson, contains('"entry_source":"offline"'));
  });

  test('sync pull upserts the authorized current milk revision', () async {
    await SyncService(
      database: database,
      api: _syncApi(),
    ).synchronize(organizationId: 'org-1');

    final local = await database.select(database.localMilkEntries).getSingle();
    expect(local.entryId, 'entry-1');
    expect(local.slotId, 'slot-1');
    expect(local.quantityLitres, '12.500');
    expect(local.syncState, 'synced');
    expect(local.isAccessible, isTrue);
  });
}

ApiClient _api(List<RequestOptions> requests, {bool offline = false}) {
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
        if (offline) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              error: 'offline',
            ),
          );
          return;
        }
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: options.method == 'POST' ? 201 : 200,
            data: options.method == 'GET'
                ? {
                    'data': {
                      'date': '2026-07-30',
                      'session': 'morning',
                      'summary': _summary(),
                      'eligible_animals': [_animal()],
                      'entries': [_entry()],
                    },
                  }
                : {
                    'data': [_entry()],
                  },
          ),
        );
      },
    ),
  );
  return api;
}

ApiClient _syncApi() {
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
      onRequest: (options, handler) => handler.resolve(
        Response<Object>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'data': {
              'organizations': <Object>[],
              'farms': <Object>[],
              'sheds': <Object>[],
              'animal_species': <Object>[],
              'animal_breeds': <Object>[],
              'animal_groups': <Object>[],
              'animals': <Object>[],
              'animal_movements': <Object>[],
              'animal_movements_authorized': false,
              'animal_weights': <Object>[],
              'animal_weights_authorized': false,
              'animal_status_changes': <Object>[],
              'animal_status_changes_authorized': false,
              'milk_entries': [_entry()],
              'milk_entries_authorized': true,
              'authorized_farm_ids': ['farm-1'],
              'next_cursor': 'cursor-1',
            },
          },
        ),
      ),
    ),
  );
  return api;
}

Map<String, Object> _summary() => {
  'total_litres': '12.500',
  'rejected_litres': '0.500',
  'sellable_litres': '12.000',
  'entry_count': 1,
  'animals_recorded': 1,
  'yesterday_sellable_litres': '10.000',
  'seven_day_daily_average_litres': '11.250',
};

Map<String, Object?> _animal() => {
  'id': 'animal-1',
  'animal_number': 'AN-001',
  'name': 'Noor',
  'shed_id': 'shed-1',
  'shed_name': 'Milking Shed',
};

Map<String, Object?> _entry() => {
  'id': 'entry-1',
  'slot_id': 'slot-1',
  'organization_id': 'org-1',
  'farm_id': 'farm-1',
  'shed_id': 'shed-1',
  'shed_name': 'Milking Shed',
  'animal_id': 'animal-1',
  'animal_number': 'AN-001',
  'animal_name': 'Noor',
  'production_date': '2026-07-30',
  'session': 'morning',
  'quantity_litres': '12.500',
  'rejected_quantity_litres': '0.500',
  'rejection_reason': 'Quality sample',
  'notes': null,
  'entry_source': 'manual',
  'revision': 1,
  'is_current': true,
  'supersedes_entry_id': null,
  'correction_reason': null,
  'recorded_by': 'user-1',
  'recorded_by_name': 'Ayesha',
  'created_at': '2026-07-30T06:00:00Z',
  'updated_at': '2026-07-30T06:00:00Z',
};

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class LocalSessionMetadata extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get activeOrganizationId => text().nullable()();
  TextColumn get activeFarmId => text().nullable()();
  DateTimeColumn get accessExpiresAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalOrganizations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalFarms extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get name => text()();
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalSheds extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get farmId => text()();
  TextColumn get name => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncDevices extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get registeredAt => dateTime().nullable()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncCursors extends Table {
  TextColumn get organizationId => text()();
  TextColumn get collection => text()();
  TextColumn get cursor => text().nullable()();
  DateTimeColumn get lastSuccessfulSyncAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {organizationId, collection};
}

class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get deviceId => text()();
  TextColumn get idempotencyKey => text()();
  TextColumn get aggregateType => text()();
  TextColumn get aggregateId => text()();
  TextColumn get method => text()();
  TextColumn get path => text()();
  TextColumn get payloadJson => text()();
  TextColumn get dependencyIdsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {organizationId, deviceId, idempotencyKey},
  ];
}

class SyncConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get operationId => text()();
  TextColumn get aggregateType => text()();
  TextColumn get aggregateId => text()();
  TextColumn get localPayloadJson => text()();
  TextColumn get serverPayloadJson => text()();
  TextColumn get reason => text()();
  TextColumn get resolutionState =>
      text().withDefault(const Constant('unresolved'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalApplicationSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    LocalSessionMetadata,
    LocalOrganizations,
    LocalFarms,
    LocalSheds,
    SyncDevices,
    SyncCursors,
    SyncOutbox,
    SyncConflicts,
    LocalApplicationSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'dairycare'));

  @override
  int get schemaVersion => 1;

  Stream<int> watchPendingOperationCount() {
    final count = syncOutbox.id.count();
    final query = selectOnly(syncOutbox)
      ..addColumns([count])
      ..where(syncOutbox.state.isIn(['pending', 'uploading', 'failed']));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  Stream<List<SyncConflict>> watchUnresolvedConflicts() => (select(
    syncConflicts,
  )..where((row) => row.resolutionState.equals('unresolved'))).watch();

  Future<void> enqueue(SyncOutboxCompanion operation) =>
      into(syncOutbox).insert(operation);

  Future<void> upsertFarmAndEnqueue(
    LocalFarmsCompanion farm,
    SyncOutboxCompanion operation,
  ) => transaction(() async {
    await into(localFarms).insertOnConflictUpdate(farm);
    await into(syncOutbox).insert(operation);
  });

  Future<void> upsertShedAndEnqueue(
    LocalShedsCompanion shed,
    SyncOutboxCompanion operation,
  ) => transaction(() async {
    await into(localSheds).insertOnConflictUpdate(shed);
    await into(syncOutbox).insert(operation);
  });

  Future<List<SyncOutboxData>> dueOperations(
    String organizationId,
    DateTime now,
  ) =>
      (select(syncOutbox)
            ..where(
              (row) =>
                  row.organizationId.equals(organizationId) &
                  (row.state.equals('pending') |
                      (row.state.equals('failed') &
                          row.nextAttemptAt.isNotNull() &
                          row.nextAttemptAt.isSmallerOrEqualValue(now))),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .get();
}

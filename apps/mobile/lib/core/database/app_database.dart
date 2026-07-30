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

class LocalAnimalSpecies extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAnimalBreeds extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get speciesId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAnimalGroups extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get farmId => text()();
  TextColumn get defaultShedId => text().nullable()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isAccessible => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAnimals extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get animalNumber => text()();
  TextColumn get earTagNumber => text().nullable()();
  TextColumn get rfidNumber => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get registrationNumber => text().nullable()();
  TextColumn get speciesId => text()();
  TextColumn get speciesName => text()();
  TextColumn get breedId => text()();
  TextColumn get breedName => text()();
  TextColumn get sex => text()();
  TextColumn get lifeStage => text()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  BoolColumn get isDateOfBirthEstimated =>
      boolean().withDefault(const Constant(false))();
  TextColumn get colour => text().nullable()();
  TextColumn get identifyingMarks => text().nullable()();
  TextColumn get currentFarmId => text()();
  TextColumn get currentFarmName => text()();
  TextColumn get currentShedId => text()();
  TextColumn get currentShedName => text()();
  TextColumn get currentAnimalGroupId => text().nullable()();
  TextColumn get currentAnimalGroupName => text().nullable()();
  TextColumn get motherAnimalId => text().nullable()();
  TextColumn get motherAnimalNumber => text().nullable()();
  TextColumn get fatherAnimalId => text().nullable()();
  TextColumn get fatherAnimalNumber => text().nullable()();
  TextColumn get externalSireReference => text().nullable()();
  TextColumn get origin => text()();
  DateTimeColumn get acquisitionDate => dateTime().nullable()();
  TextColumn get sourceDescription => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get operationalStatus => text()();
  TextColumn get latestWeightId => text().nullable()();
  TextColumn get latestWeightKg => text().nullable()();
  DateTimeColumn get latestWeightObservedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isAccessible => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAnimalMovements extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get animalId => text()();
  TextColumn get animalNumber => text()();
  TextColumn get sourceFarmId => text()();
  TextColumn get sourceFarmName => text()();
  TextColumn get sourceShedId => text()();
  TextColumn get sourceShedName => text()();
  TextColumn get sourceAnimalGroupId => text().nullable()();
  TextColumn get sourceAnimalGroupName => text().nullable()();
  TextColumn get destinationFarmId => text()();
  TextColumn get destinationFarmName => text()();
  TextColumn get destinationShedId => text()();
  TextColumn get destinationShedName => text()();
  TextColumn get destinationAnimalGroupId => text().nullable()();
  TextColumn get destinationAnimalGroupName => text().nullable()();
  DateTimeColumn get requestedEffectiveAt => dateTime()();
  DateTimeColumn get actualEffectiveAt => dateTime().nullable()();
  TextColumn get reason => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text()();
  BoolColumn get approvalRequired =>
      boolean().withDefault(const Constant(true))();
  TextColumn get requestedBy => text()();
  TextColumn get requestedByName => text()();
  TextColumn get decidedBy => text().nullable()();
  TextColumn get decidedByName => text().nullable()();
  DateTimeColumn get decisionAt => dateTime().nullable()();
  TextColumn get rejectionReason => text().nullable()();
  TextColumn get cancellationReason => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();
  BoolColumn get isAccessible => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAnimalWeights extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get farmId => text()();
  TextColumn get farmName => text()();
  TextColumn get animalId => text()();
  TextColumn get animalNumber => text()();
  TextColumn get enteredValue => text()();
  TextColumn get enteredUnit => text()();
  TextColumn get normalizedKg => text()();
  DateTimeColumn get observedAt => dateTime()();
  TextColumn get source => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get recordedBy => text()();
  TextColumn get recordedByName => text()();
  TextColumn get supersedesWeightId => text().nullable()();
  TextColumn get supersededByWeightId => text().nullable()();
  TextColumn get correctionReason => text().nullable()();
  BoolColumn get isSuperseded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();
  BoolColumn get isAccessible => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAnimalStatusChanges extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get farmId => text()();
  TextColumn get farmName => text()();
  TextColumn get animalId => text()();
  TextColumn get animalNumber => text()();
  TextColumn get previousStatus => text()();
  TextColumn get newStatus => text()();
  DateTimeColumn get effectiveAt => dateTime()();
  TextColumn get reason => text()();
  TextColumn get changedBy => text()();
  TextColumn get changedByName => text()();
  IntColumn get sequence => integer()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();
  BoolColumn get isAccessible => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalMilkEntries extends Table {
  TextColumn get slotId => text()();
  TextColumn get entryId => text()();
  TextColumn get organizationId => text()();
  TextColumn get farmId => text()();
  TextColumn get shedId => text()();
  TextColumn get shedName => text().nullable()();
  TextColumn get animalId => text()();
  TextColumn get animalNumber => text()();
  TextColumn get animalName => text().nullable()();
  DateTimeColumn get productionDate => dateTime()();
  TextColumn get session => text()();
  TextColumn get quantityLitres => text()();
  TextColumn get rejectedQuantityLitres =>
      text().withDefault(const Constant('0.000'))();
  TextColumn get rejectionReason => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get entrySource => text().withDefault(const Constant('manual'))();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get correctionReason => text().nullable()();
  TextColumn get recordedBy => text().nullable()();
  TextColumn get recordedByName => text().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('synced'))();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();
  BoolColumn get isAccessible => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {slotId};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {entryId},
  ];
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
    LocalAnimalSpecies,
    LocalAnimalBreeds,
    LocalAnimalGroups,
    LocalAnimals,
    LocalAnimalMovements,
    LocalAnimalWeights,
    LocalAnimalStatusChanges,
    LocalMilkEntries,
    SyncDevices,
    SyncCursors,
    SyncOutbox,
    SyncConflicts,
    LocalApplicationSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'dairycare',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(localAnimalSpecies);
        await migrator.createTable(localAnimalBreeds);
        await migrator.createTable(localAnimalGroups);
        await migrator.createTable(localAnimals);
      }
      if (from < 3) {
        await migrator.createTable(localAnimalMovements);
      }
      if (from < 4) {
        await migrator.addColumn(localAnimals, localAnimals.latestWeightId);
        await migrator.addColumn(localAnimals, localAnimals.latestWeightKg);
        await migrator.addColumn(
          localAnimals,
          localAnimals.latestWeightObservedAt,
        );
        await migrator.createTable(localAnimalWeights);
        await migrator.createTable(localAnimalStatusChanges);
      }
      if (from < 5) {
        await migrator.createTable(localMilkEntries);
      }
    },
  );

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

  Stream<List<LocalAnimal>> watchAnimals({
    required String organizationId,
    String? farmId,
    String search = '',
    String? speciesId,
    String? breedId,
    String? sex,
    String? lifeStage,
    String? shedId,
    String? groupId,
    String? operationalStatus,
    String archiveState = 'active',
  }) {
    final query = select(localAnimals)
      ..where(
        (row) =>
            row.organizationId.equals(organizationId) &
            row.isAccessible.equals(true),
      );
    if (archiveState == 'active') {
      query.where((row) => row.isArchived.equals(false));
    } else if (archiveState == 'archived') {
      query.where((row) => row.isArchived.equals(true));
    }
    if (farmId != null) {
      query.where((row) => row.currentFarmId.equals(farmId));
    }
    if (speciesId != null) {
      query.where((row) => row.speciesId.equals(speciesId));
    }
    if (breedId != null) {
      query.where((row) => row.breedId.equals(breedId));
    }
    if (sex != null) {
      query.where((row) => row.sex.equals(sex));
    }
    if (lifeStage != null) {
      query.where((row) => row.lifeStage.equals(lifeStage));
    }
    if (shedId != null) {
      query.where((row) => row.currentShedId.equals(shedId));
    }
    if (groupId != null) {
      query.where((row) => row.currentAnimalGroupId.equals(groupId));
    }
    if (operationalStatus != null) {
      query.where((row) => row.operationalStatus.equals(operationalStatus));
    }
    final trimmedSearch = search.trim();
    if (trimmedSearch.isNotEmpty) {
      final pattern =
          '%${trimmedSearch.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
      query.where(
        (row) =>
            row.animalNumber.like(pattern) |
            row.earTagNumber.like(pattern) |
            row.rfidNumber.like(pattern) |
            row.name.like(pattern),
      );
    }
    query.orderBy([(row) => OrderingTerm.asc(row.animalNumber)]);

    return query.watch();
  }

  Stream<List<LocalAnimalMovement>> watchAnimalMovements({
    required String organizationId,
    required String animalId,
  }) {
    final query = select(localAnimalMovements)
      ..where(
        (row) =>
            row.organizationId.equals(organizationId) &
            row.animalId.equals(animalId) &
            row.isAccessible.equals(true),
      )
      ..orderBy([
        (row) => OrderingTerm.desc(row.requestedEffectiveAt),
        (row) => OrderingTerm.desc(row.id),
      ]);

    return query.watch();
  }

  Stream<List<LocalAnimalWeight>> watchAnimalWeights({
    required String organizationId,
    required String animalId,
  }) {
    final query = select(localAnimalWeights)
      ..where(
        (row) =>
            row.organizationId.equals(organizationId) &
            row.animalId.equals(animalId) &
            row.isAccessible.equals(true),
      )
      ..orderBy([
        (row) => OrderingTerm.desc(row.observedAt),
        (row) => OrderingTerm.desc(row.serverUpdatedAt),
        (row) => OrderingTerm.desc(row.id),
      ])
      ..limit(250);

    return query.watch();
  }

  Stream<List<LocalAnimalStatusChange>> watchAnimalStatusChanges({
    required String organizationId,
    required String animalId,
  }) {
    final query = select(localAnimalStatusChanges)
      ..where(
        (row) =>
            row.organizationId.equals(organizationId) &
            row.animalId.equals(animalId) &
            row.isAccessible.equals(true),
      )
      ..orderBy([
        (row) => OrderingTerm.desc(row.sequence),
        (row) => OrderingTerm.desc(row.id),
      ])
      ..limit(250);

    return query.watch();
  }

  Stream<List<LocalMilkEntry>> watchMilkEntries({
    required String organizationId,
    required String farmId,
    required DateTime fromDate,
    required DateTime toDate,
    String? session,
  }) {
    final query = select(localMilkEntries)
      ..where(
        (row) =>
            row.organizationId.equals(organizationId) &
            row.farmId.equals(farmId) &
            row.productionDate.isBiggerOrEqualValue(fromDate) &
            row.productionDate.isSmallerOrEqualValue(toDate) &
            row.isAccessible.equals(true),
      );
    if (session != null) {
      query.where((row) => row.session.equals(session));
    }
    query.orderBy([
      (row) => OrderingTerm.desc(row.productionDate),
      (row) => OrderingTerm.asc(row.session),
      (row) => OrderingTerm.asc(row.animalNumber),
    ]);

    return query.watch();
  }

  Future<void> upsertMilkEntriesAndEnqueue(
    List<LocalMilkEntriesCompanion> entries,
    SyncOutboxCompanion operation,
  ) => transaction(() async {
    for (final entry in entries) {
      await into(localMilkEntries).insertOnConflictUpdate(entry);
    }
    await into(syncOutbox).insert(operation);
  });
}

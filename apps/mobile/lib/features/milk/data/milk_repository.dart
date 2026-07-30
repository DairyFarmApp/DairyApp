import 'dart:convert';

import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/features/milk/domain/milk_models.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final class MilkRepository {
  MilkRepository({
    required AppDatabase database,
    required ApiClient api,
    Uuid uuid = const Uuid(),
  }) : _database = database,
       _api = api,
       _uuid = uuid;

  final AppDatabase _database;
  final ApiClient _api;
  final Uuid _uuid;
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Future<MilkDailyData> daily({
    required String organizationId,
    required String farmId,
    required DateTime date,
    required MilkingSession session,
  }) async {
    try {
      final body = await _api.getJson(
        '/milk/daily',
        query: {'date': _dateFormat.format(date), 'session': session.apiValue},
      );
      final data = body['data'] as Map<String, dynamic>;
      final entries = _maps(
        data['entries'],
      ).map(MilkEntry.fromJson).toList(growable: false);
      await _upsertEntries(entries);
      return MilkDailyData(
        date: date,
        session: session,
        summary: MilkDailySummary.fromJson(
          data['summary'] as Map<String, dynamic>,
        ),
        eligibleAnimals: _maps(
          data['eligible_animals'],
        ).map(MilkEligibleAnimal.fromJson).toList(growable: false),
        entries: entries,
        isCached: false,
      );
    } on NetworkException {
      return _cachedDaily(
        organizationId: organizationId,
        farmId: farmId,
        date: date,
        session: session,
      );
    } on TransientServerException {
      return _cachedDaily(
        organizationId: organizationId,
        farmId: farmId,
        date: date,
        session: session,
      );
    }
  }

  Future<MilkSaveResult> saveBulk({
    required String organizationId,
    required String farmId,
    required DateTime productionDate,
    required MilkingSession session,
    required List<MilkEntryDraft> drafts,
  }) async {
    final idempotencyKey = _uuid.v7();
    final generated = [
      for (final draft in drafts)
        (draft: draft, entryId: _uuid.v7(), slotId: _uuid.v7()),
    ];
    final payload = {
      'production_date': _dateFormat.format(productionDate),
      'session': session.apiValue,
      'entries': [
        for (final item in generated)
          {
            'id': item.entryId,
            'slot_id': item.slotId,
            'animal_id': item.draft.animal.id,
            'quantity_litres': item.draft.quantityLitres,
            'rejected_quantity_litres': item.draft.rejectedQuantityLitres,
            'rejection_reason': item.draft.rejectionReason,
            'notes': item.draft.notes,
            'entry_source': 'manual',
          },
      ],
    };
    try {
      final body = await _api.postJson(
        '/milk/entries/bulk',
        data: payload,
        idempotencyKey: idempotencyKey,
      );
      final entries = _maps(
        body['data'],
      ).map(MilkEntry.fromJson).toList(growable: false);
      await _upsertEntries(entries);
      return MilkSaveResult(entries: entries, queuedOffline: false);
    } on NetworkException {
      return _queueOffline(
        organizationId: organizationId,
        farmId: farmId,
        productionDate: productionDate,
        session: session,
        generated: generated,
        payload: payload,
        idempotencyKey: idempotencyKey,
      );
    } on TransientServerException {
      return _queueOffline(
        organizationId: organizationId,
        farmId: farmId,
        productionDate: productionDate,
        session: session,
        generated: generated,
        payload: payload,
        idempotencyKey: idempotencyKey,
      );
    }
  }

  Future<MilkEntry> correct({
    required MilkEntry entry,
    required String quantityLitres,
    required String rejectedQuantityLitres,
    String? rejectionReason,
    String? notes,
    required String correctionReason,
  }) async {
    final body = await _api.postJson(
      '/milk/entries/${entry.id}/correct',
      data: {
        'id': _uuid.v7(),
        'quantity_litres': quantityLitres,
        'rejected_quantity_litres': rejectedQuantityLitres,
        'rejection_reason': rejectionReason,
        'notes': notes,
        'correction_reason': correctionReason,
      },
      idempotencyKey: _uuid.v7(),
    );
    final corrected = MilkEntry.fromJson(body['data'] as Map<String, dynamic>);
    await _upsertEntries([corrected]);
    return corrected;
  }

  Future<MilkSaveResult> _queueOffline({
    required String organizationId,
    required String farmId,
    required DateTime productionDate,
    required MilkingSession session,
    required List<({MilkEntryDraft draft, String entryId, String slotId})>
    generated,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  }) async {
    final deviceId = await _deviceId();
    final now = DateTime.now().toUtc();
    final local = [
      for (final item in generated)
        LocalMilkEntriesCompanion.insert(
          slotId: item.slotId,
          entryId: item.entryId,
          organizationId: organizationId,
          farmId: farmId,
          shedId: item.draft.animal.shedId,
          shedName: Value(item.draft.animal.shedName),
          animalId: item.draft.animal.id,
          animalNumber: item.draft.animal.animalNumber,
          animalName: Value(item.draft.animal.name),
          productionDate: _dateOnly(productionDate),
          session: session.apiValue,
          quantityLitres: item.draft.quantityLitres,
          rejectedQuantityLitres: Value(item.draft.rejectedQuantityLitres),
          rejectionReason: Value(item.draft.rejectionReason),
          notes: Value(item.draft.notes),
          entrySource: const Value('offline'),
          syncState: const Value('pending'),
          serverUpdatedAt: now,
          cachedAt: now,
        ),
    ];
    await _database.upsertMilkEntriesAndEnqueue(
      local,
      SyncOutboxCompanion.insert(
        id: _uuid.v7(),
        organizationId: organizationId,
        farmId: Value(farmId),
        deviceId: deviceId,
        idempotencyKey: idempotencyKey,
        aggregateType: 'milk_entry_batch',
        aggregateId: generated.first.slotId,
        method: 'POST',
        path: '/milk/entries/bulk',
        payloadJson: jsonEncode({
          ...payload,
          'entries': [
            for (final entry in payload['entries']! as List)
              {...entry as Map<String, dynamic>, 'entry_source': 'offline'},
          ],
        }),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return MilkSaveResult(
      entries: local.map((row) => _fromPending(row)).toList(growable: false),
      queuedOffline: true,
    );
  }

  Future<MilkDailyData> _cachedDaily({
    required String organizationId,
    required String farmId,
    required DateTime date,
    required MilkingSession session,
  }) async {
    final end = _dateOnly(date);
    final start = end.subtract(const Duration(days: 6));
    final rows = await _database
        .watchMilkEntries(
          organizationId: organizationId,
          farmId: farmId,
          fromDate: start,
          toDate: end,
          session: session.apiValue,
        )
        .first;
    final entries = rows
        .where((row) => _sameDate(row.productionDate, end))
        .map(_fromLocal)
        .toList(growable: false);
    final animals =
        await (_database.select(_database.localAnimals)
              ..where(
                (row) =>
                    row.organizationId.equals(organizationId) &
                    row.currentFarmId.equals(farmId) &
                    row.sex.equals('female') &
                    row.lifeStage.equals('adult') &
                    row.operationalStatus.equals('active') &
                    row.isArchived.equals(false) &
                    row.isAccessible.equals(true),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.animalNumber)]))
            .get();
    final yesterday = end.subtract(const Duration(days: 1));
    final selectedRows = rows.where(
      (row) => _sameDate(row.productionDate, end),
    );
    final yesterdayRows = rows.where(
      (row) => _sameDate(row.productionDate, yesterday),
    );
    final total = _sum(selectedRows, (row) => row.quantityLitres);
    final rejected = _sum(selectedRows, (row) => row.rejectedQuantityLitres);
    final yesterdaySellable =
        _sum(yesterdayRows, (row) => row.quantityLitres) -
        _sum(yesterdayRows, (row) => row.rejectedQuantityLitres);
    final sevenDaySellable =
        _sum(rows, (row) => row.quantityLitres) -
        _sum(rows, (row) => row.rejectedQuantityLitres);
    return MilkDailyData(
      date: date,
      session: session,
      summary: MilkDailySummary(
        totalLitres: _decimal(total),
        rejectedLitres: _decimal(rejected),
        sellableLitres: _decimal(total - rejected),
        entryCount: selectedRows.length,
        animalsRecorded: selectedRows.map((row) => row.animalId).toSet().length,
        yesterdaySellableLitres: _decimal(yesterdaySellable),
        sevenDayDailyAverageLitres: _decimal(sevenDaySellable / 7),
      ),
      eligibleAnimals: [
        for (final animal in animals)
          MilkEligibleAnimal(
            id: animal.id,
            animalNumber: animal.animalNumber,
            name: animal.name,
            shedId: animal.currentShedId,
            shedName: animal.currentShedName,
          ),
      ],
      entries: entries,
      isCached: true,
    );
  }

  Future<void> _upsertEntries(List<MilkEntry> entries) =>
      _database.transaction(() async {
        final now = DateTime.now().toUtc();
        for (final entry in entries) {
          await _database
              .into(_database.localMilkEntries)
              .insertOnConflictUpdate(
                LocalMilkEntriesCompanion.insert(
                  slotId: entry.slotId,
                  entryId: entry.id,
                  organizationId: entry.organizationId,
                  farmId: entry.farmId,
                  shedId: entry.shedId,
                  shedName: Value(entry.shedName),
                  animalId: entry.animalId,
                  animalNumber: entry.animalNumber,
                  animalName: Value(entry.animalName),
                  productionDate: _dateOnly(entry.productionDate),
                  session: entry.session.apiValue,
                  quantityLitres: entry.quantityLitres,
                  rejectedQuantityLitres: Value(entry.rejectedQuantityLitres),
                  rejectionReason: Value(entry.rejectionReason),
                  notes: Value(entry.notes),
                  entrySource: const Value('manual'),
                  revision: Value(entry.revision),
                  correctionReason: Value(entry.correctionReason),
                  recordedBy: Value(entry.recordedBy),
                  recordedByName: Value(entry.recordedByName),
                  syncState: const Value('synced'),
                  serverUpdatedAt: entry.updatedAt,
                  cachedAt: now,
                  isAccessible: const Value(true),
                ),
              );
        }
      });

  Future<String> _deviceId() async {
    final existing = await _database
        .select(_database.syncDevices)
        .getSingleOrNull();
    if (existing != null) return existing.id;
    final id = _uuid.v7();
    await _database
        .into(_database.syncDevices)
        .insert(
          SyncDevicesCompanion.insert(
            id: id,
            name: 'DairyCare device',
            lastSeenAt: Value(DateTime.now().toUtc()),
          ),
        );
    return id;
  }

  MilkEntry _fromLocal(LocalMilkEntry row) => MilkEntry(
    id: row.entryId,
    slotId: row.slotId,
    organizationId: row.organizationId,
    farmId: row.farmId,
    shedId: row.shedId,
    shedName: row.shedName,
    animalId: row.animalId,
    animalNumber: row.animalNumber,
    animalName: row.animalName,
    productionDate: row.productionDate,
    session: MilkingSession.fromApi(row.session),
    quantityLitres: row.quantityLitres,
    rejectedQuantityLitres: row.rejectedQuantityLitres,
    rejectionReason: row.rejectionReason,
    notes: row.notes,
    revision: row.revision,
    correctionReason: row.correctionReason,
    recordedBy: row.recordedBy,
    recordedByName: row.recordedByName,
    syncState: row.syncState,
    updatedAt: row.serverUpdatedAt,
  );

  MilkEntry _fromPending(LocalMilkEntriesCompanion row) => MilkEntry(
    id: row.entryId.value,
    slotId: row.slotId.value,
    organizationId: row.organizationId.value,
    farmId: row.farmId.value,
    shedId: row.shedId.value,
    shedName: row.shedName.value,
    animalId: row.animalId.value,
    animalNumber: row.animalNumber.value,
    animalName: row.animalName.value,
    productionDate: row.productionDate.value,
    session: MilkingSession.fromApi(row.session.value),
    quantityLitres: row.quantityLitres.value,
    rejectedQuantityLitres: row.rejectedQuantityLitres.value,
    rejectionReason: row.rejectionReason.value,
    notes: row.notes.value,
    revision: 1,
    syncState: 'pending',
    updatedAt: row.serverUpdatedAt.value,
  );

  List<Map<String, dynamic>> _maps(Object? value) =>
      (value as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  double _sum(
    Iterable<LocalMilkEntry> rows,
    String Function(LocalMilkEntry row) value,
  ) => rows.fold(0, (total, row) => total + double.parse(value(row)));

  DateTime _dateOnly(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);

  bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  String _decimal(double value) => value.toStringAsFixed(3);
}

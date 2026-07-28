import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_status_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_weight_models.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class AnimalHistoryLoadResult<T> {
  const AnimalHistoryLoadResult({
    required this.items,
    this.isCached = false,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  final List<T> items;
  final bool isCached;
  final int currentPage;
  final int lastPage;

  bool get hasMore => !isCached && currentPage < lastPage;
}

final class AnimalMeasurementRepository {
  AnimalMeasurementRepository({
    required AppDatabase database,
    required ApiClient api,
    Uuid uuid = const Uuid(),
  }) : _database = database,
       _api = api,
       _uuid = uuid;

  final AppDatabase _database;
  final ApiClient _api;
  final Uuid _uuid;

  Future<AnimalHistoryLoadResult<AnimalWeight>> getWeights({
    required String organizationId,
    required String animalId,
    int page = 1,
  }) async {
    try {
      final body = await _api.getJson(
        '/animals/$animalId/weights',
        query: {'page[size]': 25, 'page[page]': page},
      );
      final items = _maps(
        body['data'],
      ).map(AnimalWeight.fromJson).toList(growable: false);
      await _database.transaction(() async {
        for (final weight in items) {
          await _upsertWeight(weight);
        }
      });
      final pagination = _pagination(body);
      return AnimalHistoryLoadResult(
        items: items,
        currentPage: pagination.$1,
        lastPage: pagination.$2,
      );
    } on NetworkException {
      return _cachedWeights(organizationId, animalId);
    } on TransientServerException {
      return _cachedWeights(organizationId, animalId);
    }
  }

  Future<AnimalWeight> getWeight(String id) async {
    try {
      final body = await _api.getJson('/animal-weights/$id');
      final weight = AnimalWeight.fromJson(
        body['data'] as Map<String, dynamic>,
      );
      await _upsertWeight(weight);
      return weight;
    } on NetworkException {
      return _cachedWeight(id);
    } on TransientServerException {
      return _cachedWeight(id);
    }
  }

  Future<AnimalWeight> recordWeight(
    String animalId,
    AnimalWeightDraft draft,
  ) async {
    final body = await _api.postJson(
      '/animals/$animalId/weights',
      data: draft.toJson(),
      idempotencyKey: _uuid.v7(),
    );
    final weight = AnimalWeight.fromJson(body['data'] as Map<String, dynamic>);
    await _upsertWeight(weight);
    return weight;
  }

  Future<AnimalWeight> correctWeight(
    AnimalWeight weight,
    AnimalWeightCorrectionDraft draft,
  ) async {
    final body = await _api.postJson(
      '/animal-weights/${weight.id}/correct',
      data: draft.toJson(),
      idempotencyKey: _uuid.v7(),
    );
    final replacement = AnimalWeight.fromJson(
      body['data'] as Map<String, dynamic>,
    );
    await _database.transaction(() async {
      await (_database.update(
        _database.localAnimalWeights,
      )..where((row) => row.id.equals(weight.id))).write(
        LocalAnimalWeightsCompanion(
          isSuperseded: const Value(true),
          supersededByWeightId: Value(replacement.id),
          cachedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _upsertWeight(replacement);
    });
    return replacement;
  }

  Future<AnimalHistoryLoadResult<AnimalStatusChange>> getStatusHistory({
    required String organizationId,
    required String animalId,
    int page = 1,
  }) async {
    try {
      final body = await _api.getJson(
        '/animals/$animalId/status-history',
        query: {'page[size]': 25, 'page[page]': page},
      );
      final items = _maps(
        body['data'],
      ).map(AnimalStatusChange.fromJson).toList(growable: false);
      await _database.transaction(() async {
        for (final change in items) {
          await _upsertStatusChange(change);
        }
      });
      final pagination = _pagination(body);
      return AnimalHistoryLoadResult(
        items: items,
        currentPage: pagination.$1,
        lastPage: pagination.$2,
      );
    } on NetworkException {
      return _cachedStatusHistory(organizationId, animalId);
    } on TransientServerException {
      return _cachedStatusHistory(organizationId, animalId);
    }
  }

  Future<AnimalStatusChange> changeStatus(
    String animalId,
    AnimalStatusChangeDraft draft,
  ) async {
    final body = await _api.postJson(
      '/animals/$animalId/status-changes',
      data: draft.toJson(),
      idempotencyKey: _uuid.v7(),
    );
    final change = AnimalStatusChange.fromJson(
      body['data'] as Map<String, dynamic>,
    );
    await _database.transaction(() async {
      await _upsertStatusChange(change);
      await (_database.update(
        _database.localAnimals,
      )..where((row) => row.id.equals(animalId))).write(
        LocalAnimalsCompanion(
          operationalStatus: Value(change.newStatus),
          version: change.animalVersion == null
              ? const Value.absent()
              : Value(change.animalVersion!),
          serverUpdatedAt: Value(change.serverUpdatedAt),
          cachedAt: Value(DateTime.now().toUtc()),
        ),
      );
    });
    return change;
  }

  Future<AnimalHistoryLoadResult<AnimalWeight>> _cachedWeights(
    String organizationId,
    String animalId,
  ) async {
    final rows = await _database
        .watchAnimalWeights(organizationId: organizationId, animalId: animalId)
        .first;
    return AnimalHistoryLoadResult(
      items: rows.map(_weightFromLocal).toList(growable: false),
      isCached: true,
    );
  }

  Future<AnimalWeight> _cachedWeight(String id) async {
    final row =
        await (_database.select(_database.localAnimalWeights)..where(
              (item) => item.id.equals(id) & item.isAccessible.equals(true),
            ))
            .getSingleOrNull();
    if (row == null) {
      throw const NetworkException(
        'The weight record is unavailable offline on this device.',
      );
    }
    return _weightFromLocal(row);
  }

  Future<AnimalHistoryLoadResult<AnimalStatusChange>> _cachedStatusHistory(
    String organizationId,
    String animalId,
  ) async {
    final rows = await _database
        .watchAnimalStatusChanges(
          organizationId: organizationId,
          animalId: animalId,
        )
        .first;
    return AnimalHistoryLoadResult(
      items: rows.map(_statusFromLocal).toList(growable: false),
      isCached: true,
    );
  }

  Future<void> _upsertWeight(AnimalWeight weight) async {
    await _database
        .into(_database.localAnimalWeights)
        .insertOnConflictUpdate(
          LocalAnimalWeightsCompanion.insert(
            id: weight.id,
            organizationId: weight.organizationId,
            farmId: weight.farmId,
            farmName: weight.farmName,
            animalId: weight.animalId,
            animalNumber: weight.animalNumber,
            enteredValue: weight.enteredValue,
            enteredUnit: weight.enteredUnit,
            normalizedKg: weight.normalizedKg,
            observedAt: weight.observedAt,
            source: weight.source,
            notes: Value(weight.notes),
            recordedBy: weight.recordedBy,
            recordedByName: weight.recordedByName,
            supersedesWeightId: Value(weight.supersedesWeightId),
            supersededByWeightId: Value(weight.supersededByWeightId),
            correctionReason: Value(weight.correctionReason),
            isSuperseded: Value(weight.isSuperseded),
            serverUpdatedAt: weight.serverUpdatedAt,
            cachedAt: DateTime.now().toUtc(),
            isAccessible: const Value(true),
          ),
        );
    if (weight.isSuperseded) return;
    final animal = await (_database.select(
      _database.localAnimals,
    )..where((row) => row.id.equals(weight.animalId))).getSingleOrNull();
    final shouldProject =
        animal != null &&
        (animal.latestWeightObservedAt == null ||
            weight.observedAt.isAfter(animal.latestWeightObservedAt!) ||
            (weight.observedAt.isAtSameMomentAs(
                  animal.latestWeightObservedAt!,
                ) &&
                weight.id.compareTo(animal.latestWeightId ?? '') > 0));
    if (shouldProject) {
      await (_database.update(
        _database.localAnimals,
      )..where((row) => row.id.equals(weight.animalId))).write(
        LocalAnimalsCompanion(
          latestWeightId: Value(weight.id),
          latestWeightKg: Value(weight.normalizedKg),
          latestWeightObservedAt: Value(weight.observedAt),
          cachedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }
  }

  Future<void> _upsertStatusChange(AnimalStatusChange change) => _database
      .into(_database.localAnimalStatusChanges)
      .insertOnConflictUpdate(
        LocalAnimalStatusChangesCompanion.insert(
          id: change.id,
          organizationId: change.organizationId,
          farmId: change.farmId,
          farmName: change.farmName,
          animalId: change.animalId,
          animalNumber: change.animalNumber,
          previousStatus: change.previousStatus,
          newStatus: change.newStatus,
          effectiveAt: change.effectiveAt,
          reason: change.reason,
          changedBy: change.changedBy,
          changedByName: change.changedByName,
          sequence: change.sequence,
          serverUpdatedAt: change.serverUpdatedAt,
          cachedAt: DateTime.now().toUtc(),
          isAccessible: const Value(true),
        ),
      );

  AnimalWeight _weightFromLocal(LocalAnimalWeight row) => AnimalWeight(
    id: row.id,
    organizationId: row.organizationId,
    farmId: row.farmId,
    farmName: row.farmName,
    animalId: row.animalId,
    animalNumber: row.animalNumber,
    enteredValue: row.enteredValue,
    enteredUnit: row.enteredUnit,
    normalizedKg: row.normalizedKg,
    observedAt: row.observedAt,
    source: row.source,
    notes: row.notes,
    recordedBy: row.recordedBy,
    recordedByName: row.recordedByName,
    supersedesWeightId: row.supersedesWeightId,
    supersededByWeightId: row.supersededByWeightId,
    correctionReason: row.correctionReason,
    isSuperseded: row.isSuperseded,
    serverUpdatedAt: row.serverUpdatedAt,
  );

  AnimalStatusChange _statusFromLocal(LocalAnimalStatusChange row) =>
      AnimalStatusChange(
        id: row.id,
        organizationId: row.organizationId,
        farmId: row.farmId,
        farmName: row.farmName,
        animalId: row.animalId,
        animalNumber: row.animalNumber,
        previousStatus: row.previousStatus,
        newStatus: row.newStatus,
        effectiveAt: row.effectiveAt,
        reason: row.reason,
        changedBy: row.changedBy,
        changedByName: row.changedByName,
        sequence: row.sequence,
        serverUpdatedAt: row.serverUpdatedAt,
      );

  List<Map<String, dynamic>> _maps(Object? value) =>
      (value as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  (int, int) _pagination(Map<String, dynamic> body) {
    final meta = body['meta'];
    final pagination = meta is Map<String, dynamic> ? meta['pagination'] : null;
    if (pagination is! Map<String, dynamic>) return (1, 1);
    final current = pagination['current_page'];
    final last = pagination['last_page'];
    return (
      current is int && current > 0 ? current : 1,
      last is int && last > 0 ? last : 1,
    );
  }
}

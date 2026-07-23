import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_movement_models.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class AnimalMovementLoadResult {
  const AnimalMovementLoadResult({required this.items, this.isCached = false});

  final List<AnimalMovement> items;
  final bool isCached;
}

final class AnimalMovementRepository {
  AnimalMovementRepository({
    required AppDatabase database,
    required ApiClient api,
    Uuid uuid = const Uuid(),
  }) : _database = database,
       _api = api,
       _uuid = uuid;

  final AppDatabase _database;
  final ApiClient _api;
  final Uuid _uuid;

  Future<AnimalMovementLoadResult> getMovements({
    required String organizationId,
    required String animalId,
  }) async {
    try {
      final body = await _api.getJson(
        '/animals/$animalId/movements',
        query: {'page[size]': 100},
      );
      final items = _maps(
        body['data'],
      ).map(AnimalMovement.fromJson).toList(growable: false);
      await _database.transaction(() async {
        for (final movement in items) {
          await _upsert(movement);
        }
      });
      return AnimalMovementLoadResult(items: items);
    } on NetworkException {
      return _cached(organizationId, animalId);
    } on TransientServerException {
      return _cached(organizationId, animalId);
    }
  }

  Future<AnimalMovement> requestMovement(
    String animalId,
    AnimalMovementDraft draft,
  ) async {
    final body = await _api.postJson(
      '/animals/$animalId/movements',
      data: draft.toJson(),
      idempotencyKey: _uuid.v7(),
    );
    final movement = AnimalMovement.fromJson(
      body['data'] as Map<String, dynamic>,
    );
    await _upsert(movement);
    return movement;
  }

  Future<AnimalMovement> approve(AnimalMovement movement) =>
      _decision(movement, 'approve', {'version': movement.version});

  Future<AnimalMovement> reject(AnimalMovement movement, String reason) =>
      _decision(movement, 'reject', {
        'version': movement.version,
        'reason': reason.trim(),
      });

  Future<AnimalMovement> cancel(AnimalMovement movement, String reason) =>
      _decision(movement, 'cancel', {
        'version': movement.version,
        'reason': reason.trim(),
      });

  Future<AnimalMovement> _decision(
    AnimalMovement movement,
    String action,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.postJson(
      '/animal-movements/${movement.id}/$action',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    final updated = AnimalMovement.fromJson(
      body['data'] as Map<String, dynamic>,
    );
    await _upsert(updated);
    return updated;
  }

  Future<AnimalMovementLoadResult> _cached(
    String organizationId,
    String animalId,
  ) async {
    final rows = await _database
        .watchAnimalMovements(
          organizationId: organizationId,
          animalId: animalId,
        )
        .first;
    return AnimalMovementLoadResult(
      items: rows.map(_fromLocal).toList(growable: false),
      isCached: true,
    );
  }

  Future<void> _upsert(AnimalMovement movement) => _database
      .into(_database.localAnimalMovements)
      .insertOnConflictUpdate(
        LocalAnimalMovementsCompanion.insert(
          id: movement.id,
          organizationId: movement.organizationId,
          animalId: movement.animalId,
          animalNumber: movement.animalNumber,
          sourceFarmId: movement.sourceFarmId,
          sourceFarmName: movement.sourceFarmName,
          sourceShedId: movement.sourceShedId,
          sourceShedName: movement.sourceShedName,
          sourceAnimalGroupId: Value(movement.sourceAnimalGroupId),
          sourceAnimalGroupName: Value(movement.sourceAnimalGroupName),
          destinationFarmId: movement.destinationFarmId,
          destinationFarmName: movement.destinationFarmName,
          destinationShedId: movement.destinationShedId,
          destinationShedName: movement.destinationShedName,
          destinationAnimalGroupId: Value(movement.destinationAnimalGroupId),
          destinationAnimalGroupName: Value(
            movement.destinationAnimalGroupName,
          ),
          requestedEffectiveAt: movement.requestedEffectiveAt,
          actualEffectiveAt: Value(movement.actualEffectiveAt),
          reason: movement.reason,
          notes: Value(movement.notes),
          status: movement.status,
          approvalRequired: Value(movement.approvalRequired),
          requestedBy: movement.requestedBy,
          requestedByName: movement.requestedByName,
          decidedBy: Value(movement.decidedBy),
          decidedByName: Value(movement.decidedByName),
          decisionAt: Value(movement.decisionAt),
          rejectionReason: Value(movement.rejectionReason),
          cancellationReason: Value(movement.cancellationReason),
          version: Value(movement.version),
          serverUpdatedAt: movement.serverUpdatedAt,
          cachedAt: DateTime.now().toUtc(),
          isAccessible: const Value(true),
        ),
      );

  AnimalMovement _fromLocal(LocalAnimalMovement row) => AnimalMovement(
    id: row.id,
    organizationId: row.organizationId,
    animalId: row.animalId,
    animalNumber: row.animalNumber,
    sourceFarmId: row.sourceFarmId,
    sourceFarmName: row.sourceFarmName,
    sourceShedId: row.sourceShedId,
    sourceShedName: row.sourceShedName,
    sourceAnimalGroupId: row.sourceAnimalGroupId,
    sourceAnimalGroupName: row.sourceAnimalGroupName,
    destinationFarmId: row.destinationFarmId,
    destinationFarmName: row.destinationFarmName,
    destinationShedId: row.destinationShedId,
    destinationShedName: row.destinationShedName,
    destinationAnimalGroupId: row.destinationAnimalGroupId,
    destinationAnimalGroupName: row.destinationAnimalGroupName,
    requestedEffectiveAt: row.requestedEffectiveAt,
    actualEffectiveAt: row.actualEffectiveAt,
    reason: row.reason,
    notes: row.notes,
    status: row.status,
    approvalRequired: row.approvalRequired,
    requestedBy: row.requestedBy,
    requestedByName: row.requestedByName,
    decidedBy: row.decidedBy,
    decidedByName: row.decidedByName,
    decisionAt: row.decisionAt,
    rejectionReason: row.rejectionReason,
    cancellationReason: row.cancellationReason,
    version: row.version,
    serverUpdatedAt: row.serverUpdatedAt,
  );

  List<Map<String, dynamic>> _maps(Object? value) =>
      (value as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
}

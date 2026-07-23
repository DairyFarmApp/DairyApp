import 'package:dairycare_mobile/features/animals/domain/animal_movement_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/animal_fixtures.dart';

void main() {
  test('movement serialization preserves source destination and decisions', () {
    final movement = AnimalMovement.fromJson(
      movementJson(status: 'rejected', version: 2),
    );

    expect(movement.id, movementId);
    expect(movement.sourceFarmId, farmId);
    expect(movement.destinationFarmId, destinationFarmId);
    expect(movement.requestedEffectiveAt, DateTime.utc(2026, 7, 23, 9));
    expect(movement.status, 'rejected');
    expect(movement.rejectionReason, 'Destination unavailable');
    expect(movement.version, 2);
    expect(movement.isPending, isFalse);
  });

  test('movement draft emits immutable source snapshot and UTC timestamp', () {
    final draft = AnimalMovementDraft(
      sourceFarmId: farmId,
      sourceShedId: shedId,
      sourceAnimalGroupId: groupId,
      destinationFarmId: destinationFarmId,
      destinationShedId: destinationShedId,
      destinationAnimalGroupId: destinationGroupId,
      requestedEffectiveAt: DateTime.utc(2026, 7, 23, 9),
      reason: '  Routine relocation  ',
      notes: '  ',
    );

    expect(draft.toJson(), {
      'source_farm_id': farmId,
      'source_shed_id': shedId,
      'source_animal_group_id': groupId,
      'destination_farm_id': destinationFarmId,
      'destination_shed_id': destinationShedId,
      'destination_animal_group_id': destinationGroupId,
      'requested_effective_at': '2026-07-23T09:00:00.000Z',
      'reason': 'Routine relocation',
      'notes': null,
    });
  });

  test('all approved movement statuses deserialize distinctly', () {
    for (final status in ['pending', 'approved', 'rejected', 'cancelled']) {
      final movement = movementFixture(status: status);
      expect(movement.status, status);
      expect(movement.isPending, status == 'pending');
    }
  });
}

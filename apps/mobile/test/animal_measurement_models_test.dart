import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_status_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_weight_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/animal_fixtures.dart';

void main() {
  test('weight model preserves decimal strings and correction linkage', () {
    final weight = AnimalWeight.fromJson(
      weightJson(
        id: correctedWeightId,
        enteredValue: '1100.000000',
        enteredUnit: 'lb',
        normalizedKg: '498.951607',
        supersedesWeightId: weightId,
        correctionReason: 'Verified paper log.',
      ),
    );

    expect(weight.enteredValue, '1100.000000');
    expect(weight.normalizedKg, '498.951607');
    expect(weight.isCorrection, isTrue);
    expect(weight.supersedesWeightId, weightId);
    expect(weight.observedAt, DateTime.utc(2026, 7, 23, 8));
  });

  test(
    'weight drafts send decimal strings UTC times and correction reason',
    () {
      final record = AnimalWeightDraft(
        farmId: farmId,
        value: ' 500.125000 ',
        unit: 'kg',
        observedAt: DateTime.utc(2026, 7, 23, 8),
        source: 'scale',
        notes: '  ',
      );
      const correction = AnimalWeightCorrectionDraft(
        value: '501.000000',
        unit: 'kg',
        correctionReason: ' Paper log rechecked. ',
      );

      expect(record.toJson()['value'], '500.125000');
      expect(record.toJson()['farm_id'], farmId);
      expect(record.toJson()['observed_at'], '2026-07-23T08:00:00.000Z');
      expect(record.toJson()['notes'], isNull);
      expect(correction.toJson()['correction_reason'], 'Paper log rechecked.');
    },
  );

  test('status model and draft preserve transition sequence and version', () {
    final change = AnimalStatusChange.fromJson(
      statusChangeJson(newStatus: 'missing', sequence: 3, animalVersion: 8),
    );
    final draft = AnimalStatusChangeDraft(
      newStatus: 'active',
      effectiveAt: DateTime.utc(2026, 7, 23, 9),
      reason: ' Animal found. ',
      version: 8,
    );

    expect(change.previousStatus, 'active');
    expect(change.newStatus, 'missing');
    expect(change.sequence, 3);
    expect(change.animalVersion, 8);
    expect(draft.toJson(), {
      'new_status': 'active',
      'effective_at': '2026-07-23T09:00:00.000Z',
      'reason': 'Animal found.',
      'version': 8,
    });
  });

  test('animal profile parses latest normalized-weight projection', () {
    final animal = animalFixture();
    final withWeight = Animal.fromJson(animalJson(latestWeight: weightJson()));

    expect(animal.latestWeight, isNull);
    expect(withWeight.latestWeight?.normalizedKg, '500.000000');
  });
}

import 'package:dairycare_mobile/features/inventory/presentation/inventory_form_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('inventory decimals enforce scale and positive stock', () {
    expect(
      validateInventoryDecimal(
        '12.345',
        required: true,
        decimalPlaces: 3,
        positive: true,
      ),
      isNull,
    );
    expect(
      validateInventoryDecimal(
        '0',
        required: true,
        decimalPlaces: 3,
        positive: true,
      ),
      'Must be greater than zero',
    );
    expect(
      validateInventoryDecimal('1.2345', required: true, decimalPlaces: 3),
      contains('up to 3 decimals'),
    );
  });

  test('inventory dates reject invalid format and reversed expiry', () {
    expect(validateInventoryDate('2026-02-29'), 'Enter a valid date');
    expect(validateInventoryDate('29/07/2026'), 'Use YYYY-MM-DD');
    expect(
      validateInventoryExpiry('2026-07-28', '2026-07-29'),
      'Must be on or after purchase date',
    );
    expect(validateInventoryExpiry('2026-07-29', '2026-07-29'), isNull);
  });

  test('maximum stock cannot be less than minimum stock', () {
    expect(
      validateMaximumStock('5.000', '10.000'),
      'Must be at least minimum stock',
    );
    expect(validateMaximumStock('10.000', '10.000'), isNull);
    expect(validateMaximumStock('', '10.000'), isNull);
  });
}

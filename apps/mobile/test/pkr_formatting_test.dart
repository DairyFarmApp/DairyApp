import 'package:dairycare_mobile/core/formatting/pkr.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PKR formatter uses digits, grouping, and two decimals', () {
    expect(formatPkr('125000'), 'PKR 125,000.00');
    expect(formatPkr(99.5), 'PKR 99.50');
  });

  test('PKR validator rejects text and more than two decimals', () {
    expect(validatePkrAmount('12abc', required: true), isNotNull);
    expect(validatePkrAmount('12.345', required: true), isNotNull);
    expect(validatePkrAmount('12.34', required: true), isNull);
    expect(validatePkrAmount('', required: false), isNull);
  });
}

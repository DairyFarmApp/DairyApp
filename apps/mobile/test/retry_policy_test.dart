import 'dart:math';

import 'package:dairycare_mobile/core/sync/retry_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retry delay stays within exponential cap', () {
    final policy = ExponentialRetryPolicy(
      baseDelay: const Duration(seconds: 2),
      maximumDelay: const Duration(seconds: 30),
      random: Random(42),
    );
    for (var attempt = 0; attempt < 10; attempt++) {
      expect(
        policy.delayForAttempt(attempt),
        lessThanOrEqualTo(const Duration(seconds: 30)),
      );
    }
  });
}

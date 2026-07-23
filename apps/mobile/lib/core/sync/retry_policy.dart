import 'dart:math';

final class ExponentialRetryPolicy {
  ExponentialRetryPolicy({
    this.baseDelay = const Duration(seconds: 2),
    this.maximumDelay = const Duration(minutes: 5),
    Random? random,
  }) : _random = random ?? Random.secure();

  final Duration baseDelay;
  final Duration maximumDelay;
  final Random _random;

  Duration delayForAttempt(int attempt) {
    final safeAttempt = attempt.clamp(0, 20);
    final capMs = min(
      maximumDelay.inMilliseconds,
      baseDelay.inMilliseconds * pow(2, safeAttempt).toInt(),
    );
    return Duration(milliseconds: _random.nextInt(max(1, capMs + 1)));
  }
}

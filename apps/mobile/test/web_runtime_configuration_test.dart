import 'dart:io';

import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Drift web runtime configuration and versioned assets are present', () {
    final databaseSource = File(
      'lib/core/database/app_database.dart',
    ).readAsStringSync();
    expect(databaseSource, contains('web: DriftWebOptions('));
    expect(databaseSource, contains("Uri.parse('sqlite3.wasm')"));
    expect(databaseSource, contains("Uri.parse('drift_worker.js')"));

    final wasm = File('web/sqlite3.wasm');
    final worker = File('web/drift_worker.js');
    expect(wasm.existsSync(), isTrue);
    expect(worker.existsSync(), isTrue);
    expect(wasm.lengthSync(), greaterThan(700000));
    expect(worker.lengthSync(), greaterThan(300000));
    expect(
      wasm.readAsBytesSync().take(4),
      orderedEquals(const [0x00, 0x61, 0x73, 0x6D]),
    );
    expect(worker.readAsStringSync(), contains('DedicatedWorkerGlobalScope'));
  });

  test('provider internals are never displayed as a user-facing error', () {
    const providerFailure =
        'ProviderException: provider failed\n'
        'package:dairycare_mobile/core/providers.dart';
    expect(safeErrorMessage(providerFailure), isNot(contains('Provider')));
    expect(safeErrorMessage(providerFailure), isNot(contains('package:')));
    expect(
      safeErrorMessage('Unable to reach the server.'),
      'Unable to reach the server.',
    );
  });
}

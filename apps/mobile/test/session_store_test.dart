import 'helpers/fakes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'session persistence abstraction replaces and clears credentials',
    () async {
      final store = MemorySessionStore();
      await store.saveTokens(
        accessToken: 'access',
        renewalCredential: 'renewal',
      );
      expect(await store.readAccessToken(), 'access');
      expect(await store.readRenewalCredential(), 'renewal');

      await store.saveTokens(accessToken: 'rotated', renewalCredential: 'next');
      expect(await store.readRenewalCredential(), 'next');
      await store.clear();
      expect(await store.readAccessToken(), isNull);
      expect(await store.readRenewalCredential(), isNull);
    },
  );
}

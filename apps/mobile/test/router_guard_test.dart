import 'package:dairycare_mobile/app/router.dart';
import 'helpers/fakes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('router sends unauthenticated users to login', () {
    expect(authRedirect(auth: const AsyncData(null), path: '/home'), '/login');
  });

  test('router allows unauthenticated owner and family signup pages', () {
    expect(authRedirect(auth: const AsyncData(null), path: '/signup'), isNull);
  });

  test('router keeps public authentication forms mounted while submitting', () {
    expect(authRedirect(auth: const AsyncLoading(), path: '/login'), isNull);
    expect(authRedirect(auth: const AsyncLoading(), path: '/signup'), isNull);
    expect(authRedirect(auth: const AsyncLoading(), path: '/home'), '/loading');
  });

  test('router sends a complete authenticated context home', () {
    expect(
      authRedirect(auth: AsyncData(foundationSession()), path: '/login'),
      '/home',
    );
  });
}

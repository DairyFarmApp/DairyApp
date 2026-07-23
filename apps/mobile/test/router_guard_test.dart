import 'package:dairycare_mobile/app/router.dart';
import 'helpers/fakes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('router sends unauthenticated users to login', () {
    expect(authRedirect(auth: const AsyncData(null), path: '/home'), '/login');
  });

  test('router sends a complete authenticated context home', () {
    expect(
      authRedirect(auth: AsyncData(foundationSession()), path: '/login'),
      '/home',
    );
  });
}

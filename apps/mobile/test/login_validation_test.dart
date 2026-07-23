import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/features/authentication/presentation/login_screen.dart';
import 'helpers/fakes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login form validates required and malformed values', (
    tester,
  ) async {
    FakeAuthController.session = null;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'not-an-email',
    );
    await tester.enterText(find.byKey(const Key('login_password')), 'secret');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });
}

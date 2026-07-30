import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/features/authentication/presentation/signup_screen.dart';
import 'helpers/fakes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('owner signup validates farm profile and password fields', (
    tester,
  ) async {
    FakeAuthController.session = null;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
        ],
        child: const MaterialApp(home: SignupScreen()),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('signup_submit')));
    await tester.tap(find.byKey(const Key('signup_submit')));
    await tester.pump();
    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('Farm name is required.'), findsOneWidget);
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsNWidgets(2));

    await tester.enterText(find.byKey(const Key('signup_name')), 'Tayyab');
    await tester.enterText(
      find.byKey(const Key('signup_farm_name')),
      'Saleem Dairy Farm',
    );
    await tester.enterText(find.byKey(const Key('signup_email')), 'bad-email');
    await tester.enterText(
      find.byKey(const Key('signup_phone')),
      'not-a-phone',
    );
    await tester.enterText(
      find.byKey(const Key('signup_password')),
      'password',
    );
    await tester.enterText(
      find.byKey(const Key('signup_confirmation')),
      'different',
    );
    await tester.ensureVisible(find.byKey(const Key('signup_submit')));
    await tester.tap(find.byKey(const Key('signup_submit')));
    await tester.pump();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Enter a valid phone number.'), findsOneWidget);
    expect(find.text('Use at least 10 characters.'), findsOneWidget);
    expect(find.text('Passwords do not match.'), findsOneWidget);
  });
}

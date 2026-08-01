import 'package:dairycare_mobile/app/router.dart';
import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/auth/session_models.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
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

  testWidgets('invalid credentials keep entered login values and show error', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(RejectingLoginAuthController.new),
        ],
        child: const _RouterTestApp(),
      ),
    );
    await tester.pumpAndSettle();

    const email = 'owner@example.test';
    const password = 'wrong-password';
    await tester.enterText(find.byKey(const Key('login_email')), email);
    await tester.enterText(find.byKey(const Key('login_password')), password);
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_error')), findsOneWidget);
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('login_email')))
          .controller!
          .text,
      email,
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('login_password')))
          .controller!
          .text,
      password,
    );
  });
}

final class _RouterTestApp extends ConsumerWidget {
  const _RouterTestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      MaterialApp.router(routerConfig: ref.watch(routerProvider));
}

final class RejectingLoginAuthController extends AuthController {
  @override
  Future<AuthSession?> build() async => null;

  @override
  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    await Future<void>.delayed(Duration.zero);
    state = AsyncError(
      const AuthenticationException(
        'The supplied credentials are invalid.',
        code: 'INVALID_CREDENTIALS',
      ),
      StackTrace.empty,
    );
  }
}

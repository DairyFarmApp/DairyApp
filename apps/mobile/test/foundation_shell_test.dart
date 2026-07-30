import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/network/connectivity_provider.dart';
import 'package:dairycare_mobile/core/sync/sync_controller.dart';
import 'package:dairycare_mobile/core/sync/sync_models.dart';
import 'package:dairycare_mobile/features/foundation_home/presentation/foundation_shell.dart';
import 'helpers/fakes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('menu hides farm and shed entries without permission', (
    tester,
  ) async {
    FakeAuthController.session = foundationSession();
    FakeSyncController.status = const SyncStatus();
    await tester.pumpWidget(_app());
    await tester.pump();
    expect(find.text('Farms'), findsNothing);
    expect(find.text('Sheds'), findsNothing);
    expect(find.text('Sync'), findsOneWidget);
  });

  testWidgets('wide shell uses navigation rail and exposes permitted entries', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession(
      permissions: const {'farms.view', 'sheds.view', 'inventory.view'},
    );
    await tester.pumpWidget(_app());
    await tester.pump();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Farms'), findsOneWidget);
    expect(find.text('Sheds'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
  });

  testWidgets('primary owner menu exposes profile and family management', (
    tester,
  ) async {
    FakeAuthController.session = foundationSession(
      membershipType: 'primary_owner',
    );
    await tester.pumpWidget(_app());
    await tester.pump();
    await tester.tap(find.byTooltip('Account and farm options'));
    await tester.pumpAndSettle();
    expect(find.text('My profile'), findsOneWidget);
    expect(find.text('Family accounts'), findsOneWidget);
    expect(find.text('System theme'), findsOneWidget);
    expect(find.text('White theme'), findsOneWidget);
    expect(find.text('Dark theme'), findsOneWidget);
    expect(find.text('Switch farm'), findsNothing);
  });
}

Widget _app() {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (_, _, child) => FoundationShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/farms', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/sheds', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/inventory', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/sync', builder: (_, _) => const SizedBox()),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(FakeAuthController.new),
      syncControllerProvider.overrideWith(FakeSyncController.new),
      isOfflineProvider.overrideWith((ref) => false),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

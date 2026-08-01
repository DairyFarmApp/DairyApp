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
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession();
    FakeSyncController.status = const SyncStatus();
    await tester.pumpWidget(_app());
    await tester.pump();
    expect(find.text('Farm'), findsNothing);
    expect(find.text('Sheds'), findsNothing);
    expect(find.text('Milk Production'), findsNothing);
    expect(find.text('Employees'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
    expect(find.text('Loans'), findsNothing);
    expect(find.text('Finance'), findsOneWidget);
    expect(find.text('Sync'), findsOneWidget);
  });

  testWidgets('employee navigation expands indented items inside the sidebar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession(
      permissions: const {
        'farms.view',
        'sheds.view',
        'animals.view',
        'animal_breeds.view',
        'inventory.view',
        'milk.view',
      },
    );
    FakeSyncController.status = const SyncStatus();

    await tester.pumpWidget(_app());
    await tester.pump();
    await tester.drag(
      find.byKey(const Key('wide_sidebar_navigation')),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Employees'));
    await tester.pumpAndSettle();

    expect(find.byType(SimpleDialog), findsNothing);
    expect(find.byKey(const Key('employee_list_menu_action')), findsOneWidget);
    expect(
      find.byKey(const Key('employee_salary_menu_action')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('employee_loans_menu_action')), findsOneWidget);
    expect(find.text('Employee list'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Loans'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('wide_sidebar_navigation')),
        matching: find.byKey(const Key('employee_salary_menu_action')),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('employee_slide_down_menu')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Employees'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('employee_salary_menu_action')), findsNothing);
  });

  testWidgets('salary route expands and selects its employee subheading', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession();
    FakeSyncController.status = const SyncStatus();

    await tester.pumpWidget(_app(initialLocation: '/payroll'));
    await tester.pump();

    expect(
      find.byKey(const Key('employee_salary_menu_action')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ListTile>(
            find.byKey(const Key('employee_salary_menu_action')),
          )
          .selected,
      isTrue,
    );
  });

  testWidgets('wide shell uses scrollable sidebar and permitted entries', (
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
    expect(find.byKey(const Key('wide_sidebar_navigation')), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Farm'), findsOneWidget);
    expect(find.text('Sheds'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
  });

  testWidgets('animal, breed and milk entries follow their permissions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession(
      permissions: const {'animals.view', 'animal_breeds.view', 'milk.view'},
    );
    await tester.pumpWidget(_app());
    await tester.pump();
    expect(find.text('Animals'), findsOneWidget);
    expect(find.text('Breeds'), findsOneWidget);
    expect(find.text('Milk Production'), findsOneWidget);
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

Widget _app({String initialLocation = '/home'}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (_, _, child) => FoundationShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/farms', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/sheds', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/animals', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/animal-breeds', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/inventory', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/milk', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/employees', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/payroll', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/employee-loans', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/finance', builder: (_, _) => const SizedBox()),
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

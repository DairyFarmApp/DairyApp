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
    expect(find.text('Animal Housing'), findsNothing);
    expect(find.text('Milk Production'), findsNothing);
    expect(find.text('Manage Users'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
    expect(find.text('Loans'), findsNothing);
  });

  testWidgets('settings navigation expands indented items inside the sidebar', (
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
        'finance.view',
      },
    );
    FakeSyncController.status = const SyncStatus();

    await tester.pumpWidget(_app());
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Settings'),
      320,
      scrollable: find.descendant(
        of: find.byKey(const Key('wide_sidebar_navigation')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings_farm_menu_action')), findsOneWidget);
    expect(
      find.byKey(const Key('settings_breeds_menu_action')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('main_finance_menu_action')), findsOneWidget);
    expect(find.text('Farm'), findsOneWidget);
    expect(find.text('Breeds'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
    expect(find.byKey(const Key('settings_slide_down_menu')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings_farm_menu_action')), findsNothing);
  });

  testWidgets('farm route expands and selects its settings subheading', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession(
      permissions: const {'farms.view'},
    );
    FakeSyncController.status = const SyncStatus();

    await tester.pumpWidget(_app(initialLocation: '/farms'));
    await tester.pump();

    expect(find.byKey(const Key('settings_farm_menu_action')), findsOneWidget);
    expect(
      tester
          .widget<ListTile>(find.byKey(const Key('settings_farm_menu_action')))
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
    expect(find.text('Animal Housing'), findsOneWidget);
    expect(find.text('Manage Inventory'), findsOneWidget);
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
    expect(find.text('Cattle Management'), findsOneWidget);
    expect(find.text('Milk Production'), findsOneWidget);
  });

  testWidgets('daily operation sections appear before management sections', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession(
      permissions: const {'milk.view', 'inventory.view', 'animals.view'},
    );
    await tester.pumpWidget(_app());
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('Milk Production')).dy,
      lessThan(tester.getTopLeft(find.text('Stock Usage')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Stock Usage')).dy,
      lessThan(tester.getTopLeft(find.text('Manage Inventory')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Manage Inventory')).dy,
      lessThan(tester.getTopLeft(find.text('Cattle Management')).dy),
    );
  });

  testWidgets(
    'commercial menu entries follow customer and supplier permissions',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      FakeAuthController.session = foundationSession(
        permissions: const {'customers.view', 'suppliers.view'},
      );
      FakeSyncController.status = const SyncStatus();
      await tester.pumpWidget(_app());
      await tester.pump();

      expect(
        find.byKey(const Key('main_customers_menu_action')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('main_suppliers_menu_action')),
        findsOneWidget,
      );
      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('Suppliers'), findsOneWidget);
    },
  );

  testWidgets('purchase order menu follows purchasing permission', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession(
      permissions: const {'purchases.view'},
    );
    FakeSyncController.status = const SyncStatus();
    await tester.pumpWidget(_app());
    await tester.pump();
    expect(
      find.byKey(const Key('main_purchase_orders_menu_action')),
      findsOneWidget,
    );
    expect(find.text('Purchase Orders'), findsOneWidget);
  });

  testWidgets('milk sales menu follows sales permission', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession(
      permissions: const {'milk_sales.view'},
    );
    FakeSyncController.status = const SyncStatus();
    await tester.pumpWidget(_app());
    await tester.pump();
    expect(
      find.byKey(const Key('main_milk_sales_menu_action')),
      findsOneWidget,
    );
    expect(find.text('Milk Sales'), findsOneWidget);
  });

  testWidgets('supplier invoice menu follows invoice permission', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession(
      permissions: const {'supplier_invoices.view'},
    );
    FakeSyncController.status = const SyncStatus();
    await tester.pumpWidget(_app());
    await tester.pump();
    expect(
      find.byKey(const Key('main_supplier_invoices_menu_action')),
      findsOneWidget,
    );
    expect(find.text('Supplier Invoices'), findsOneWidget);
  });

  testWidgets('primary owner menu exposes profile and family management', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
          GoRoute(
            path: '/inventory/indents',
            builder: (_, _) => const SizedBox(),
          ),
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

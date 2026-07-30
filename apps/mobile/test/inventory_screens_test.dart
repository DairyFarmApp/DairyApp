import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/features/inventory/application/inventory_providers.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:dairycare_mobile/features/inventory/presentation/inventory_date_field.dart';
import 'package:dairycare_mobile/features/inventory/presentation/inventory_dashboard_screen.dart';
import 'package:dairycare_mobile/features/inventory/presentation/inventory_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('inventory dashboard exposes medicine semen and feed choices', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDashboardProvider.overrideWith(
            (ref) async => {
              for (final kind in InventoryKind.values) kind: _summary,
            },
          ),
        ],
        child: const MaterialApp(home: InventoryDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Manage inventory'), findsOneWidget);
    expect(find.text('Medicine inventory'), findsOneWidget);
    expect(find.text('Semen inventory'), findsOneWidget);
    expect(find.text('Feed inventory'), findsOneWidget);
  });

  testWidgets('medicine overview renders metrics filters and stock actions', (
    tester,
  ) async {
    FakeAuthController.session = foundationSession(
      permissions: const {
        'inventory.view',
        'inventory.manage',
        'inventory.export',
      },
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
          inventoryOverviewProvider.overrideWith(
            (ref, query) async => InventoryOverview(
              summary: _summary,
              items: [_item],
              categories: const ['Injection'],
              suppliers: const ['DairyVet'],
            ),
          ),
        ],
        child: const MaterialApp(
          home: InventoryOverviewScreen(kind: InventoryKind.medicine),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Medicine inventory'), findsOneWidget);
    expect(find.byKey(const Key('inventory_search')), findsOneWidget);
    expect(find.text('Oxytocin'), findsOneWidget);
    expect(find.text('Receive stock'), findsOneWidget);
    expect(find.text('Receipts and Excel export'), findsOneWidget);
    expect(find.text('PDF receipt'), findsOneWidget);
    expect(find.text('Excel file'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_rounded), findsNWidgets(2));
    expect(find.text('Low stock'), findsWidgets);

    await tester.ensureVisible(find.text('Edit'));
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Oxytocin'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
  });

  testWidgets('inventory date fields open a calendar picker', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryDateField(
            controller: controller,
            label: 'Purchase date',
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('wide inventory table exposes selection and row actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession(
      permissions: const {
        'inventory.view',
        'inventory.manage',
        'inventory.export',
      },
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
          inventoryOverviewProvider.overrideWith(
            (ref, query) async => InventoryOverview(
              summary: _summary,
              items: [_item],
              categories: const ['Injection'],
              suppliers: const ['DairyVet'],
            ),
          ),
        ],
        child: const MaterialApp(
          home: InventoryOverviewScreen(kind: InventoryKind.medicine),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf_outlined), findsWidgets);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.add_box_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
  });
}

const _summary = InventorySummary(
  itemCount: 1,
  totalStock: '1.000',
  totalValue: '125.0000',
  lowStockItems: 1,
  expiringSoonBatches: 0,
  expiredBatches: 0,
);

final _item = InventoryItem(
  id: 'item-1',
  kind: InventoryKind.medicine,
  itemCode: 'MED-001',
  name: 'Oxytocin',
  category: 'Injection',
  brand: 'DairyVet',
  unit: 'vial',
  minimumStock: '2.000',
  maximumStock: '100.000',
  currentStock: '1.000',
  totalValue: '125.0000',
  version: 1,
  batches: [
    InventoryBatch(
      id: 'batch-1',
      batchNumber: 'B-001',
      supplier: 'DairyVet',
      unitCost: '125.0000',
      currentQuantity: '1.000',
      expiryDate: DateTime.utc(2027, 7, 29),
    ),
  ],
);

import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/features/milk/application/milk_providers.dart';
import 'package:dairycare_mobile/features/milk/domain/milk_models.dart';
import 'package:dairycare_mobile/features/milk/presentation/milk_production_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('daily milk screen shows real metrics and quick-entry controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession(
      permissions: const {'milk.view', 'milk.create', 'milk.correct'},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
          milkDailyProvider.overrideWith(
            (ref, query) async => _daily(query.date, query.session),
          ),
        ],
        child: const MaterialApp(home: MilkProductionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Milk production'), findsOneWidget);
    expect(find.text('Total milk'), findsOneWidget);
    expect(find.text('12.500 L'), findsOneWidget);
    expect(find.text('Sellable milk'), findsOneWidget);
    expect(find.text('AN-001 · Noor'), findsOneWidget);
    expect(find.text('Save entries'), findsOneWidget);
    expect(find.text('Milk litres'), findsOneWidget);
    expect(find.text('Morning'), findsWidgets);
    expect(find.text('Afternoon'), findsOneWidget);
    expect(find.text('Evening'), findsOneWidget);
  });

  testWidgets('milk production date button opens the calendar', (tester) async {
    FakeAuthController.session = foundationSession(
      permissions: const {'milk.view'},
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
          milkDailyProvider.overrideWith(
            (ref, query) async => _daily(query.date, query.session),
          ),
        ],
        child: const MaterialApp(home: MilkProductionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.calendar_month_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('empty milk setup explains and links the required hierarchy', (
    tester,
  ) async {
    FakeAuthController.session = foundationSession(
      permissions: const {'milk.view', 'milk.create'},
    );
    final router = GoRouter(
      initialLocation: '/milk',
      routes: [
        GoRoute(path: '/milk', builder: (_, _) => const MilkProductionScreen()),
        GoRoute(path: '/animals/new', builder: (_, _) => const SizedBox()),
        GoRoute(path: '/sheds', builder: (_, _) => const SizedBox()),
        GoRoute(path: '/animal-breeds', builder: (_, _) => const SizedBox()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
          milkDailyProvider.overrideWith(
            (ref, query) async => MilkDailyData(
              date: query.date,
              session: query.session,
              summary: const MilkDailySummary(
                totalLitres: '0.000',
                rejectedLitres: '0.000',
                sellableLitres: '0.000',
                entryCount: 0,
                animalsRecorded: 0,
                yesterdaySellableLitres: '0.000',
                sevenDayDailyAverageLitres: '0.000',
              ),
              eligibleAnimals: const [],
              entries: const [],
              isCached: false,
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No animals ready for milk entry'), findsOneWidget);
    expect(find.byKey(const Key('milk_add_animal_action')), findsOneWidget);
    expect(find.byKey(const Key('milk_manage_sheds_action')), findsOneWidget);
    expect(find.byKey(const Key('milk_manage_breeds_action')), findsOneWidget);
  });
}

MilkDailyData _daily(DateTime date, MilkingSession session) => MilkDailyData(
  date: date,
  session: session,
  summary: const MilkDailySummary(
    totalLitres: '12.500',
    rejectedLitres: '0.500',
    sellableLitres: '12.000',
    entryCount: 0,
    animalsRecorded: 0,
    yesterdaySellableLitres: '10.000',
    sevenDayDailyAverageLitres: '11.250',
  ),
  eligibleAnimals: const [
    MilkEligibleAnimal(
      id: 'animal-1',
      animalNumber: 'AN-001',
      name: 'Noor',
      shedId: 'shed-1',
      shedName: 'Milking Shed',
    ),
  ],
  entries: const [],
  isCached: false,
);

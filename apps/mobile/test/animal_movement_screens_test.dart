import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/features/animals/application/animal_movement_providers.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_movement_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_movement_models.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_movement_form_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_movement_history_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/animal_fixtures.dart';
import 'helpers/fakes.dart';

void main() {
  setUp(() {
    FakeAuthController.session = foundationSession(
      permissions: const {
        'animals.view',
        'animals.move',
        'animal_movements.view',
        'animal_movements.approve',
        'animal_movements.reject',
        'animal_movements.cancel',
      },
    );
  });

  testWidgets(
    'history renders pending approved rejected and cancelled states',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final items = [
        movementFixture(id: '${movementId}1'),
        movementFixture(id: '${movementId}2', status: 'approved', version: 2),
        movementFixture(id: '${movementId}3', status: 'rejected', version: 2),
        movementFixture(id: '${movementId}4', status: 'cancelled', version: 2),
      ];
      await tester.pumpWidget(_historyApp(items));
      await tester.pumpAndSettle();

      for (final status in ['pending', 'approved', 'rejected', 'cancelled']) {
        expect(find.byKey(Key('movement_status_$status')), findsOneWidget);
      }
      expect(find.text('Rejection: Destination unavailable'), findsOneWidget);
      expect(
        find.text('Cancellation: Request entered in error'),
        findsOneWidget,
      );
    },
  );

  testWidgets('approval controls follow permission and separation of duties', (
    tester,
  ) async {
    await tester.pumpWidget(_historyApp([movementFixture()]));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('approve_movement_$movementId')), findsOneWidget);
    expect(find.byKey(Key('reject_movement_$movementId')), findsOneWidget);
    expect(find.byKey(Key('cancel_movement_$movementId')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _historyApp([
        movementFixture(requestedBy: '018f0000-0000-7000-8000-000000000001'),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(Key('approve_movement_$movementId')), findsNothing);
    expect(find.byKey(Key('reject_movement_$movementId')), findsOneWidget);
  });

  testWidgets('cached history is labelled and tablet layout uses a table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_historyApp([movementFixture()], isCached: true));
    await tester.pumpAndSettle();

    expect(find.text('Showing cached movement history'), findsOneWidget);
    expect(find.byType(DataTable), findsOneWidget);
  });

  testWidgets('request form validates destination and reason', (tester) async {
    await tester.pumpWidget(_movementFormApp());
    await tester.pump();
    await tester.pump();

    tester
        .widget<FilledButton>(find.byKey(const Key('submit_movement_button')))
        .onPressed!();
    await tester.pump();

    expect(find.text('This field is required.'), findsNWidgets(3));
    expect(find.byKey(const Key('movement_source_summary')), findsOneWidget);
  });

  testWidgets('destination farm selection limits shed and group choices', (
    tester,
  ) async {
    await tester.pumpWidget(_movementFormApp());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const Key('movement_destination_farm')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('South Farm').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('movement_destination_shed')));
    await tester.pumpAndSettle();

    expect(find.text('Receiving Shed'), findsWidgets);
    expect(find.text('Main Shed'), findsNothing);
  });
}

Widget _historyApp(List<AnimalMovement> movements, {bool isCached = false}) =>
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(FakeAuthController.new),
        animalMovementHistoryProvider.overrideWith(
          (ref, id) async =>
              AnimalMovementLoadResult(items: movements, isCached: isCached),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnimalMovementHistorySection(animal: animalFixture()),
          ),
        ),
      ),
    );

Widget _movementFormApp() => ProviderScope(
  overrides: [
    authControllerProvider.overrideWith(FakeAuthController.new),
    animalDetailProvider.overrideWith((ref, id) async => animalFixture()),
    animalReferencesProvider.overrideWith(
      (ref, id) async => movementReferenceFixture(),
    ),
  ],
  child: const MaterialApp(home: AnimalMovementFormScreen(animalId: animalId)),
);

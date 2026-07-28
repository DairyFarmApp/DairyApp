import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/features/animals/application/animal_measurement_providers.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_measurement_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_status_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_weight_models.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_status_change_form_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_status_history_section.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_weight_form_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_weight_history_section.dart';
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
        'animals.record_weight',
        'animals.correct_weight',
        'animals.view_weight_history',
        'animals.change_status',
        'animals.view_status_history',
      },
    );
  });

  testWidgets(
    'weight history distinguishes superseded and correction records',
    (tester) async {
      final weights = [
        weightFixture(
          superseded: true,
          supersededByWeightId: correctedWeightId,
        ),
        weightFixture(
          id: correctedWeightId,
          supersedesWeightId: weightId,
          correctionReason: 'Verified paper log.',
        ),
      ];
      await tester.pumpWidget(_weightHistoryApp(weights, isCached: true));
      await tester.pumpAndSettle();

      expect(find.text('Showing cached weight history'), findsOneWidget);
      expect(find.byKey(const Key('weight_state_superseded')), findsOneWidget);
      expect(find.byKey(const Key('weight_state_correction')), findsOneWidget);
      expect(find.byKey(Key('correct_weight_$weightId')), findsNothing);
      expect(
        find.byKey(Key('correct_weight_$correctedWeightId')),
        findsNothing,
      );
      expect(find.byKey(const Key('record_weight_action')), findsOneWidget);
    },
  );

  testWidgets('tablet weight history uses a bounded data table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_weightHistoryApp([weightFixture()]));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Normalized'), findsOneWidget);
    expect(find.byKey(Key('correct_weight_$weightId')), findsOneWidget);
  });

  testWidgets(
    'status history renders transitions and permission-aware action',
    (tester) async {
      final changes = [
        statusChangeFixture(newStatus: 'missing'),
        statusChangeFixture(
          id: '${statusChangeId}1',
          previousStatus: 'missing',
          newStatus: 'active',
          sequence: 2,
        ),
      ];
      await tester.pumpWidget(_statusHistoryApp(changes, isCached: true));
      await tester.pumpAndSettle();

      expect(find.text('Showing cached status history'), findsOneWidget);
      expect(find.byKey(const Key('operational_status_missing')), findsWidgets);
      expect(find.byKey(const Key('operational_status_active')), findsWidgets);
      expect(find.byKey(const Key('change_status_action')), findsOneWidget);
    },
  );

  testWidgets('history sections expose bounded incremental loading', (
    tester,
  ) async {
    await tester.pumpWidget(_weightHistoryApp([weightFixture()], lastPage: 2));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('load_more_weights')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _statusHistoryApp([statusChangeFixture()], lastPage: 2),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('load_more_status_history')), findsOneWidget);
  });

  testWidgets(
    'record and correction forms validate decimal and reason fields',
    (tester) async {
      await tester.pumpWidget(_weightFormApp());
      await tester.pump();
      await tester.pump();
      tester
          .widget<FilledButton>(find.byKey(const Key('submit_weight_button')))
          .onPressed!();
      await tester.pump();
      expect(
        find.text('Enter a positive decimal with at most six decimal places.'),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(_weightFormApp(correction: true));
      await tester.pump();
      await tester.pump();
      tester
          .widget<FilledButton>(find.byKey(const Key('submit_weight_button')))
          .onPressed!();
      await tester.pump();
      expect(find.text('A correction reason is required.'), findsOneWidget);
      expect(find.byKey(const Key('original_weight_summary')), findsOneWidget);
    },
  );

  testWidgets('status form requires a distinct status and mandatory reason', (
    tester,
  ) async {
    await tester.pumpWidget(_statusFormApp());
    await tester.pump();
    await tester.pump();
    tester
        .widget<FilledButton>(
          find.byKey(const Key('submit_status_change_button')),
        )
        .onPressed!();
    await tester.pump();

    expect(find.text('Select a new status.'), findsOneWidget);
    expect(find.text('A status-change reason is required.'), findsOneWidget);
    expect(find.text('Current operational status'), findsOneWidget);
  });

  testWidgets('history actions are hidden for read-only viewer', (
    tester,
  ) async {
    FakeAuthController.session = foundationSession(
      permissions: const {
        'animals.view',
        'animals.view_weight_history',
        'animals.view_status_history',
      },
    );
    await tester.pumpWidget(_weightHistoryApp([weightFixture()]));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('record_weight_action')), findsNothing);
    expect(find.byKey(Key('correct_weight_$weightId')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(_statusHistoryApp([statusChangeFixture()]));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('change_status_action')), findsNothing);
  });
}

Widget _weightHistoryApp(
  List<AnimalWeight> weights, {
  bool isCached = false,
  int lastPage = 1,
}) => ProviderScope(
  overrides: [
    authControllerProvider.overrideWith(FakeAuthController.new),
    animalWeightHistoryProvider.overrideWith(
      (ref, id) async => AnimalHistoryLoadResult(
        items: weights,
        isCached: isCached,
        lastPage: lastPage,
      ),
    ),
  ],
  child: MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: AnimalWeightHistorySection(animal: animalFixture()),
      ),
    ),
  ),
);

Widget _statusHistoryApp(
  List<AnimalStatusChange> changes, {
  bool isCached = false,
  int lastPage = 1,
}) => ProviderScope(
  overrides: [
    authControllerProvider.overrideWith(FakeAuthController.new),
    animalStatusHistoryProvider.overrideWith(
      (ref, id) async => AnimalHistoryLoadResult(
        items: changes,
        isCached: isCached,
        lastPage: lastPage,
      ),
    ),
  ],
  child: MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: AnimalStatusHistorySection(animal: animalFixture()),
      ),
    ),
  ),
);

Widget _weightFormApp({bool correction = false}) => ProviderScope(
  overrides: [
    authControllerProvider.overrideWith(FakeAuthController.new),
    animalDetailProvider.overrideWith((ref, id) async => animalFixture()),
    if (correction)
      animalWeightDetailProvider.overrideWith(
        (ref, id) async => weightFixture(),
      ),
  ],
  child: MaterialApp(
    home: AnimalWeightFormScreen(
      animalId: animalId,
      weightId: correction ? weightId : null,
    ),
  ),
);

Widget _statusFormApp() => ProviderScope(
  overrides: [
    authControllerProvider.overrideWith(FakeAuthController.new),
    animalDetailProvider.overrideWith((ref, id) async => animalFixture()),
  ],
  child: const MaterialApp(
    home: AnimalStatusChangeFormScreen(animalId: animalId),
  ),
);

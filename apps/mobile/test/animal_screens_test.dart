import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_detail_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_form_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_group_management_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_list_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/breed_management_screen.dart';
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
        'animals.create',
        'animals.update',
        'animals.archive',
        'animal_breeds.view',
        'animal_breeds.manage',
        'animal_groups.view',
        'animal_groups.manage',
      },
    );
    FakeAnimalListController.value = AnimalListState(
      items: [animalFixture()],
      filters: const AnimalFilters(farmId: farmId),
    );
  });

  testWidgets(
    'animal list uses cards on mobile and preserves permission controls',
    (tester) async {
      await tester.pumpWidget(
        _app(const AnimalListScreen(), references: referenceFixture()),
      );
      await tester.pump();

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('AN-000001 · Gulabo'), findsOneWidget);
      expect(find.byKey(const Key('animal_search')), findsOneWidget);
      expect(find.text('Add animal'), findsOneWidget);
      expect(find.text('Breeds'), findsOneWidget);
      expect(find.text('Animal groups'), findsOneWidget);
    },
  );

  testWidgets('animal list switches to a table at tablet width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(const AnimalListScreen(), references: referenceFixture()),
    );
    await tester.pump();

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Species / breed'), findsOneWidget);
  });

  testWidgets('add form validates required registry fields', (tester) async {
    const references = AnimalReferenceData(
      species: [],
      breeds: [],
      groups: [],
      farms: [],
      sheds: [],
      animals: [],
    );
    await tester.pumpWidget(
      _app(const AnimalFormScreen(), references: references),
    );
    await tester.pump();
    await tester.pump();

    final save = find.byKey(const Key('save_animal_button'));
    tester.widget<FilledButton>(save).onPressed!();
    await tester.pump();

    expect(find.text('This field is required.'), findsWidgets);
  });

  testWidgets('edit form presents location as read-only movement-owned data', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const AnimalFormScreen(animalId: animalId),
        references: referenceFixture(),
        detail: animalFixture(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.text(
        'Location changes are handled by the movement workflow in Phase 2B.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('farm_field')), findsNothing);
  });

  testWidgets('profile exposes archive but not restore for active animal', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const AnimalDetailScreen(animalId: animalId),
        detail: animalFixture(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('edit_animal_action')), findsOneWidget);
    expect(find.byKey(const Key('archive_animal_action')), findsOneWidget);
    expect(find.byKey(const Key('restore_animal_action')), findsNothing);
  });

  testWidgets('breed and group management actions follow permissions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const BreedManagementScreen(), references: referenceFixture()),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('add_breed_action')), findsOneWidget);

    await tester.pumpWidget(
      _app(const AnimalGroupManagementScreen(), references: referenceFixture()),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('add_group_action')), findsOneWidget);
  });
}

class FakeAnimalListController extends AnimalListController {
  static late AnimalListState value;

  @override
  Future<AnimalListState> build() async => value;
}

Widget _app(Widget home, {AnimalReferenceData? references, Animal? detail}) =>
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(FakeAuthController.new),
        animalListControllerProvider.overrideWith(FakeAnimalListController.new),
        if (references != null)
          animalReferencesProvider.overrideWith((ref, id) async => references),
        if (detail != null)
          animalDetailProvider.overrideWith((ref, id) async => detail),
      ],
      child: MaterialApp(home: home),
    );

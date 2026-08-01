import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/sync/sync_controller.dart';
import 'package:dairycare_mobile/core/sync/sync_models.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/features/foundation_home/application/dashboard_providers.dart';
import 'package:dairycare_mobile/features/foundation_home/presentation/foundation_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('dashboard emphasizes farm name above owner greeting', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FakeAuthController.session = foundationSession();
    FakeSyncController.status = const SyncStatus();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
          syncControllerProvider.overrideWith(FakeSyncController.new),
          cachedActiveAnimalCountProvider.overrideWith(
            (ref) => Stream.value(3),
          ),
        ],
        child: const MaterialApp(home: FoundationHomeScreen()),
      ),
    );
    await tester.pump();

    final header = find.byType(PageHeader);
    final farmFinder = find.descendant(
      of: header,
      matching: find.text('North Farm'),
    );
    final ownerFinder = find.descendant(
      of: header,
      matching: find.text('WELCOME BACK, AYESHA'),
    );
    expect(farmFinder, findsOneWidget);
    expect(ownerFinder, findsOneWidget);

    final farm = tester.widget<Text>(farmFinder);
    final owner = tester.widget<Text>(ownerFinder);
    expect(farm.style?.fontSize, greaterThan(owner.style?.fontSize ?? 0));
  });
}

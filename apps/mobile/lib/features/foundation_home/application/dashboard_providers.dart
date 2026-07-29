import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cachedActiveAnimalCountProvider = StreamProvider<int>((ref) {
  final session = ref.watch(authControllerProvider).asData?.value;
  final organizationId = session?.activeOrganizationId;
  if (organizationId == null) return Stream.value(0);

  return ref
      .watch(appDatabaseProvider)
      .watchAnimals(
        organizationId: organizationId,
        farmId: session?.activeFarmId,
      )
      .map((animals) => animals.length);
});

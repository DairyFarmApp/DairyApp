import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_movement_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalMovementRepositoryProvider = Provider<AnimalMovementRepository>(
  (ref) => AnimalMovementRepository(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(apiClientProvider),
  ),
);

final animalMovementHistoryProvider =
    FutureProvider.family<AnimalMovementLoadResult, String>((ref, animalId) {
      final organizationId = ref
          .watch(authControllerProvider)
          .asData
          ?.value
          ?.activeOrganizationId;
      if (organizationId == null) {
        return const AnimalMovementLoadResult(items: []);
      }
      return ref
          .watch(animalMovementRepositoryProvider)
          .getMovements(organizationId: organizationId, animalId: animalId);
    });

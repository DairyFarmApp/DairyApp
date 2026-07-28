import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_measurement_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_status_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_weight_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalMeasurementRepositoryProvider =
    Provider<AnimalMeasurementRepository>(
      (ref) => AnimalMeasurementRepository(
        database: ref.watch(appDatabaseProvider),
        api: ref.watch(apiClientProvider),
      ),
    );

final animalWeightHistoryProvider =
    FutureProvider.family<AnimalHistoryLoadResult<AnimalWeight>, String>((
      ref,
      animalId,
    ) {
      final organizationId = ref
          .watch(authControllerProvider)
          .asData
          ?.value
          ?.activeOrganizationId;
      if (organizationId == null) {
        return const AnimalHistoryLoadResult(items: []);
      }
      return ref
          .watch(animalMeasurementRepositoryProvider)
          .getWeights(organizationId: organizationId, animalId: animalId);
    });

final animalWeightDetailProvider = FutureProvider.family<AnimalWeight, String>(
  (ref, weightId) =>
      ref.watch(animalMeasurementRepositoryProvider).getWeight(weightId),
);

final animalStatusHistoryProvider =
    FutureProvider.family<AnimalHistoryLoadResult<AnimalStatusChange>, String>((
      ref,
      animalId,
    ) {
      final organizationId = ref
          .watch(authControllerProvider)
          .asData
          ?.value
          ?.activeOrganizationId;
      if (organizationId == null) {
        return const AnimalHistoryLoadResult(items: []);
      }
      return ref
          .watch(animalMeasurementRepositoryProvider)
          .getStatusHistory(organizationId: organizationId, animalId: animalId);
    });

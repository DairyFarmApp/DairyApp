import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/health/data/health_repository.dart';
import 'package:dairycare_mobile/features/health/domain/health_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final healthRepositoryProvider = Provider(
  (ref) => HealthRepository(api: ref.watch(apiClientProvider)),
);
final healthSymptomsProvider = FutureProvider<List<HealthSymptom>>(
  (ref) => ref.watch(healthRepositoryProvider).symptoms(),
);
final healthKnowledgeProvider = FutureProvider<List<HealthKnowledgeEntry>>(
  (ref) => ref.watch(healthRepositoryProvider).knowledge(),
);
final healthAiEvaluationCasesProvider =
    FutureProvider<List<HealthAiEvaluationCase>>(
      (ref) => ref.watch(healthRepositoryProvider).evaluationCases(),
    );
final animalHealthCasesProvider =
    FutureProvider.family<List<AnimalHealthCase>, String>(
      (ref, id) => ref.watch(healthRepositoryProvider).cases(id),
    );
final animalTreatmentsProvider =
    FutureProvider.family<List<AnimalTreatment>, String>(
      (ref, id) => ref.watch(healthRepositoryProvider).treatments(id),
    );
final animalPreventiveCareProvider =
    FutureProvider.family<List<PreventiveCareRecord>, String>(
      (ref, id) => ref.watch(healthRepositoryProvider).preventiveCare(id),
    );
final duePreventiveCareProvider = FutureProvider<List<PreventiveCareRecord>>(
  (ref) => ref.watch(healthRepositoryProvider).duePreventiveCare(),
);
final healthAiEvaluationReviewHistoryProvider =
    FutureProvider.family<List<HealthAiEvaluationReview>, String>(
      (ref, id) =>
          ref.watch(healthRepositoryProvider).evaluationReviewHistory(id),
    );
final healthMedicineEvidenceProvider =
    FutureProvider<List<HealthMedicineEvidence>>(
      (ref) => ref.watch(healthRepositoryProvider).medicineEvidence(),
    );

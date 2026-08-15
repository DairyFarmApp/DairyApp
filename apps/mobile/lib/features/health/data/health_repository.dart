import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/health/domain/health_models.dart';
import 'package:uuid/uuid.dart';

final class HealthRepository {
  HealthRepository({required ApiClient api, Uuid uuid = const Uuid()})
    : _api = api,
      _uuid = uuid;
  final ApiClient _api;
  final Uuid _uuid;
  Future<List<HealthSymptom>> symptoms() async {
    final body = await _api.getJson('/health/symptoms');
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(HealthSymptom.fromJson)
        .toList();
  }

  Future<List<HealthKnowledgeEntry>> knowledge({String? search}) async {
    final body = await _api.getJson(
      '/health/knowledge',
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(HealthKnowledgeEntry.fromJson)
        .toList();
  }

  Future<HealthAiAnswer> askHealthGuide(Map<String, dynamic> payload) async {
    final body = await _api.postJson('/health/ai/ask', data: payload);
    return HealthAiAnswer.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<HealthAiEvaluationCase>> evaluationCases() async {
    final body = await _api.getJson('/health/ai/evaluation-cases');
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(HealthAiEvaluationCase.fromJson)
        .toList();
  }

  Future<HealthAiEvaluationCase> reviewEvaluationCase(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.postJson(
      '/health/ai/evaluation-cases/$id/review',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    return HealthAiEvaluationCase.fromJson(
      body['data'] as Map<String, dynamic>,
    );
  }

  Future<List<HealthAiEvaluationReview>> evaluationReviewHistory(
    String id,
  ) async {
    final body = await _api.getJson('/health/ai/evaluation-cases/$id/reviews');
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(HealthAiEvaluationReview.fromJson)
        .toList();
  }

  Future<List<HealthMedicineEvidence>> medicineEvidence() async {
    final body = await _api.getJson('/health/medicine-evidence');
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(HealthMedicineEvidence.fromJson)
        .toList();
  }

  Future<HealthMedicineEvidence> reviewMedicineEvidence(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.postJson(
      '/health/medicine-evidence/$id/review',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    return HealthMedicineEvidence.fromJson(
      body['data'] as Map<String, dynamic>,
    );
  }

  Future<HealthKnowledgeEntry> reviewKnowledge(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.postJson(
      '/health/knowledge/$id/review',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    return HealthKnowledgeEntry.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<AnimalHealthCase>> cases(String animalId) async {
    final body = await _api.getJson('/animals/$animalId/health-cases');
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(AnimalHealthCase.fromJson)
        .toList();
  }

  Future<AnimalHealthCase> assess(
    String animalId,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.postJson(
      '/animals/$animalId/health-assessments',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    return AnimalHealthCase.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<AnimalTreatment>> treatments(String animalId) async {
    final body = await _api.getJson('/animals/$animalId/treatments');
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(AnimalTreatment.fromJson)
        .toList();
  }

  Future<AnimalTreatment> recordTreatment(
    String animalId,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.postJson(
      '/animals/$animalId/treatments',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    return AnimalTreatment.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<PreventiveCareRecord>> preventiveCare(String animalId) async {
    final body = await _api.getJson('/animals/$animalId/preventive-care');
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(PreventiveCareRecord.fromJson)
        .toList();
  }

  Future<List<PreventiveCareRecord>> duePreventiveCare() async {
    final body = await _api.getJson('/health/preventive-care/due');
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(PreventiveCareRecord.fromJson)
        .toList();
  }

  Future<void> recordPreventiveCare(Map<String, dynamic> payload) async {
    await _api.postJson(
      '/health/preventive-care',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
  }
}

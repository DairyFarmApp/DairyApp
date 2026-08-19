import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_feed_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalFeedRepositoryProvider = Provider<AnimalFeedRepository>((ref) {
  return AnimalFeedRepository(apiClient: ref.watch(apiClientProvider));
});

class AnimalFeedRepository {
  AnimalFeedRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AnimalFeedHistoryLoadResult> getFeedConsumptions({
    required String organizationId,
    required String animalId,
    int page = 1,
  }) async {
    final data = await _apiClient.getJson(
      '/animals/$animalId/feed-consumptions',
      query: {'page': page},
    );
    final meta = data['meta'] as Map<String, dynamic>?;
    return AnimalFeedHistoryLoadResult(
      items: ((data['data'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(AnimalFeedConsumption.fromJson)
          .toList(growable: false),
      currentPage: (meta?['current_page'] as int?) ?? 1,
      lastPage: (meta?['last_page'] as int?) ?? 1,
      total: (meta?['total'] as int?) ?? ((data['data'] as List?)?.length ?? 0),
    );
  }

  Future<AnimalFeedConsumption> recordFeedConsumption({
    required String animalId,
    required String inventoryItemId,
    required DateTime date,
    required String session,
    required double quantity,
    required String unit,
    String? notes,
  }) async {
    final data = await _apiClient.postJson(
      '/animals/$animalId/feed-consumptions',
      data: {
        'inventory_item_id': inventoryItemId,
        'date': date.toIso8601String().split('T').first,
        'session': session,
        'quantity': quantity,
        'unit': unit,
        'notes': notes,
      },
    );
    return AnimalFeedConsumption.fromJson(data['data'] as Map<String, dynamic>);
  }
}

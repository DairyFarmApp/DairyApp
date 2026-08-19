import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/milk/domain/milk_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalMilkRepositoryProvider = Provider<AnimalMilkRepository>((ref) {
  return AnimalMilkRepository(apiClient: ref.watch(apiClientProvider));
});

class AnimalMilkRepository {
  AnimalMilkRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AnimalMilkHistoryLoadResult> getMilkEntries({
    required String organizationId,
    required String animalId,
    int page = 1,
  }) async {
    final data = await _apiClient.getJson(
      '/animals/$animalId/milk-entries',
      query: {'page': page},
    );
    final meta = data['meta'] as Map<String, dynamic>?;
    return AnimalMilkHistoryLoadResult(
      items: ((data['data'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(MilkEntry.fromJson)
          .toList(growable: false),
      currentPage: (meta?['current_page'] as int?) ?? 1,
      lastPage: (meta?['last_page'] as int?) ?? 1,
      total: (meta?['total'] as int?) ?? ((data['data'] as List?)?.length ?? 0),
    );
  }
}

class AnimalMilkHistoryLoadResult {
  const AnimalMilkHistoryLoadResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<MilkEntry> items;
  final int currentPage;
  final int lastPage;
  final int total;
}

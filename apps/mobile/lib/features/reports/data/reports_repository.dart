import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/reports/domain/report_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportsRepositoryProvider = Provider((ref) {
  return ReportsRepository(ref.watch(apiClientProvider));
});

class ReportsRepository {
  const ReportsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AnimalDailyRecord>> getDailyProduction(DateTime date) async {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await _apiClient.getJson(
      '/reports/daily-animal-production',
      query: {'date': dateString},
    );
    final data = response['data'] as List<dynamic>? ?? const [];
    return data
        .cast<Map<String, dynamic>>()
        .map(AnimalDailyRecord.fromJson)
        .toList(growable: false);
  }
}

import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_sales_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalSalesRepositoryProvider = Provider<AnimalSalesRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AnimalSalesRepository(apiClient: apiClient);
});

final animalPurchasesProvider = FutureProvider<List<AnimalPurchase>>((
  ref,
) async {
  final repo = ref.watch(animalSalesRepositoryProvider);
  return await repo.getPurchases();
});

final animalSalesProvider = FutureProvider<List<AnimalSale>>((ref) async {
  final repo = ref.watch(animalSalesRepositoryProvider);
  return await repo.getSales();
});

class AnimalSalesRepository {
  final ApiClient _apiClient;

  AnimalSalesRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<List<AnimalPurchase>> getPurchases() async {
    final response = await _apiClient.getJson('/animal-purchases');

    if (response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => AnimalPurchase.fromJson(json)).toList();
    }

    return [];
  }

  Future<List<AnimalSale>> getSales() async {
    final response = await _apiClient.getJson('/animal-sales');

    if (response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => AnimalSale.fromJson(json)).toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> createPurchase(Map<String, dynamic> data) async {
    final response = await _apiClient.postJson('/animal-purchases', data: data);
    return response['data'] as Map<String, dynamic>;
  }

  Future<void> createSale(Map<String, dynamic> data) async {
    await _apiClient.postJson('/animal-sales', data: data);
  }
}

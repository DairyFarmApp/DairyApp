import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/commerce/domain/milk_sale_models.dart';
import 'package:uuid/uuid.dart';

final class MilkSalesRepository {
  MilkSalesRepository({required ApiClient api, Uuid uuid = const Uuid()})
    : _api = api,
      _uuid = uuid;
  final ApiClient _api;
  final Uuid _uuid;
  Future<MilkSalesOverview> list() async {
    final b = await _api.getJson('/milk-sales');
    return MilkSalesOverview.fromJson(b['data'] as Map<String, dynamic>);
  }

  Future<MilkSale> create(Map<String, dynamic> d) async {
    final b = await _api.postJson(
      '/milk-sales',
      data: d,
      idempotencyKey: _uuid.v7(),
    );
    return MilkSale.fromJson(b['data'] as Map<String, dynamic>);
  }

  Future<MilkSale> confirm(String id) async {
    final b = await _api.postJson(
      '/milk-sales/$id/confirm',
      data: const {},
      idempotencyKey: _uuid.v7(),
    );
    return MilkSale.fromJson(b['data'] as Map<String, dynamic>);
  }

  Future<MilkSale> pay(String id, Map<String, dynamic> d) async {
    final b = await _api.postJson(
      '/milk-sales/$id/payments',
      data: d,
      idempotencyKey: _uuid.v7(),
    );
    return MilkSale.fromJson(b['data'] as Map<String, dynamic>);
  }

  Future<MilkSale> cancel(String id, String reason) async {
    final b = await _api.postJson(
      '/milk-sales/$id/cancel',
      data: {'reason': reason},
      idempotencyKey: _uuid.v7(),
    );
    return MilkSale.fromJson(b['data'] as Map<String, dynamic>);
  }
}

import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/commerce/domain/purchase_models.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:uuid/uuid.dart';

final class PurchaseRepository {
  PurchaseRepository({required ApiClient api, Uuid uuid = const Uuid()})
    : _api = api,
      _uuid = uuid;
  final ApiClient _api;
  final Uuid _uuid;
  Future<List<PurchaseOrder>> list() async {
    final b = await _api.getJson('/purchase-orders');
    return (b['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(PurchaseOrder.fromJson)
        .toList();
  }

  Future<List<InventoryItem>> inventoryItems() async {
    final rows = await Future.wait(
      InventoryKind.values.map((k) => _api.getJson('/inventory/${k.apiValue}')),
    );
    return rows
        .expand(
          (b) => ((b['data'] as Map<String, dynamic>)['items'] as List)
              .cast<Map<String, dynamic>>()
              .map(InventoryItem.fromJson),
        )
        .toList();
  }

  Future<PurchaseOrder> create(Map<String, dynamic> data) async {
    final b = await _api.postJson(
      '/purchase-orders',
      data: data,
      idempotencyKey: _uuid.v7(),
    );
    return PurchaseOrder.fromJson(b['data'] as Map<String, dynamic>);
  }

  Future<PurchaseOrder> approve(String id) async {
    final b = await _api.postJson(
      '/purchase-orders/$id/approve',
      data: const {},
      idempotencyKey: _uuid.v7(),
    );
    return PurchaseOrder.fromJson(b['data'] as Map<String, dynamic>);
  }

  Future<PurchaseOrder> receive(String id, Map<String, dynamic> data) async {
    final b = await _api.postJson(
      '/purchase-orders/$id/receipts',
      data: data,
      idempotencyKey: _uuid.v7(),
    );
    return PurchaseOrder.fromJson(
      (b['data'] as Map<String, dynamic>)['purchase_order']
          as Map<String, dynamic>,
    );
  }
}

import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final class InventoryRepository {
  InventoryRepository({required ApiClient api, Uuid uuid = const Uuid()})
    : _api = api,
      _uuid = uuid;

  final ApiClient _api;
  final Uuid _uuid;

  Future<Map<InventoryKind, InventorySummary>> dashboard() async {
    final body = await _api.getJson('/inventory');
    final data = body['data'] as Map<String, dynamic>;
    return {
      for (final kind in InventoryKind.values)
        kind: InventorySummary.fromJson(
          data[kind.apiValue] as Map<String, dynamic>,
        ),
    };
  }

  Future<InventoryOverview> overview(
    InventoryKind kind, {
    String? search,
    String? category,
    String? supplier,
    bool lowStock = false,
  }) async {
    final query = <String, dynamic>{
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      'low_stock': lowStock ? 1 : 0,
    };
    query['category'] = category;
    query['supplier'] = supplier;
    query.removeWhere((_, value) => value == null);
    final body = await _api.getJson(
      '/inventory/${kind.apiValue}',
      query: query,
    );
    return InventoryOverview.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<InventoryItem> createItem(
    InventoryKind kind,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.postJson(
      '/inventory/${kind.apiValue}/items',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    return InventoryItem.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> receiveStock(
    InventoryItem item,
    Map<String, dynamic> payload,
  ) async {
    await _api.postJson(
      '/inventory/${item.kind.apiValue}/items/${item.id}/receipts',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
  }

  Future<void> adjustStock(
    InventoryItem item,
    Map<String, dynamic> payload,
  ) async {
    await _api.postJson(
      '/inventory/items/${item.id}/adjustments',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
  }

  Future<List<InventoryMovement>> movements(InventoryItem item) async {
    final body = await _api.getJson(
      '/inventory/${item.kind.apiValue}/items/${item.id}/movements',
    );
    final rows = (body['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    var balance = double.parse(item.currentStock);
    final movements = <InventoryMovement>[];
    for (final row in rows) {
      movements.add(
        InventoryMovement.fromJson(
          row,
          balanceAfter: balance.toStringAsFixed(3),
        ),
      );
      balance -= double.parse(row['quantity_change'].toString());
    }
    return movements;
  }

  Future<InventoryItem> updateItem(
    InventoryItem item,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.patchJson(
      '/inventory/${item.kind.apiValue}/items/${item.id}',
      data: {...payload, 'version': item.version},
    );
    return InventoryItem.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> archiveItem(InventoryItem item) async {
    await _api.deleteJson(
      '/inventory/${item.kind.apiValue}/items/${item.id}',
      data: {'version': item.version},
    );
  }

  Future<List<InventoryItem>> stockUsageItems() async {
    final overviews = await Future.wait(
      InventoryKind.values.map((kind) => overview(kind)),
    );
    return overviews
        .expand((overview) => overview.items)
        .where((item) => double.parse(item.currentStock) > 0)
        .toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<StockUsageRecord>> stockUsageHistory() async {
    final body = await _api.getJson('/inventory/usage');
    return (body['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(StockUsageRecord.fromJson)
        .toList(growable: false);
  }

  Future<void> recordStockUsage(
    InventoryItem item, {
    required String quantity,
    required String purpose,
  }) async {
    await _api.postJson(
      '/inventory/${item.kind.apiValue}/items/${item.id}/usage',
      data: {'quantity': quantity, 'purpose': purpose},
      idempotencyKey: _uuid.v7(),
    );
  }

  Future<InventoryExportFile> export(
    InventoryKind kind,
    InventoryExportFormat format, {
    Set<String> itemIds = const {},
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final date = DateFormat('yyyy-MM-dd');
    final bytes = await _api.getBytes(
      '/inventory/${kind.apiValue}/exports/${format.path}',
      query: {
        if (itemIds.isNotEmpty) 'item_ids': itemIds.toList(growable: false),
        if (fromDate != null) 'from_date': date.format(fromDate),
        if (toDate != null) 'to_date': date.format(toDate),
      },
    );
    final timestamp = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
    final descriptor = format == InventoryExportFormat.receipt
        ? 'receipt'
        : 'inventory';
    return InventoryExportFile(
      bytes: bytes,
      filename:
          'dairycare-${kind.apiValue}-$descriptor-$timestamp.${format.extension}',
      mimeType: format.mimeType,
    );
  }
}

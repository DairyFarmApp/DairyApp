import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/inventory/data/inventory_repository.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'inventory repository loads all three summaries and creates ledger items',
    () async {
      final requests = <RequestOptions>[];
      final repository = InventoryRepository(api: _api(requests));

      final dashboard = await repository.dashboard();
      final overview = await repository.overview(
        InventoryKind.medicine,
        search: 'oxytocin',
        lowStock: true,
      );
      final created = await repository.createItem(
        InventoryKind.medicine,
        const {'name': 'Oxytocin'},
      );
      final updated = await repository.updateItem(created, const {
        'name': 'Updated Oxytocin',
      });
      final exported = await repository.export(
        InventoryKind.medicine,
        InventoryExportFormat.spreadsheet,
        itemIds: const {'item-1'},
        fromDate: DateTime(2026, 7),
        toDate: DateTime(2026, 7, 31),
      );
      await repository.archiveItem(updated);

      expect(dashboard.keys, containsAll(InventoryKind.values));
      expect(overview.items.single.name, 'Oxytocin');
      expect(created.currentStock, '10.000');
      expect(updated.id, created.id);
      expect(exported.bytes, [80, 75]);
      expect(exported.filename, endsWith('.xlsx'));
      expect(
        requests.map((request) => '${request.method} ${request.path}'),
        containsAll([
          'GET /inventory',
          'GET /inventory/medicine',
          'POST /inventory/medicine/items',
          'PATCH /inventory/medicine/items/item-1',
          'GET /inventory/medicine/exports/spreadsheet',
          'DELETE /inventory/medicine/items/item-1',
        ]),
      );
      final overviewRequest = requests.firstWhere(
        (request) => request.path == '/inventory/medicine',
      );
      expect(overviewRequest.queryParameters['search'], 'oxytocin');
      expect(overviewRequest.queryParameters['low_stock'], 1);
      final exportRequest = requests.firstWhere(
        (request) => request.path == '/inventory/medicine/exports/spreadsheet',
      );
      expect(exportRequest.queryParameters['item_ids'], ['item-1']);
      expect(exportRequest.queryParameters['from_date'], '2026-07-01');
      expect(exportRequest.queryParameters['to_date'], '2026-07-31');
      final updateRequest = requests.firstWhere(
        (request) => request.method == 'PATCH',
      );
      expect(updateRequest.data, containsPair('version', 1));
      final deleteRequest = requests.firstWhere(
        (request) => request.method == 'DELETE',
      );
      expect(deleteRequest.data, {'version': 1});
    },
  );
}

ApiClient _api(List<RequestOptions> requests) {
  final dio = Dio();
  final api = ApiClient(
    config: EnvironmentConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: Uri.parse('http://example.test/api/v1'),
    ),
    readAccessToken: () async => 'token',
    dio: dio,
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        if (options.path.endsWith('/exports/spreadsheet')) {
          handler.resolve(
            Response<Object>(
              requestOptions: options,
              statusCode: 200,
              data: <int>[80, 75],
            ),
          );
          return;
        }
        final data = options.path == '/inventory'
            ? {
                'data': {
                  for (final kind in InventoryKind.values)
                    kind.name: _summary(),
                },
              }
            : options.path == '/inventory/medicine'
            ? {
                'data': {
                  'summary': _summary(),
                  'items': [_item()],
                  'filters': {
                    'categories': ['Injection'],
                    'suppliers': ['DairyVet'],
                  },
                },
              }
            : {'data': _item()};
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: options.method == 'POST' ? 201 : 200,
            data: data,
          ),
        );
      },
    ),
  );
  return api;
}

Map<String, Object> _summary() => {
  'item_count': 1,
  'total_stock': '10.000',
  'total_value': '1250.0000',
  'low_stock_items': 0,
  'expiring_soon_batches': 0,
  'expired_batches': 0,
};

Map<String, Object?> _item() => {
  'id': 'item-1',
  'organization_id': 'org-1',
  'farm_id': 'farm-1',
  'kind': 'medicine',
  'item_code': 'MED-001',
  'barcode': null,
  'name': 'Oxytocin',
  'category': 'Injection',
  'brand': 'DairyVet',
  'unit': 'vial',
  'minimum_stock': '2.000',
  'maximum_stock': '100.000',
  'current_stock': '10.000',
  'total_value': '1250.0000',
  'notes': null,
  'version': 1,
  'batches': [
    {
      'id': 'batch-1',
      'batch_number': 'B-001',
      'supplier': 'DairyVet',
      'purchase_date': '2026-07-29',
      'expiry_date': '2027-07-29',
      'unit_cost': '125.0000',
      'current_quantity': '10.000',
    },
  ],
};

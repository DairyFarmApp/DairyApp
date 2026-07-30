import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/inventory/data/inventory_repository.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>(
  (ref) => InventoryRepository(api: ref.watch(apiClientProvider)),
);

final inventoryDashboardProvider =
    FutureProvider<Map<InventoryKind, InventorySummary>>(
      (ref) => ref.watch(inventoryRepositoryProvider).dashboard(),
    );

typedef InventoryQuery = ({
  InventoryKind kind,
  String search,
  String? category,
  String? supplier,
  bool lowStock,
});

final inventoryOverviewProvider =
    FutureProvider.family<InventoryOverview, InventoryQuery>(
      (ref, query) => ref
          .watch(inventoryRepositoryProvider)
          .overview(
            query.kind,
            search: query.search,
            category: query.category,
            supplier: query.supplier,
            lowStock: query.lowStock,
          ),
    );

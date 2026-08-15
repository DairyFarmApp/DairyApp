import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/commerce/data/commercial_party_repository.dart';
import 'package:dairycare_mobile/features/commerce/domain/commercial_party_models.dart';
import 'package:dairycare_mobile/features/commerce/data/purchase_repository.dart';
import 'package:dairycare_mobile/features/commerce/domain/purchase_models.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:dairycare_mobile/features/commerce/data/supplier_invoice_repository.dart';
import 'package:dairycare_mobile/features/commerce/domain/supplier_invoice_models.dart';
import 'package:dairycare_mobile/features/commerce/data/milk_sales_repository.dart';
import 'package:dairycare_mobile/features/commerce/domain/milk_sale_models.dart';
import 'package:dairycare_mobile/features/commerce/data/delivery_repository.dart';
import 'package:dairycare_mobile/features/commerce/domain/delivery_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commercialPartyRepositoryProvider = Provider(
  (ref) => CommercialPartyRepository(api: ref.watch(apiClientProvider)),
);
final commercialPartiesProvider =
    FutureProvider.family<List<CommercialParty>, String>(
      (ref, kind) => ref.watch(commercialPartyRepositoryProvider).list(kind),
    );
final commercialLedgerProvider =
    FutureProvider.family<
      List<CommercialLedgerEntry>,
      ({String kind, String id})
    >(
      (ref, query) => ref
          .watch(commercialPartyRepositoryProvider)
          .ledger(query.kind, query.id),
    );
final purchaseRepositoryProvider = Provider(
  (ref) => PurchaseRepository(api: ref.watch(apiClientProvider)),
);
final purchaseOrdersProvider = FutureProvider<List<PurchaseOrder>>(
  (ref) => ref.watch(purchaseRepositoryProvider).list(),
);
final purchaseInventoryItemsProvider = FutureProvider<List<InventoryItem>>(
  (ref) => ref.watch(purchaseRepositoryProvider).inventoryItems(),
);
final supplierInvoiceRepositoryProvider = Provider(
  (ref) => SupplierInvoiceRepository(api: ref.watch(apiClientProvider)),
);
final supplierInvoicesProvider = FutureProvider<List<SupplierInvoice>>(
  (ref) => ref.watch(supplierInvoiceRepositoryProvider).list(),
);
final milkSalesRepositoryProvider = Provider(
  (ref) => MilkSalesRepository(api: ref.watch(apiClientProvider)),
);
final milkSalesProvider = FutureProvider<MilkSalesOverview>(
  (ref) => ref.watch(milkSalesRepositoryProvider).list(),
);
final deliveryRepositoryProvider = Provider(
  (ref) => DeliveryRepository(api: ref.watch(apiClientProvider)),
);
final deliveriesProvider = FutureProvider<DeliveryOverview>(
  (ref) => ref.watch(deliveryRepositoryProvider).overview(),
);

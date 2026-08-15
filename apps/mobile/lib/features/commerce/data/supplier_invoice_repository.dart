import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/commerce/domain/supplier_invoice_models.dart';
import 'package:uuid/uuid.dart';

final class SupplierInvoiceRepository {
  SupplierInvoiceRepository({required ApiClient api, Uuid uuid = const Uuid()})
    : _api = api,
      _uuid = uuid;
  final ApiClient _api;
  final Uuid _uuid;
  Future<List<SupplierInvoice>> list() async {
    final b = await _api.getJson('/supplier-invoices');
    return (b['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(SupplierInvoice.fromJson)
        .toList();
  }

  Future<SupplierInvoice> create(Map<String, dynamic> data) async {
    final b = await _api.postJson(
      '/supplier-invoices',
      data: data,
      idempotencyKey: _uuid.v7(),
    );
    return SupplierInvoice.fromJson(b['data'] as Map<String, dynamic>);
  }

  Future<SupplierInvoice> pay(String id, Map<String, dynamic> data) async {
    final b = await _api.postJson(
      '/supplier-invoices/$id/payments',
      data: data,
      idempotencyKey: _uuid.v7(),
    );
    return SupplierInvoice.fromJson(b['data'] as Map<String, dynamic>);
  }
}

import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/commerce/domain/delivery_models.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';

final class DeliveryRepository {
  DeliveryRepository({required ApiClient api, Uuid uuid = const Uuid()})
    : _api = api,
      _uuid = uuid;
  final ApiClient _api;
  final Uuid _uuid;
  Future<DeliveryOverview> overview() async => DeliveryOverview.fromJson(
    (await _api.getJson('/deliveries'))['data'] as Map<String, dynamic>,
  );
  Future<void> createRoute(Map<String, dynamic> data) =>
      _post('/delivery-routes', data);
  Future<void> createVehicle(Map<String, dynamic> data) =>
      _post('/delivery-vehicles', data);
  Future<void> createDriver(Map<String, dynamic> data) =>
      _post('/delivery-drivers', data);
  Future<void> createManifest(Map<String, dynamic> data) =>
      _post('/delivery-manifests', data);
  Future<void> dispatch(String id, String loaded) =>
      _post('/delivery-manifests/$id/dispatch', {'loaded_quantity': loaded});
  Future<void> completeStop(
    String manifestId,
    String stopId,
    Map<String, dynamic> data,
  ) => _post('/delivery-manifests/$manifestId/stops/$stopId/complete', data);
  Future<void> uploadProof(
    String manifestId,
    String stopId,
    Uint8List bytes,
    String filename,
  ) async {
    await _api.postMultipart(
      '/delivery-manifests/$manifestId/stops/$stopId/proof',
      fields: const {},
      fileField: 'proof',
      bytes: bytes,
      filename: filename,
      idempotencyKey: _uuid.v7(),
    );
  }

  Future<String> refund(
    String manifestId,
    String stopId,
    Map<String, dynamic> data,
  ) async {
    final body = await _api.postJson(
      '/delivery-manifests/$manifestId/stops/$stopId/refunds',
      data: data,
      idempotencyKey: _uuid.v7(),
    );
    return '${(body['data'] as Map<String, dynamic>)['id']}';
  }

  Future<Uint8List> deliveryNote(String id) =>
      _api.getBytes('/delivery-manifests/$id/delivery-note.pdf');
  Future<Uint8List> refundReceipt(String id) =>
      _api.getBytes('/customer-refunds/$id/receipt.pdf');
  Future<Uint8List> export({DateTime? from, DateTime? to, String? status}) =>
      _api.getBytes(
        '/deliveries/export.xlsx',
        query: {
          if (from != null)
            'from_date': from.toIso8601String().split('T').first,
          if (to != null) 'to_date': to.toIso8601String().split('T').first,
          if (status != null && status != 'all') 'status': status,
        },
      );

  Future<void> _post(String path, Map<String, dynamic> data) async {
    await _api.postJson(path, data: data, idempotencyKey: _uuid.v7());
  }
}

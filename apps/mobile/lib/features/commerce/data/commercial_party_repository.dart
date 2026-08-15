import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/commerce/domain/commercial_party_models.dart';
import 'package:uuid/uuid.dart';

final class CommercialPartyRepository {
  CommercialPartyRepository({required ApiClient api, Uuid uuid = const Uuid()})
    : _api = api,
      _uuid = uuid;
  final ApiClient _api;
  final Uuid _uuid;
  Future<List<CommercialParty>> list(String kind) async {
    final body = await _api.getJson('/$kind');
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (j) => CommercialParty.fromJson(
            j,
            fallbackType: kind == 'suppliers' ? 'supplier' : 'individual',
          ),
        )
        .toList(growable: false);
  }

  Future<CommercialParty> create(
    String kind,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.postJson(
      '/$kind',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    return CommercialParty.fromJson(
      body['data'] as Map<String, dynamic>,
      fallbackType: kind == 'suppliers' ? 'supplier' : 'individual',
    );
  }

  Future<CommercialParty> update(
    String kind,
    CommercialParty party,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.patchJson(
      '/$kind/${party.id}',
      data: {...payload, 'version': party.version},
    );
    return CommercialParty.fromJson(
      body['data'] as Map<String, dynamic>,
      fallbackType: party.type,
    );
  }

  Future<void> archive(String kind, String id) => _api.delete('/$kind/$id');
  Future<List<CommercialLedgerEntry>> ledger(String kind, String id) async {
    final body = await _api.getJson('/$kind/$id/ledger');
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(CommercialLedgerEntry.fromJson)
        .toList(growable: false);
  }
}

import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/visitors/domain/visitor_record.dart';
import 'package:uuid/uuid.dart';

final class VisitorRepository {
  VisitorRepository(this._api);
  final ApiClient _api;

  Future<List<VisitorRecord>> list() async {
    final body = await _api.getJson('/visitors');
    return ((body['data'] as Map<String, dynamic>)['visitors'] as List)
        .cast<Map<String, dynamic>>()
        .map(VisitorRecord.fromJson)
        .toList();
  }

  Future<void> create({
    required String name,
    required DateTime visitedAt,
    required String purpose,
  }) => _api.postJson(
    '/visitors',
    idempotencyKey: const Uuid().v7(),
    data: {
      'visitor_name': name,
      'visited_at': visitedAt.toUtc().toIso8601String(),
      'purpose': purpose,
    },
  );

  Future<void> delete(String id) => _api.delete('/visitors/$id');
}

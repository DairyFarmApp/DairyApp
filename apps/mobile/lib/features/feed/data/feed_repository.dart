import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/feed/domain/feed_models.dart';
import 'package:uuid/uuid.dart';

final class FeedRepository {
  FeedRepository({required ApiClient api, Uuid uuid = const Uuid()})
    : _api = api,
      _uuid = uuid;

  final ApiClient _api;
  final Uuid _uuid;

  Future<List<FeedRationPlan>> fetchRationPlans() async {
    final body = await _api.getJson('/feed-ration-plans');
    return (body['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(FeedRationPlan.fromJson)
        .toList(growable: false);
  }

  Future<FeedRationPlan> fetchRationPlan(String id) async {
    final body = await _api.getJson('/feed-ration-plans/$id');
    return FeedRationPlan.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<FeedRationPlan> createRationPlan(Map<String, dynamic> payload) async {
    final body = await _api.postJson(
      '/feed-ration-plans',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    return FeedRationPlan.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<DailyFeedIssue>> fetchDailyFeedIssues() async {
    final body = await _api.getJson('/daily-feed-issues');
    return (body['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(DailyFeedIssue.fromJson)
        .toList(growable: false);
  }

  Future<DailyFeedIssue> createDailyFeedIssue(
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.postJson(
      '/daily-feed-issues',
      data: payload,
      idempotencyKey: _uuid.v7(),
    );
    return DailyFeedIssue.fromJson(body['data'] as Map<String, dynamic>);
  }
}

import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/feed/data/feed_repository.dart';
import 'package:dairycare_mobile/features/feed/domain/feed_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => FeedRepository(api: ref.watch(apiClientProvider)),
);

final feedRationPlansProvider = FutureProvider<List<FeedRationPlan>>((ref) {
  return ref.watch(feedRepositoryProvider).fetchRationPlans();
});

final dailyFeedIssuesProvider = FutureProvider<List<DailyFeedIssue>>((ref) {
  return ref.watch(feedRepositoryProvider).fetchDailyFeedIssues();
});

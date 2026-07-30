import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/milk/data/milk_repository.dart';
import 'package:dairycare_mobile/features/milk/domain/milk_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final milkRepositoryProvider = Provider<MilkRepository>(
  (ref) => MilkRepository(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(apiClientProvider),
  ),
);

typedef MilkDailyQuery = ({
  String organizationId,
  String farmId,
  DateTime date,
  MilkingSession session,
});

final milkDailyProvider = FutureProvider.family<MilkDailyData, MilkDailyQuery>(
  (ref, query) => ref
      .watch(milkRepositoryProvider)
      .daily(
        organizationId: query.organizationId,
        farmId: query.farmId,
        date: query.date,
        session: query.session,
      ),
);

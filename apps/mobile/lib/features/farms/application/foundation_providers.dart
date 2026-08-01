import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/farms/data/foundation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final foundationRepositoryProvider = Provider<FoundationRepository>(
  (ref) => FoundationRepository(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(apiClientProvider),
  ),
);

typedef FarmProfileQuery = ({String organizationId, String farmId});

final farmProfileProvider = FutureProvider.family<LocalFarm, FarmProfileQuery>(
  (ref, query) => ref
      .watch(foundationRepositoryProvider)
      .loadFarm(organizationId: query.organizationId, farmId: query.farmId),
);

final shedListProvider =
    FutureProvider.family<List<LocalShed>, FarmProfileQuery>(
      (ref, query) => ref
          .watch(foundationRepositoryProvider)
          .loadSheds(
            organizationId: query.organizationId,
            farmId: query.farmId,
          ),
    );

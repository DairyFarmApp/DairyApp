import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/farms/data/foundation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final foundationRepositoryProvider = Provider<FoundationRepository>(
  (ref) => FoundationRepository(ref.watch(appDatabaseProvider)),
);

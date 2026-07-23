import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/storage/secure_session_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final environmentProvider = Provider<EnvironmentConfig>(
  (ref) => EnvironmentConfig.fromCompileTime(),
);

final sessionStoreProvider = Provider<SessionStore>(
  (ref) => SecureSessionStore(),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    config: ref.watch(environmentProvider),
    readAccessToken: ref.watch(sessionStoreProvider).readAccessToken,
  ),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

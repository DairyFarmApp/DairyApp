import 'package:dairycare_mobile/core/auth/auth_repository.dart';
import 'package:dairycare_mobile/core/auth/session_models.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() => ref.watch(authRepositoryProvider).restore();

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .login(email: email, password: password),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  Future<void> switchOrganization(String organizationId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).switchOrganization(organizationId),
    );
  }

  Future<void> switchFarm(String farmId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).switchFarm(farmId),
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    api: ref.watch(apiClientProvider),
    store: ref.watch(sessionStoreProvider),
  ),
);

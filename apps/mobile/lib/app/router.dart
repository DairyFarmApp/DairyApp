import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/auth/session_models.dart';
import 'package:dairycare_mobile/features/authentication/presentation/login_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_detail_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_form_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_group_management_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_list_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/breed_management_screen.dart';
import 'package:dairycare_mobile/features/farms/presentation/farm_selection_screen.dart';
import 'package:dairycare_mobile/features/farms/presentation/farm_list_screen.dart';
import 'package:dairycare_mobile/features/foundation_home/presentation/foundation_home_screen.dart';
import 'package:dairycare_mobile/features/foundation_home/presentation/foundation_shell.dart';
import 'package:dairycare_mobile/features/foundation_home/presentation/sync_diagnostics_screen.dart';
import 'package:dairycare_mobile/features/organizations/presentation/organization_selection_screen.dart';
import 'package:dairycare_mobile/features/sheds/presentation/shed_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(
      auth: ref.read(authControllerProvider),
      path: state.matchedLocation,
    ),
    routes: [
      GoRoute(path: '/loading', builder: (_, _) => const _LoadingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/organizations/select',
        builder: (_, _) => const OrganizationSelectionScreen(),
      ),
      GoRoute(
        path: '/farms/select',
        builder: (_, _) => const FarmSelectionScreen(),
      ),
      ShellRoute(
        builder: (_, _, child) => FoundationShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => const FoundationHomeScreen(),
          ),
          GoRoute(path: '/farms', builder: (_, _) => const FarmListScreen()),
          GoRoute(path: '/sheds', builder: (_, _) => const ShedListScreen()),
          GoRoute(
            path: '/animals',
            builder: (_, _) => const AnimalListScreen(),
          ),
          GoRoute(
            path: '/animals/new',
            builder: (_, _) => const AnimalFormScreen(),
          ),
          GoRoute(
            path: '/animals/:animalId/edit',
            builder: (_, state) =>
                AnimalFormScreen(animalId: state.pathParameters['animalId']!),
          ),
          GoRoute(
            path: '/animals/:animalId',
            builder: (_, state) =>
                AnimalDetailScreen(animalId: state.pathParameters['animalId']!),
          ),
          GoRoute(
            path: '/animal-breeds',
            builder: (_, _) => const BreedManagementScreen(),
          ),
          GoRoute(
            path: '/animal-groups',
            builder: (_, _) => const AnimalGroupManagementScreen(),
          ),
          GoRoute(
            path: '/sync',
            builder: (_, _) => const SyncDiagnosticsScreen(),
          ),
        ],
      ),
    ],
  );
});

String? authRedirect({
  required AsyncValue<AuthSession?> auth,
  required String path,
}) {
  if (auth.isLoading) return path == '/loading' ? null : '/loading';
  final session = auth.asData?.value;
  if (session == null) return path == '/login' ? null : '/login';
  if (path == '/login' || path == '/loading') {
    if (session.activeOrganizationId == null) return '/organizations/select';
    if (session.activeFarmId == null) return '/farms/select';
    return '/home';
  }
  if (session.activeOrganizationId == null && path != '/organizations/select') {
    return '/organizations/select';
  }
  if (session.activeFarmId == null &&
      path != '/farms/select' &&
      path != '/organizations/select') {
    return '/farms/select';
  }
  return null;
}

final class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    _subscription = ref.listen(
      authControllerProvider,
      (_, _) => notifyListeners(),
    );
  }

  late final ProviderSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

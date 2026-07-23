import 'dart:async';

import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalRepositoryProvider = Provider<AnimalRepository>(
  (ref) => AnimalRepository(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(apiClientProvider),
  ),
);

final animalReferencesProvider =
    FutureProvider.family<AnimalReferenceData, String>(
      (ref, organizationId) =>
          ref.watch(animalRepositoryProvider).loadReferences(organizationId),
    );

final animalDetailProvider = FutureProvider.family<Animal, String>(
  (ref, id) => ref.watch(animalRepositoryProvider).getAnimal(id),
);

final animalListControllerProvider =
    AsyncNotifierProvider<AnimalListController, AnimalListState>(
      AnimalListController.new,
    );

final class AnimalListState {
  const AnimalListState({
    required this.items,
    required this.filters,
    this.isCachedResult = false,
  });

  final List<Animal> items;
  final AnimalFilters filters;
  final bool isCachedResult;
}

class AnimalListController extends AsyncNotifier<AnimalListState> {
  Timer? _searchTimer;
  AnimalFilters _filters = const AnimalFilters();

  @override
  Future<AnimalListState> build() async {
    ref.onDispose(() => _searchTimer?.cancel());
    final session = ref.watch(authControllerProvider).asData?.value;
    if (session?.activeOrganizationId == null) {
      return AnimalListState(items: const [], filters: _filters);
    }
    if (_filters.farmId == null && session?.activeFarmId != null) {
      _filters = _filters.copyWith(farmId: session!.activeFarmId);
    }
    return _load(session!.activeOrganizationId!);
  }

  Future<void> refresh() async {
    final organizationId = ref
        .read(authControllerProvider)
        .asData
        ?.value
        ?.activeOrganizationId;
    if (organizationId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(organizationId));
  }

  void setSearch(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 350), () {
      _filters = _filters.copyWith(search: value);
      unawaited(refresh());
    });
  }

  Future<void> setFilters(AnimalFilters filters) async {
    _filters = filters;
    await refresh();
  }

  Future<AnimalListState> _load(String organizationId) async {
    final repository = ref.read(animalRepositoryProvider);
    try {
      final items = await repository.refreshAnimals(
        organizationId: organizationId,
        filters: _filters,
      );
      return AnimalListState(items: items, filters: _filters);
    } on NetworkException {
      return _cached(repository, organizationId);
    } on TransientServerException {
      return _cached(repository, organizationId);
    }
  }

  Future<AnimalListState> _cached(
    AnimalRepository repository,
    String organizationId,
  ) async {
    final items = await repository
        .watchCachedAnimals(organizationId: organizationId, filters: _filters)
        .first;
    return AnimalListState(
      items: items,
      filters: _filters,
      isCachedResult: true,
    );
  }
}

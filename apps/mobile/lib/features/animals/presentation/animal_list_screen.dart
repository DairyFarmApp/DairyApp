import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_registry_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class AnimalListScreen extends ConsumerStatefulWidget {
  const AnimalListScreen({super.key});

  @override
  ConsumerState<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends ConsumerState<AnimalListScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(animalListControllerProvider);
    final canCreate =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('animals.create') ??
        false;
    final session = ref.watch(authControllerProvider).asData?.value;
    final organizationId = session?.activeOrganizationId;
    final references = organizationId == null
        ? null
        : ref.watch(animalReferencesProvider(organizationId)).asData?.value;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  AnimalRegistryStrings.animals,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (session?.can('animal_breeds.view') ?? false)
                  OutlinedButton.icon(
                    onPressed: () => context.go('/animal-breeds'),
                    icon: const Icon(Icons.category_outlined),
                    label: const Text(AnimalRegistryStrings.breeds),
                  ),
                if (session?.can('animal_groups.view') ?? false)
                  OutlinedButton.icon(
                    onPressed: () => context.go('/animal-groups'),
                    icon: const Icon(Icons.groups_outlined),
                    label: const Text(AnimalRegistryStrings.groups),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('animal_search'),
                    controller: _search,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: AnimalRegistryStrings.searchHint,
                    ),
                    onChanged: ref
                        .read(animalListControllerProvider.notifier)
                        .setSearch,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Filters',
                  onPressed: list.asData == null || references == null
                      ? null
                      : () => _showFilters(
                          context,
                          list.requireValue.filters,
                          references,
                          session?.activeFarmId,
                        ),
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: list.when(
                loading: () =>
                    const LoadingStateView(label: 'Loading animals…'),
                error: (error, _) => ErrorStateView(
                  message: error.toString(),
                  onRetry: ref
                      .read(animalListControllerProvider.notifier)
                      .refresh,
                ),
                data: (value) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (value.isCachedResult)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          avatar: Icon(Icons.offline_pin_outlined),
                          label: Text(AnimalRegistryStrings.cachedResult),
                        ),
                      ),
                    Expanded(
                      child: value.items.isEmpty
                          ? const EmptyStateView(
                              message: AnimalRegistryStrings.noAnimals,
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) =>
                                  constraints.maxWidth >= 850
                                  ? _AnimalTable(items: value.items)
                                  : _AnimalCards(items: value.items),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/animals/new'),
              icon: const Icon(Icons.add),
              label: const Text(AnimalRegistryStrings.addAnimal),
            )
          : null,
    );
  }

  Future<void> _showFilters(
    BuildContext context,
    AnimalFilters current,
    AnimalReferenceData references,
    String? defaultFarmId,
  ) async {
    var speciesId = current.speciesId;
    var breedId = current.breedId;
    var farmId = current.farmId;
    var shedId = current.shedId;
    var groupId = current.groupId;
    var sex = current.sex;
    var lifeStage = current.lifeStage;
    var status = current.operationalStatus;
    var archive = current.archiveState;
    final result = await showDialog<AnimalFilters>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final breeds = references.breeds
              .where((item) => speciesId == null || item.speciesId == speciesId)
              .toList();
          final sheds = references.sheds
              .where((item) => farmId == null || item.farmId == farmId)
              .toList();
          final groups = references.groups
              .where((item) => farmId == null || item.farmId == farmId)
              .toList();
          return AlertDialog(
            title: const Text('Animal filters'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _referenceDropdown(
                      label: 'Species',
                      value: speciesId,
                      items: [
                        for (final item in references.species)
                          (item.id, item.name),
                      ],
                      onChanged: (value) => setState(() {
                        speciesId = value;
                        breedId = null;
                      }),
                    ),
                    _referenceDropdown(
                      label: 'Breed',
                      value: breedId,
                      items: [for (final item in breeds) (item.id, item.name)],
                      onChanged: (value) => setState(() => breedId = value),
                    ),
                    _filterDropdown(
                      label: 'Sex',
                      value: sex,
                      values: const ['female', 'male'],
                      onChanged: (value) => setState(() => sex = value),
                    ),
                    _filterDropdown(
                      label: 'Life stage',
                      value: lifeStage,
                      values: const ['calf', 'juvenile', 'adult'],
                      onChanged: (value) => setState(() => lifeStage = value),
                    ),
                    _referenceDropdown(
                      label: 'Farm',
                      value: farmId,
                      items: [
                        for (final item in references.farms)
                          (item.id, item.name),
                      ],
                      onChanged: (value) => setState(() {
                        farmId = value;
                        shedId = null;
                        groupId = null;
                      }),
                    ),
                    _referenceDropdown(
                      label: 'Shed',
                      value: shedId,
                      items: [for (final item in sheds) (item.id, item.name)],
                      onChanged: (value) => setState(() => shedId = value),
                    ),
                    _referenceDropdown(
                      label: 'Group',
                      value: groupId,
                      items: [for (final item in groups) (item.id, item.name)],
                      onChanged: (value) => setState(() => groupId = value),
                    ),
                    _filterDropdown(
                      label: 'Operational status',
                      value: status,
                      values: const ['active', 'inactive', 'missing'],
                      onChanged: (value) => setState(() => status = value),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: archive,
                      decoration: const InputDecoration(
                        labelText: 'Archive state',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: 'archived',
                          child: Text('Archived'),
                        ),
                        DropdownMenuItem(value: 'all', child: Text('All')),
                      ],
                      onChanged: (value) =>
                          setState(() => archive = value ?? 'active'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  current.copyWith(
                    farmId: defaultFarmId,
                    clearSpecies: true,
                    clearBreed: true,
                    clearSex: true,
                    clearLifeStage: true,
                    clearFarm: defaultFarmId == null,
                    clearShed: true,
                    clearGroup: true,
                    clearOperationalStatus: true,
                    archiveState: 'active',
                  ),
                ),
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AnimalRegistryStrings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  current.copyWith(
                    speciesId: speciesId,
                    breedId: breedId,
                    farmId: farmId,
                    shedId: shedId,
                    groupId: groupId,
                    sex: sex,
                    lifeStage: lifeStage,
                    operationalStatus: status,
                    archiveState: archive,
                    clearSex: sex == null,
                    clearLifeStage: lifeStage == null,
                    clearSpecies: speciesId == null,
                    clearBreed: breedId == null,
                    clearFarm: farmId == null,
                    clearShed: shedId == null,
                    clearGroup: groupId == null,
                    clearOperationalStatus: status == null,
                  ),
                ),
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
    if (result != null) {
      await ref.read(animalListControllerProvider.notifier).setFilters(result);
    }
  }

  Widget _filterDropdown({
    required String label,
    required String? value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem(value: null, child: Text('Any')),
        for (final item in values)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: onChanged,
    ),
  );

  Widget _referenceDropdown({
    required String label,
    required String? value,
    required List<(String, String)> items,
    required ValueChanged<String?> onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      initialValue: items.any((item) => item.$1 == value) ? value : null,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem(value: null, child: Text('Any')),
        for (final item in items)
          DropdownMenuItem(value: item.$1, child: Text(item.$2)),
      ],
      onChanged: onChanged,
    ),
  );
}

final class _AnimalCards extends StatelessWidget {
  const _AnimalCards({required this.items});

  final List<Animal> items;

  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      final animal = items[index];
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            child: Text(animal.sex == 'female' ? 'F' : 'M'),
          ),
          title: Text(
            animal.name == null
                ? animal.animalNumber
                : '${animal.animalNumber} · ${animal.name}',
          ),
          subtitle: Text(
            '${animal.speciesName} · ${animal.breedName}\n'
            '${animal.currentShedName} · ${animal.operationalStatus}',
          ),
          isThreeLine: true,
          trailing: animal.isArchived
              ? const Icon(Icons.archive_outlined)
              : const Icon(Icons.chevron_right),
          onTap: () => context.go('/animals/${animal.id}'),
        ),
      );
    },
  );
}

final class _AnimalTable extends StatelessWidget {
  const _AnimalTable({required this.items});

  final List<Animal> items;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Animal number')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Species / breed')),
          DataColumn(label: Text('Sex / stage')),
          DataColumn(label: Text('Location')),
          DataColumn(label: Text('Status')),
        ],
        rows: [
          for (final animal in items)
            DataRow(
              onSelectChanged: (_) => context.go('/animals/${animal.id}'),
              cells: [
                DataCell(Text(animal.animalNumber)),
                DataCell(Text(animal.name ?? '—')),
                DataCell(Text('${animal.speciesName} / ${animal.breedName}')),
                DataCell(Text('${animal.sex} / ${animal.lifeStage}')),
                DataCell(Text(animal.currentShedName)),
                DataCell(
                  Text(
                    animal.isArchived ? 'archived' : animal.operationalStatus,
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

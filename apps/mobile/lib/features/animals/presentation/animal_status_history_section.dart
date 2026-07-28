import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_measurement_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_measurement_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_status_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class AnimalStatusHistorySection extends ConsumerStatefulWidget {
  const AnimalStatusHistorySection({super.key, required this.animal});

  final Animal animal;

  @override
  ConsumerState<AnimalStatusHistorySection> createState() =>
      _AnimalStatusHistorySectionState();
}

class _AnimalStatusHistorySectionState
    extends ConsumerState<AnimalStatusHistorySection> {
  final List<AnimalStatusChange> _additional = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final canView = session?.can('animals.view_status_history') ?? false;
    final history = canView
        ? ref.watch(animalStatusHistoryProvider(widget.animal.id))
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Operational-status history',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (!widget.animal.isArchived &&
                (session?.can('animals.change_status') ?? false))
              FilledButton.icon(
                key: const Key('change_status_action'),
                onPressed: () => context.push(
                  '/animals/${widget.animal.id}/status-changes/new',
                ),
                icon: const Icon(Icons.change_circle_outlined),
                label: const Text('Change status'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!canView)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Status history is unavailable with your current permissions.',
              ),
            ),
          )
        else
          history!.when(
            loading: () => const SizedBox(
              height: 140,
              child: LoadingStateView(label: 'Loading status history...'),
            ),
            error: (error, _) => SizedBox(
              height: 160,
              child: ErrorStateView(
                message: error.toString(),
                onRetry: () {
                  setState(() {
                    _additional.clear();
                    _page = 1;
                  });
                  ref.invalidate(animalStatusHistoryProvider(widget.animal.id));
                },
              ),
            ),
            data: (result) => _history(context, result),
          ),
      ],
    );
  }

  Widget _history(
    BuildContext context,
    AnimalHistoryLoadResult<AnimalStatusChange> result,
  ) {
    final byId = <String, AnimalStatusChange>{
      for (final item in result.items) item.id: item,
      for (final item in _additional) item.id: item,
    };
    final items = byId.values.toList(growable: false);
    if (items.isEmpty) {
      return const SizedBox(
        height: 100,
        child: EmptyStateView(
          message: 'No operational-status changes recorded.',
        ),
      );
    }
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result.isCached)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.offline_bolt_outlined, size: 18),
                SizedBox(width: 6),
                Text('Showing cached status history'),
              ],
            ),
          ),
        if (width >= 760)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Sequence')),
                DataColumn(label: Text('Effective')),
                DataColumn(label: Text('Transition')),
                DataColumn(label: Text('Reason')),
                DataColumn(label: Text('Changed by')),
              ],
              rows: [
                for (final change in items)
                  DataRow(
                    cells: [
                      DataCell(Text('${change.sequence}')),
                      DataCell(Text(_date(change.effectiveAt))),
                      DataCell(_transition(change)),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: Text(change.reason),
                        ),
                      ),
                      DataCell(Text(change.changedByName)),
                    ],
                  ),
              ],
            ),
          )
        else
          for (final change in items)
            Card(
              key: Key('status_change_${change.id}'),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _transition(change),
                        const Spacer(),
                        Text('#${change.sequence}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_date(change.effectiveAt)),
                    Text(change.reason),
                    if (change.changedByName.isNotEmpty)
                      Text('Changed by ${change.changedByName}'),
                  ],
                ),
              ),
            ),
        if (!result.isCached &&
            _page < (_page == 1 ? result.lastPage : _lastPage))
          Align(
            alignment: Alignment.center,
            child: OutlinedButton.icon(
              key: const Key('load_more_status_history'),
              onPressed: _loadingMore ? null : _loadMore,
              icon: _loadingMore
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more),
              label: const Text('Load more status history'),
            ),
          ),
      ],
    );
  }

  Future<void> _loadMore() async {
    final organizationId = ref
        .read(authControllerProvider)
        .asData
        ?.value
        ?.activeOrganizationId;
    if (organizationId == null) return;
    setState(() => _loadingMore = true);
    try {
      final next = await ref
          .read(animalMeasurementRepositoryProvider)
          .getStatusHistory(
            organizationId: organizationId,
            animalId: widget.animal.id,
            page: _page + 1,
          );
      if (!mounted) return;
      setState(() {
        _additional.addAll(next.items);
        _page = next.currentPage;
        _lastPage = next.lastPage;
      });
    } on AppException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Widget _transition(AnimalStatusChange change) => Wrap(
    spacing: 4,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      _statusChip(change.previousStatus),
      const Icon(Icons.arrow_forward, size: 16),
      _statusChip(change.newStatus),
    ],
  );

  Widget _statusChip(String status) {
    final color = switch (status) {
      'active' => Colors.green,
      'missing' => Colors.red,
      _ => Colors.orange,
    };
    return Chip(
      key: Key('operational_status_$status'),
      label: Text(_label(status)),
      side: BorderSide(color: color),
      visualDensity: VisualDensity.compact,
    );
  }

  String _date(DateTime value) =>
      DateFormat.yMMMd().add_jm().format(value.toLocal());

  String _label(String value) => value
      .split('_')
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

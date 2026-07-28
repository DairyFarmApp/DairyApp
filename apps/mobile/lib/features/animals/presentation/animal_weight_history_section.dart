import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/auth/session_models.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_measurement_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_measurement_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_weight_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class AnimalWeightHistorySection extends ConsumerStatefulWidget {
  const AnimalWeightHistorySection({super.key, required this.animal});

  final Animal animal;

  @override
  ConsumerState<AnimalWeightHistorySection> createState() =>
      _AnimalWeightHistorySectionState();
}

class _AnimalWeightHistorySectionState
    extends ConsumerState<AnimalWeightHistorySection> {
  final List<AnimalWeight> _additional = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final canView = session?.can('animals.view_weight_history') ?? false;
    final history = canView
        ? ref.watch(animalWeightHistoryProvider(widget.animal.id))
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Weight history',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (!widget.animal.isArchived &&
                (session?.can('animals.record_weight') ?? false))
              FilledButton.icon(
                key: const Key('record_weight_action'),
                onPressed: () =>
                    context.push('/animals/${widget.animal.id}/weights/new'),
                icon: const Icon(Icons.monitor_weight_outlined),
                label: const Text('Record weight'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!canView)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Weight history is unavailable with your current permissions.',
              ),
            ),
          )
        else
          history!.when(
            loading: () => const SizedBox(
              height: 140,
              child: LoadingStateView(label: 'Loading weight history...'),
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
                  ref.invalidate(animalWeightHistoryProvider(widget.animal.id));
                },
              ),
            ),
            data: (result) => _history(context, result, session),
          ),
      ],
    );
  }

  Widget _history(
    BuildContext context,
    AnimalHistoryLoadResult<AnimalWeight> result,
    AuthSession? session,
  ) {
    final byId = <String, AnimalWeight>{
      for (final item in result.items) item.id: item,
      for (final item in _additional) item.id: item,
    };
    final items = byId.values.toList(growable: false);
    if (items.isEmpty) {
      return const SizedBox(
        height: 100,
        child: EmptyStateView(message: 'No weight history recorded.'),
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
                Text('Showing cached weight history'),
              ],
            ),
          ),
        if (width >= 760)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Observed')),
                DataColumn(label: Text('Entered')),
                DataColumn(label: Text('Normalized')),
                DataColumn(label: Text('Source')),
                DataColumn(label: Text('State')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                for (final weight in items)
                  DataRow(
                    cells: [
                      DataCell(Text(_date(weight.observedAt))),
                      DataCell(
                        Text('${weight.enteredValue} ${weight.enteredUnit}'),
                      ),
                      DataCell(Text('${weight.normalizedKg} kg')),
                      DataCell(Text(_label(weight.source))),
                      DataCell(_stateChip(weight)),
                      DataCell(_action(context, weight, session)),
                    ],
                  ),
              ],
            ),
          )
        else
          for (final weight in items)
            Card(
              key: Key('weight_${weight.id}'),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${weight.enteredValue} ${weight.enteredUnit}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        _stateChip(weight),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${weight.normalizedKg} kg normalized · ${_date(weight.observedAt)}',
                    ),
                    Text(
                      '${_label(weight.source)} · ${weight.farmName.isEmpty ? 'Recorded farm' : weight.farmName}',
                    ),
                    if (weight.correctionReason != null)
                      Text('Correction: ${weight.correctionReason}'),
                    if (weight.notes != null) Text(weight.notes!),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _action(context, weight, session),
                    ),
                  ],
                ),
              ),
            ),
        if (!result.isCached &&
            _page < (_page == 1 ? result.lastPage : _lastPage))
          Align(
            alignment: Alignment.center,
            child: OutlinedButton.icon(
              key: const Key('load_more_weights'),
              onPressed: _loadingMore ? null : _loadMore,
              icon: _loadingMore
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more),
              label: const Text('Load more weights'),
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
          .getWeights(
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

  Widget _stateChip(AnimalWeight weight) {
    if (weight.isSuperseded) {
      return const Chip(
        key: Key('weight_state_superseded'),
        avatar: Icon(Icons.history, size: 18),
        label: Text('Superseded'),
      );
    }
    if (weight.isCorrection) {
      return const Chip(
        key: Key('weight_state_correction'),
        avatar: Icon(Icons.fact_check_outlined, size: 18),
        label: Text('Correction'),
      );
    }
    return const Chip(
      key: Key('weight_state_current'),
      avatar: Icon(Icons.check_circle_outline, size: 18),
      label: Text('Recorded'),
    );
  }

  Widget _action(
    BuildContext context,
    AnimalWeight weight,
    AuthSession? session,
  ) {
    final canCorrect =
        !widget.animal.isArchived &&
        !weight.isSuperseded &&
        !weight.isCorrection &&
        (session?.can('animals.correct_weight') ?? false);
    if (!canCorrect) return const SizedBox.shrink();
    return TextButton.icon(
      key: Key('correct_weight_${weight.id}'),
      onPressed: () => context.push(
        '/animals/${widget.animal.id}/weights/${weight.id}/correct',
      ),
      icon: const Icon(Icons.edit_note_outlined),
      label: const Text('Correct'),
    );
  }

  static String _date(DateTime value) =>
      DateFormat.yMMMd().add_jm().format(value.toLocal());

  static String _label(String value) => value
      .split('_')
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

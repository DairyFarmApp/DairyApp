import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_movement_providers.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_movement_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_movement_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class AnimalMovementHistorySection extends ConsumerStatefulWidget {
  const AnimalMovementHistorySection({super.key, required this.animal});

  final Animal animal;

  @override
  ConsumerState<AnimalMovementHistorySection> createState() =>
      _AnimalMovementHistorySectionState();
}

class _AnimalMovementHistorySectionState
    extends ConsumerState<AnimalMovementHistorySection> {
  String? _mutatingId;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final canView = session?.can('animal_movements.view') ?? false;
    final history = canView
        ? ref.watch(animalMovementHistoryProvider(widget.animal.id))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Movement history',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (!widget.animal.isArchived &&
                (session?.can('animals.move') ?? false))
              FilledButton.icon(
                key: const Key('request_movement_action'),
                onPressed: () =>
                    context.push('/animals/${widget.animal.id}/movements/new'),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Request movement'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!canView)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Movement history is unavailable with your current permissions.',
              ),
            ),
          )
        else
          history!.when(
            loading: () => const SizedBox(
              height: 140,
              child: LoadingStateView(label: 'Loading movement history...'),
            ),
            error: (error, _) => SizedBox(
              height: 160,
              child: ErrorStateView(
                message: error.toString(),
                onRetry: () => ref.invalidate(
                  animalMovementHistoryProvider(widget.animal.id),
                ),
              ),
            ),
            data: (result) => _history(context, result),
          ),
      ],
    );
  }

  Widget _history(BuildContext context, AnimalMovementLoadResult result) {
    final items = result.items;
    final isCached = result.isCached;
    if (items.isEmpty) {
      return const SizedBox(
        height: 100,
        child: EmptyStateView(message: 'No movement history recorded.'),
      );
    }
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isCached)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.offline_bolt_outlined, size: 18),
                SizedBox(width: 6),
                Text('Showing cached movement history'),
              ],
            ),
          ),
        if (width >= 760)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Requested')),
                DataColumn(label: Text('From')),
                DataColumn(label: Text('To')),
                DataColumn(label: Text('Reason')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                for (final movement in items)
                  DataRow(
                    cells: [
                      DataCell(_statusBadge(movement)),
                      DataCell(Text(_date(movement.requestedEffectiveAt))),
                      DataCell(Text(_source(movement))),
                      DataCell(Text(_destination(movement))),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Text(movement.reason),
                        ),
                      ),
                      DataCell(_actions(movement)),
                    ],
                  ),
              ],
            ),
          )
        else
          for (final movement in items)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _statusBadge(movement),
                        const Spacer(),
                        Text(_date(movement.requestedEffectiveAt)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('${_source(movement)} → ${_destination(movement)}'),
                    const SizedBox(height: 6),
                    Text(
                      movement.reason,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (_decisionReason(movement) case final reason?)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(reason),
                      ),
                    if (movement.isPending) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _actions(movement),
                      ),
                    ],
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _statusBadge(AnimalMovement movement) {
    final (color, icon) = switch (movement.status) {
      'approved' => (Colors.green, Icons.check_circle_outline),
      'rejected' => (Colors.red, Icons.cancel_outlined),
      'cancelled' => (Colors.grey, Icons.block_outlined),
      _ => (Colors.orange, Icons.schedule_outlined),
    };
    return Chip(
      key: Key('movement_status_${movement.status}'),
      avatar: Icon(icon, color: color, size: 18),
      label: Text(_label(movement.status)),
      side: BorderSide(color: color),
    );
  }

  Widget _actions(AnimalMovement movement) {
    if (!movement.isPending) return const SizedBox.shrink();
    final session = ref.watch(authControllerProvider).asData?.value;
    final busy = _mutatingId == movement.id;
    final canApprove =
        (session?.can('animal_movements.approve') ?? false) &&
        (!movement.approvalRequired ||
            movement.requestedBy != session?.user.id);
    final canReject = session?.can('animal_movements.reject') ?? false;
    final canCancel = session?.can('animal_movements.cancel') ?? false;
    return Wrap(
      spacing: 4,
      children: [
        if (canApprove)
          IconButton(
            key: Key('approve_movement_${movement.id}'),
            tooltip: 'Approve',
            onPressed: busy ? null : () => _approve(movement),
            icon: const Icon(Icons.check_circle_outline),
          ),
        if (canReject)
          IconButton(
            key: Key('reject_movement_${movement.id}'),
            tooltip: 'Reject',
            onPressed: busy ? null : () => _reasonDecision(movement, 'reject'),
            icon: const Icon(Icons.cancel_outlined),
          ),
        if (canCancel)
          IconButton(
            key: Key('cancel_movement_${movement.id}'),
            tooltip: 'Cancel',
            onPressed: busy ? null : () => _reasonDecision(movement, 'cancel'),
            icon: const Icon(Icons.block_outlined),
          ),
      ],
    );
  }

  Future<void> _approve(AnimalMovement movement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve movement?'),
        content: const Text(
          'Approval immediately updates the animal’s current location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _mutate(
        movement,
        () => ref.read(animalMovementRepositoryProvider).approve(movement),
      );
    }
  }

  Future<void> _reasonDecision(AnimalMovement movement, String action) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_label(action)} movement'),
        content: TextField(
          key: Key('${action}_movement_reason'),
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: Text(_label(action)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null) return;
    await _mutate(movement, () {
      final repository = ref.read(animalMovementRepositoryProvider);
      return action == 'reject'
          ? repository.reject(movement, reason)
          : repository.cancel(movement, reason);
    });
  }

  Future<void> _mutate(
    AnimalMovement movement,
    Future<AnimalMovement> Function() operation,
  ) async {
    setState(() => _mutatingId = movement.id);
    try {
      await operation();
      ref.invalidate(animalMovementHistoryProvider(widget.animal.id));
      ref.invalidate(animalDetailProvider(widget.animal.id));
      ref.invalidate(animalListControllerProvider);
    } on AppException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _mutatingId = null);
    }
  }

  String _source(AnimalMovement movement) =>
      '${movement.sourceFarmName} / ${movement.sourceShedName}'
      '${movement.sourceAnimalGroupName == null ? '' : ' / ${movement.sourceAnimalGroupName}'}';

  String _destination(AnimalMovement movement) =>
      '${movement.destinationFarmName} / ${movement.destinationShedName}'
      '${movement.destinationAnimalGroupName == null ? '' : ' / ${movement.destinationAnimalGroupName}'}';

  String? _decisionReason(AnimalMovement movement) {
    if (movement.rejectionReason != null) {
      return 'Rejection: ${movement.rejectionReason}';
    }
    if (movement.cancellationReason != null) {
      return 'Cancellation: ${movement.cancellationReason}';
    }
    return null;
  }

  String _date(DateTime value) =>
      DateFormat.yMMMd().add_jm().format(value.toLocal());

  String _label(String value) => value
      .split('_')
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

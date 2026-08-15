import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_measurement_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AnimalFeedHistorySection extends ConsumerWidget {
  const AnimalFeedHistorySection({
    super.key,
    required this.animalId,
    this.canRecord = true,
  });

  final String animalId;
  final bool canRecord;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final canView = session?.can('inventory.view') ?? false;
    final canManage = session?.can('inventory.manage') ?? false;

    if (!canView) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Feed history is unavailable with your current permissions.',
          ),
        ),
      );
    }

    final history = ref.watch(animalFeedHistoryProvider(animalId));
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Feed History',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (canManage && canRecord)
                  FilledButton.icon(
                    key: const Key('record_feed_action_button'),
                    onPressed: () =>
                        context.push('/animals/$animalId/record-feed'),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Record Feed'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          history.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: ErrorStateView(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(animalFeedHistoryProvider(animalId)),
              ),
            ),
            data: (result) {
              final items = result.items;
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: EmptyStateView(message: 'No feed history recorded.'),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length > 5 ? 5 : items.length, // Show up to 5
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: const Icon(Icons.grass_outlined),
                    title: Text(
                      '${item.quantity} ${item.unit} ${item.inventoryItemName ?? 'Item'}',
                    ),
                    subtitle: Text(
                      '${DateFormat.yMMMd().format(item.date)} - ${item.session}\n${item.recordedByName ?? 'User'}',
                    ),
                    isThreeLine: true,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

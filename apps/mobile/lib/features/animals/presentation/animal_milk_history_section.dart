import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_measurement_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AnimalMilkHistorySection extends ConsumerWidget {
  const AnimalMilkHistorySection({
    super.key,
    required this.animalId,
    this.canRecord = true,
  });

  final String animalId;
  final bool canRecord;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final canView = session?.can('milk.view') ?? false;
    final canCreate = session?.can('milk.create') ?? false;

    if (!canView) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Milk history is unavailable with your current permissions.',
          ),
        ),
      );
    }

    final history = ref.watch(animalMilkHistoryProvider(animalId));
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
                    'Milk History',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (canCreate && canRecord)
                  FilledButton.icon(
                    key: const Key('record_milk_action_button'),
                    onPressed: () =>
                        context.push('/animals/$animalId/record-milk'),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Record Milk'),
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
                    ref.invalidate(animalMilkHistoryProvider(animalId)),
              ),
            ),
            data: (result) {
              final items = result.items;
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: EmptyStateView(message: 'No milk history recorded.'),
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
                    leading: const Icon(Icons.water_drop_outlined),
                    title: Text('${item.quantityLitres} L'),
                    subtitle: Text(
                      '${DateFormat.yMMMd().format(item.productionDate)} - ${item.session.label}\n${item.recordedByName ?? 'User'}',
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

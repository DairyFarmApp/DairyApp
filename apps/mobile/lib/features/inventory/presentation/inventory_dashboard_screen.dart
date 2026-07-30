import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/inventory/application/inventory_providers.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class InventoryDashboardScreen extends ConsumerWidget {
  const InventoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(inventoryDashboardProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(
                eyebrow: 'Stock control',
                title: 'Manage inventory',
                subtitle:
                    'Choose an inventory area to review stock, value, batches, expiry warnings, and new receipts.',
              ),
              const SizedBox(height: 24),
              dashboard.when(
                loading: () =>
                    const LoadingStateView(label: 'Loading inventory…'),
                error: (error, _) => ErrorStateView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(inventoryDashboardProvider),
                ),
                data: (summaries) => LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth >= 1040
                        ? (constraints.maxWidth - 32) / 3
                        : constraints.maxWidth >= 620
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final kind in InventoryKind.values)
                          SizedBox(
                            width: width,
                            child: _InventoryChoiceCard(
                              kind: kind,
                              summary: summaries[kind]!,
                              onTap: () =>
                                  context.go('/inventory/${kind.apiValue}'),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _InventoryChoiceCard extends StatelessWidget {
  const _InventoryChoiceCard({
    required this.kind,
    required this.summary,
    required this.onTap,
  });

  final InventoryKind kind;
  final InventorySummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color, description) = switch (kind) {
      InventoryKind.medicine => (
        Icons.medication_liquid_rounded,
        const Color(0xFF7C5CFC),
        'Medicines, vaccines, batches, and expiry control',
      ),
      InventoryKind.semen => (
        Icons.science_rounded,
        const Color(0xFF2D9CDB),
        'Semen straws, suppliers, batches, and availability',
      ),
      InventoryKind.feed => (
        Icons.grass_rounded,
        const Color(0xFF2BAE74),
        'Feed stock, categories, suppliers, and reorder levels',
      ),
    };
    return GlassSurface(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.64)],
                      ),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                '${kind.label} inventory',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatChip('${summary.itemCount} items', Icons.inventory_2),
                  _StatChip(
                    '${summary.lowStockItems} low',
                    Icons.warning_amber_rounded,
                  ),
                  _StatChip(
                    '${summary.expiredBatches} expired',
                    Icons.event_busy_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.icon);

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 17),
    label: Text(label),
    backgroundColor: Theme.of(
      context,
    ).colorScheme.surface.withValues(alpha: 0.36),
  );
}

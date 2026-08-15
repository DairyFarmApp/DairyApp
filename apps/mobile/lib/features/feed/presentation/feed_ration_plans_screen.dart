import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/feed/application/feed_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class FeedRationPlansScreen extends ConsumerWidget {
  const FeedRationPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(feedRationPlansProvider);
    final dateFmt = DateFormat.yMMMd();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/feed/plans/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Plan'),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
            sliver: SliverToBoxAdapter(
              child: ResponsiveContent(
                child: PageHeader(
                  eyebrow: 'Feed Management',
                  title: 'Ration Plans',
                  subtitle:
                      'Manage feeding regimes for different animal groups and production stages.',
                ),
              ),
            ),
          ),
          plans.when(
            loading: () => const SliverFillRemaining(
              child: LoadingStateView(label: 'Loading plans...'),
            ),
            error: (error, _) => SliverFillRemaining(
              child: ErrorStateView(
                message: error.toString(),
                onRetry: () => ref.invalidate(feedRationPlansProvider),
              ),
            ),
            data: (data) {
              if (data.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyStateView(
                    icon: Icons.assignment_rounded,
                    title: 'No ration plans yet',
                    message:
                        'Create a ration plan to standardize feeding across your farm.',
                    action: FilledButton(
                      onPressed: () => context.push('/feed/plans/new'),
                      child: const Text('Create Plan'),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final plan = data[index];
                    return ResponsiveContent(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassSurface(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              plan.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Effective: ${dateFmt.format(plan.effectiveDate)} • ${plan.feedingFrequency}x daily\nIngredients: ${plan.ingredients.length}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              // For now, just show a dialog or navigate.
                            },
                          ),
                        ),
                      ),
                    );
                  }, childCount: data.length),
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/feed/application/feed_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class DailyFeedIssuesScreen extends ConsumerWidget {
  const DailyFeedIssuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issues = ref.watch(dailyFeedIssuesProvider);
    final dateFmt = DateFormat.yMMMd();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/feed/issues/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Record Feed'),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
            sliver: SliverToBoxAdapter(
              child: ResponsiveContent(
                child: PageHeader(
                  eyebrow: 'Feed Management',
                  title: 'Daily Consumption',
                  subtitle:
                      'Track daily feed distribution, consumption, and waste.',
                ),
              ),
            ),
          ),
          issues.when(
            loading: () => const SliverFillRemaining(
              child: LoadingStateView(label: 'Loading records...'),
            ),
            error: (error, _) => SliverFillRemaining(
              child: ErrorStateView(
                message: error.toString(),
                onRetry: () => ref.invalidate(dailyFeedIssuesProvider),
              ),
            ),
            data: (data) {
              if (data.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyStateView(
                    icon: Icons.scale_rounded,
                    title: 'No feed recorded yet',
                    message:
                        'Record your daily feed distribution to track consumption.',
                    action: FilledButton(
                      onPressed: () => context.push('/feed/issues/new'),
                      child: const Text('Record Feed'),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final issue = data[index];
                    return ResponsiveContent(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassSurface(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              '${issue.issuedQuantity} issued • ${dateFmt.format(issue.date)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Consumed: ${issue.consumedQuantity} • Wasted: ${issue.wastedQuantity}\nStock deducted: ${issue.inventoryNetQuantity} • ${issue.inventoryPosted ? 'Posted' : 'Not posted'}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {},
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

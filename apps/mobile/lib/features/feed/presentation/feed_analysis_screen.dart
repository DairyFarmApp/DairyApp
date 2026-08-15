import 'package:dairycare_mobile/core/formatting/pkr.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedAnalysisProvider = FutureProvider<Map<String, dynamic>>(
  (ref) async =>
      (await ref.watch(apiClientProvider).getJson('/feed-analysis'))['data']
          as Map<String, dynamic>,
);

final class FeedAnalysisScreen extends ConsumerWidget {
  const FeedAnalysisScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef r) {
    final a = r.watch(feedAnalysisProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Feed analysis / Khurak tajzia')),
      body: a.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (d) {
          final n = d['ration_nutrition_per_animal'] as Map<String, dynamic>;
          return RefreshIndicator(
            onRefresh: () async => r.refresh(feedAnalysisProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Values are estimates based on recorded feed issues, current weighted batch cost, ration plans and milk records. / Yeh andazay recorded data par mabni hain.',
                    ),
                  ),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _card(c, 'Planned / Mansuba', d['planned_quantity']),
                    _card(c, 'Consumed / Istemal', d['consumed_quantity']),
                    _card(c, 'Wasted / Zaya', '${d['wastage_percent']}%'),
                    _card(
                      c,
                      'Estimated cost',
                      formatPkr(d['estimated_feed_cost_pkr'].toString()),
                    ),
                    _card(
                      c,
                      'Cost per litre',
                      d['feed_cost_per_litre_pkr'] == null
                          ? '-'
                          : formatPkr(d['feed_cost_per_litre_pkr'].toString()),
                    ),
                    _card(
                      c,
                      'Feed kg per litre',
                      d['feed_kg_per_litre'] ?? '-',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Ration nutrition per animal / Har janwar ki ghizayat',
                  style: Theme.of(c).textTheme.titleLarge,
                ),
                ListTile(
                  title: const Text('Dry matter'),
                  trailing: Text('${n['dry_matter_kg']} kg'),
                ),
                ListTile(
                  title: const Text('Crude protein'),
                  trailing: Text('${n['crude_protein_kg']} kg'),
                ),
                ListTile(
                  title: const Text('Energy'),
                  trailing: Text('${n['energy_mj']} MJ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _card(BuildContext c, String label, Object value) => SizedBox(
    width: 210,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            Text('$value', style: Theme.of(c).textTheme.headlineSmall),
          ],
        ),
      ),
    ),
  );
}

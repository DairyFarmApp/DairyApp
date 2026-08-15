import 'package:dairycare_mobile/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final calfCareProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, id) async =>
      (await ref
              .watch(apiClientProvider)
              .getJson('/animals/$id/calf-care'))['data']
          as Map<String, dynamic>?,
);

final class CalfCareSection extends ConsumerWidget {
  const CalfCareSection({
    super.key,
    required this.animalId,
    required this.canManage,
  });
  final String animalId;
  final bool canManage;
  @override
  Widget build(BuildContext c, WidgetRef r) {
    final p = r.watch(calfCareProvider(animalId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Calf care / Bachray ki dekh bhaal',
                    style: Theme.of(c).textTheme.titleLarge,
                  ),
                ),
                if (canManage)
                  TextButton.icon(
                    onPressed: () => c.push('/animals/$animalId/calf-care'),
                    icon: const Icon(Icons.edit),
                    label: const Text('Record'),
                  ),
              ],
            ),
            p.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
              data: (d) => d == null
                  ? const Text('No calf-care profile / Koi care record nahi')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text(
                            'Colostrum: ${d['colostrum_compliant'] ? 'on time / waqt par' : 'needs attention'}',
                          ),
                        ),
                        Chip(label: Text('Weaning: ${d['weaning_status']}')),
                        Chip(label: Text('Growth: ${d['growth_status']}')),
                        Chip(
                          label: Text(
                            'Current weight: ${d['current_weight_kg'] ?? '-'} kg',
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

final class CalfCareFormScreen extends ConsumerStatefulWidget {
  const CalfCareFormScreen({super.key, required this.animalId});
  final String animalId;
  @override
  ConsumerState<CalfCareFormScreen> createState() => _S();
}

final class _S extends ConsumerState<CalfCareFormScreen> {
  final birth = TextEditingController(),
      weight = TextEditingController(),
      colostrum = TextEditingController(),
      weaning = TextEditingController(),
      gain = TextEditingController(text: '0.7'),
      feed = TextEditingController(),
      navel = TextEditingController();
  bool saving = false;
  @override
  void dispose() {
    for (final c in [birth, weight, colostrum, weaning, gain, feed, navel]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Calf care / Bachray ki care')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _f(birth, 'Birth date/time ISO'),
        _f(weight, 'Birth weight kg'),
        _f(colostrum, 'Colostrum litres / Pehla doodh'),
        _f(navel, 'Navel product / Naaf ki dawa'),
        _f(weaning, 'Weaning target YYYY-MM-DD'),
        _f(gain, 'Target daily gain kg'),
        _f(feed, 'Feed plan / Khurak plan'),
        FilledButton(
          onPressed: saving ? null : _save,
          child: const Text('Save / Mehfooz karein'),
        ),
      ],
    ),
  );
  Widget _f(TextEditingController x, String l) => TextField(
    controller: x,
    decoration: InputDecoration(labelText: l),
  );
  Future<void> _save() async {
    setState(() => saving = true);
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await ref
          .read(apiClientProvider)
          .postJson(
            '/animals/${widget.animalId}/calf-care',
            data: {
              'birth_at': birth.text,
              'birth_weight_kg': weight.text,
              'birth_condition': 'active',
              'colostrum_given': colostrum.text.isNotEmpty,
              'colostrum_at': colostrum.text.isEmpty ? null : now,
              'colostrum_quantity_litres': colostrum.text.isEmpty
                  ? null
                  : colostrum.text,
              'navel_treated': navel.text.isNotEmpty,
              'navel_treated_at': navel.text.isEmpty ? null : now,
              'navel_product': navel.text.isEmpty ? null : navel.text,
              'weaning_target_date': weaning.text,
              'feed_plan': feed.text,
              'target_daily_gain_kg': gain.text,
              'health_status': 'normal',
            },
            idempotencyKey: DateTime.now().microsecondsSinceEpoch.toString(),
          );
      ref.invalidate(calfCareProvider(widget.animalId));
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}

import 'package:dairycare_mobile/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final breedingHistoryProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
      (ref, id) async =>
          (await ref
                  .watch(apiClientProvider)
                  .getJson('/animals/$id/breeding'))['data']
              as Map<String, dynamic>,
    );

final class BreedingSection extends ConsumerWidget {
  const BreedingSection({
    super.key,
    required this.animalId,
    required this.canManage,
  });
  final String animalId;
  final bool canManage;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(breedingHistoryProvider(animalId));
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
                    'Breeding / Nasal barhana',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (canManage)
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        context.push('/animals/$animalId/breeding'),
                    icon: const Icon(Icons.add),
                    label: const Text('Record'),
                  ),
              ],
            ),
            data.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
              data: (d) {
                final heat = (d['heat'] as List).length,
                    services = (d['services'] as List).length,
                    checks = (d['pregnancy_checks'] as List),
                    calvings = (d['calvings'] as List).length;
                return Text(
                  'Heat records: $heat · Services: $services · Pregnancy checks: ${checks.length} · Calvings: $calvings\n${checks.isEmpty ? 'No pregnancy status / Koi pregnancy record nahi' : 'Latest result: ${checks.first['result']} · Expected calving: ${checks.first['expected_calving_date'] ?? '-'}'}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final class BreedingEventScreen extends ConsumerStatefulWidget {
  const BreedingEventScreen({super.key, required this.animalId});
  final String animalId;
  @override
  ConsumerState<BreedingEventScreen> createState() => _State();
}

final class _State extends ConsumerState<BreedingEventScreen> {
  String event = 'heat';
  final a = TextEditingController(),
      b = TextEditingController(),
      c = TextEditingController(),
      d = TextEditingController();
  bool saving = false;
  @override
  void dispose() {
    a.dispose();
    b.dispose();
    c.dispose();
    d.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Breeding record / Nasal record')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField(
          initialValue: event,
          items: const [
            DropdownMenuItem(value: 'heat', child: Text('Heat / Garmi')),
            DropdownMenuItem(
              value: 'service',
              child: Text('Insemination / Breeding'),
            ),
            DropdownMenuItem(
              value: 'pregnancy-check',
              child: Text('Pregnancy check'),
            ),
          ],
          onChanged: (v) => setState(() => event = v ?? event),
        ),
        TextField(
          controller: a,
          decoration: InputDecoration(
            labelText: event == 'heat'
                ? 'Symptoms, comma separated'
                : 'Related record ID',
          ),
        ),
        TextField(
          controller: b,
          decoration: const InputDecoration(labelText: 'Method / Tareeqa'),
        ),
        TextField(
          controller: c,
          decoration: const InputDecoration(
            labelText: 'Person, technician or veterinarian',
          ),
        ),
        TextField(
          controller: d,
          decoration: const InputDecoration(
            labelText: 'Result, intensity, or semen item ID',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: saving ? null : _save,
          child: const Text('Save / Mehfooz karein'),
        ),
      ],
    ),
  );
  Future<void> _save() async {
    setState(() => saving = true);
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = event == 'heat'
        ? {
            'detected_at': now,
            'symptoms': a.text.split(','),
            'detection_method': b.text,
            'detected_by_name': c.text,
            'intensity': d.text,
            'recommended_action': 'Veterinary/farm review',
          }
        : event == 'pregnancy-check'
        ? {
            'breeding_service_id': a.text,
            'checked_on': now.substring(0, 10),
            'method': b.text,
            'veterinarian_name': c.text,
            'result': d.text,
          }
        : {
            'bred_at': now,
            'method': b.text,
            'semen_item_id': d.text,
            'semen_straw_number': a.text,
            'technician_name': c.text,
            'cost_pkr': 0,
          };
    try {
      await ref
          .read(apiClientProvider)
          .postJson(
            '/animals/${widget.animalId}/breeding/$event',
            data: payload,
            idempotencyKey: DateTime.now().microsecondsSinceEpoch.toString(),
          );
      ref.invalidate(breedingHistoryProvider(widget.animalId));
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}

import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/feed/application/feed_providers.dart';
import 'package:dairycare_mobile/features/feed/data/feed_repository.dart';
import 'package:dairycare_mobile/features/inventory/application/inventory_providers.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class DailyFeedIssueFormScreen extends ConsumerStatefulWidget {
  const DailyFeedIssueFormScreen({super.key});
  @override
  ConsumerState<DailyFeedIssueFormScreen> createState() => _State();
}

final class _State extends ConsumerState<DailyFeedIssueFormScreen> {
  final key = GlobalKey<FormState>();
  final planned = TextEditingController(),
      issued = TextEditingController(),
      consumed = TextEditingController(),
      wasted = TextEditingController(text: '0'),
      returned = TextEditingController(text: '0'),
      notes = TextEditingController();
  String? item;
  bool saving = false;
  @override
  void dispose() {
    for (final c in [planned, issued, consumed, wasted, returned, notes]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stock = ref.watch(
      inventoryOverviewProvider((
        kind: InventoryKind.feed,
        search: '',
        category: null,
        supplier: null,
        lowStock: false,
      )),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Daily feed / Rozana khurak')),
      body: stock.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) => Form(
          key: key,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Issued feed is deducted from inventory. Returned feed is added back. Issued must equal consumed + wasted + returned. / Jari khurak stock se kam aur wapas khurak stock mein jama hogi.',
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: item,
                decoration: const InputDecoration(
                  labelText: 'Feed item / Khurak',
                ),
                items: [
                  for (final i in s.items)
                    DropdownMenuItem(
                      value: i.id,
                      child: Text('${i.name} · ${i.currentStock} ${i.unit}'),
                    ),
                ],
                onChanged: (v) => setState(() => item = v),
                validator: _req,
              ),
              _f(planned, 'Planned / Mansuba'),
              _f(issued, 'Issued / Jari'),
              _f(consumed, 'Consumed / Istemal'),
              _f(wasted, 'Wasted / Zaya'),
              _f(returned, 'Returned / Wapas'),
              TextField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: saving ? null : _save,
                child: const Text('Save and update stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _f(TextEditingController c, String l) => TextFormField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: l),
    validator: _req,
  );
  String? _req(String? v) =>
      v == null || v.trim().isEmpty ? 'Required / Zaroori' : null;
  Future<void> _save() async {
    if (!(key.currentState?.validate() ?? false)) return;
    final total =
        double.parse(consumed.text) +
        double.parse(wasted.text) +
        double.parse(returned.text);
    if ((double.parse(issued.text) - total).abs() > .0005) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issued must equal consumed + wasted + returned.'),
        ),
      );
      return;
    }
    setState(() => saving = true);
    try {
      await FeedRepository(
        api: ref.read(apiClientProvider),
      ).createDailyFeedIssue({
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'inventory_item_id': item,
        'planned_quantity': planned.text,
        'issued_quantity': issued.text,
        'consumed_quantity': consumed.text,
        'wasted_quantity': wasted.text,
        'returned_quantity': returned.text,
        'notes': notes.text.trim().isEmpty ? null : notes.text.trim(),
      });
      ref.invalidate(dailyFeedIssuesProvider);
      ref.invalidate(inventoryOverviewProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}

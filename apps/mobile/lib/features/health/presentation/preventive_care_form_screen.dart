import 'package:dairycare_mobile/features/health/application/health_providers.dart';
import 'package:dairycare_mobile/features/inventory/application/inventory_providers.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class PreventiveCareFormScreen extends ConsumerStatefulWidget {
  const PreventiveCareFormScreen({super.key, required this.animalId});
  final String animalId;
  @override
  ConsumerState<PreventiveCareFormScreen> createState() => _State();
}

final class _State extends ConsumerState<PreventiveCareFormScreen> {
  final key = GlobalKey<FormState>();
  final disease = TextEditingController(),
      dose = TextEditingController(),
      unit = TextEditingController(text: 'ml'),
      used = TextEditingController(),
      next = TextEditingController(),
      vet = TextEditingController(),
      by = TextEditingController(),
      cost = TextEditingController(text: '0'),
      reaction = TextEditingController(),
      notes = TextEditingController();
  String type = 'vaccination';
  String? item;
  bool saving = false;
  @override
  void dispose() {
    for (final c in [
      disease,
      dose,
      unit,
      used,
      next,
      vet,
      by,
      cost,
      reaction,
      notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stock = ref.watch(
      inventoryOverviewProvider((
        kind: InventoryKind.medicine,
        search: '',
        category: null,
        supplier: null,
        lowStock: false,
      )),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Preventive care / Bachao ki dawa')),
      body: stock.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) => Form(
          key: key,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Type / Qisam'),
                items: const [
                  DropdownMenuItem(
                    value: 'vaccination',
                    child: Text('Vaccination / Vaccine'),
                  ),
                  DropdownMenuItem(
                    value: 'deworming',
                    child: Text('Deworming / Keeron ki dawa'),
                  ),
                ],
                onChanged: (v) => setState(() => type = v ?? type),
              ),
              DropdownButtonFormField<String>(
                initialValue: item,
                decoration: const InputDecoration(
                  labelText: 'Inventory product / Stock ki dawa',
                ),
                items: [
                  for (final i in s.items.where(
                    (x) =>
                        type != 'vaccination' ||
                        x.category.toLowerCase() == 'vaccine',
                  ))
                    DropdownMenuItem(
                      value: i.id,
                      child: Text('${i.name} · ${i.currentStock} ${i.unit}'),
                    ),
                ],
                onChanged: (v) => setState(() => item = v),
                validator: _req,
              ),
              if (type == 'vaccination')
                _f(disease, 'Disease covered / Kis bimari se bachao'),
              _f(dose, 'Dose / Miqdar', number: true),
              _f(unit, 'Dose unit'),
              _f(used, 'Stock used / Stock se istemal', number: true),
              TextFormField(
                controller: next,
                decoration: const InputDecoration(
                  labelText: 'Next due date YYYY-MM-DD / Agli tareekh',
                ),
              ),
              if (type == 'vaccination') _f(vet, 'Veterinarian / Doctor'),
              _f(by, 'Administered by / Dawa dene wala'),
              _f(cost, 'Cost PKR / Kharcha', number: true),
              _f(reaction, 'Reaction (optional)', required: false),
              _f(notes, 'Notes (optional)', required: false),
              FilledButton.icon(
                onPressed: saving ? null : _save,
                icon: const Icon(Icons.save),
                label: const Text('Save / Mehfooz karein'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _f(
    TextEditingController c,
    String label, {
    bool number = false,
    bool required = true,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      decoration: InputDecoration(labelText: label),
      validator: required ? _req : null,
    ),
  );
  String? _req(String? v) =>
      v == null || v.trim().isEmpty ? 'Required / Zaroori' : null;
  Future<void> _save() async {
    if (!(key.currentState?.validate() ?? false)) return;
    setState(() => saving = true);
    try {
      await ref.read(healthRepositoryProvider).recordPreventiveCare({
        'animal_ids': [widget.animalId],
        'inventory_item_id': item,
        'type': type,
        'disease_covered': type == 'vaccination' ? disease.text.trim() : null,
        'dose': dose.text.trim(),
        'dose_unit': unit.text.trim(),
        'inventory_quantity_used_per_animal': used.text.trim(),
        'administered_at': DateTime.now().toUtc().toIso8601String(),
        'next_due_date': next.text.trim().isEmpty ? null : next.text.trim(),
        'veterinarian_name': type == 'vaccination' ? vet.text.trim() : null,
        'administered_by_name': by.text.trim(),
        'cost_pkr_per_animal': cost.text.trim(),
        'reaction': reaction.text.trim().isEmpty ? null : reaction.text.trim(),
        'notes': notes.text.trim().isEmpty ? null : notes.text.trim(),
      });
      ref.invalidate(animalPreventiveCareProvider(widget.animalId));
      ref.invalidate(inventoryOverviewProvider);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }
}

import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/features/health/application/health_providers.dart';
import 'package:dairycare_mobile/features/inventory/application/inventory_providers.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class TreatmentFormScreen extends ConsumerStatefulWidget {
  const TreatmentFormScreen({super.key, required this.animalId});
  final String animalId;
  @override
  ConsumerState<TreatmentFormScreen> createState() => _TreatmentFormState();
}

final class _TreatmentFormState extends ConsumerState<TreatmentFormScreen> {
  final formKey = GlobalKey<FormState>();
  final weight = TextEditingController();
  final dose = TextEditingController();
  final doseUnit = TextEditingController(text: 'ml');
  final frequency = TextEditingController();
  final duration = TextEditingController(text: '1');
  final stockUsed = TextEditingController();
  final vet = TextEditingController();
  final instructions = TextEditingController();
  String? caseId, medicineId;
  String route = 'intramuscular';
  bool saving = false;

  @override
  void dispose() {
    for (final value in [
      weight,
      dose,
      doseUnit,
      frequency,
      duration,
      stockUsed,
      vet,
      instructions,
    ]) {
      value.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cases = ref.watch(animalHealthCasesProvider(widget.animalId));
    final medicines = ref.watch(
      inventoryOverviewProvider((
        kind: InventoryKind.medicine,
        search: '',
        category: null,
        supplier: null,
        lowStock: false,
      )),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record treatment / Dawa record karein'),
      ),
      body: cases.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (healthCases) => medicines.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (stock) => Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Use only a veterinarian-approved dose copied from the medicine label or prescription. App khud dose nahi banati. Expired medicine istemal nahi hogi.',
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: caseId,
                  decoration: const InputDecoration(
                    labelText: 'Health case / Bimari case',
                  ),
                  items: [
                    for (final item in healthCases)
                      DropdownMenuItem(
                        value: item.id,
                        child: Text(
                          '${item.caseNumber} · ${item.differentials.isEmpty ? 'Needs vet review' : item.differentials.first.name}',
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => caseId = v),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: medicineId,
                  decoration: const InputDecoration(
                    labelText: 'Medicine / Dawa',
                  ),
                  items: [
                    for (final item in stock.items.where(
                      (i) => double.tryParse(i.currentStock) != 0,
                    ))
                      DropdownMenuItem(
                        value: item.id,
                        child: Text(
                          '${item.name} · ${item.concentration ?? 'strength missing'} · stock ${item.currentStock} ${item.unit}',
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => medicineId = v),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                _field(weight, 'Animal weight kg / Wazan', number: true),
                _field(dose, 'Dose from vet / Vet ki dose', number: true),
                _field(doseUnit, 'Dose unit (ml, mg, tablet)'),
                DropdownButtonFormField<String>(
                  initialValue: route,
                  decoration: const InputDecoration(
                    labelText: 'How given / Dawa ka tareeqa',
                  ),
                  items: [
                    for (final value in const [
                      'oral',
                      'intramuscular',
                      'subcutaneous',
                      'intravenous',
                      'intramammary',
                      'topical',
                      'other',
                    ])
                      DropdownMenuItem(value: value, child: Text(value)),
                  ],
                  onChanged: (v) => setState(() => route = v ?? route),
                ),
                _field(
                  frequency,
                  'Frequency / Kitni dafa (example: twice daily)',
                ),
                _field(duration, 'Duration days / Kitne din', number: true),
                _field(
                  stockUsed,
                  'Inventory quantity used / Stock se kitna istemal hua',
                  number: true,
                ),
                _field(vet, 'Veterinarian name / Doctor ka naam'),
                TextFormField(
                  controller: instructions,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Vet instructions / Doctor ki hidayat',
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: saving || healthCases.isEmpty ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save treatment / Dawa save karein'),
                ),
                if (healthCases.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'First record a symptom assessment / Pehle alamat ka case banayein.',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      decoration: InputDecoration(labelText: label),
      validator: _required,
    ),
  );
  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required / Zaroori' : null;

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => saving = true);
    try {
      await ref
          .read(healthRepositoryProvider)
          .recordTreatment(widget.animalId, {
            'health_case_id': caseId,
            'inventory_item_id': medicineId,
            'administered_at': DateTime.now().toUtc().toIso8601String(),
            'animal_weight_kg': weight.text.trim(),
            'dose': dose.text.trim(),
            'dose_unit': doseUnit.text.trim(),
            'route': route,
            'frequency': frequency.text.trim(),
            'duration_days': int.parse(duration.text),
            'inventory_quantity_used': stockUsed.text.trim(),
            'veterinarian_name': vet.text.trim(),
            'veterinarian_instructions': instructions.text.trim(),
          });
      ref.invalidate(animalHealthCasesProvider(widget.animalId));
      ref.invalidate(animalTreatmentsProvider(widget.animalId));
      ref.invalidate(inventoryOverviewProvider);
      if (mounted) {
        context.pop();
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }
}

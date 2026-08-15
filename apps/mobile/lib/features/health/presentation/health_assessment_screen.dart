import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/features/health/application/health_providers.dart';
import 'package:dairycare_mobile/features/health/domain/health_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class HealthAssessmentScreen extends ConsumerStatefulWidget {
  const HealthAssessmentScreen({super.key, required this.animalId});
  final String animalId;
  @override
  ConsumerState<HealthAssessmentScreen> createState() => _State();
}

final class _State extends ConsumerState<HealthAssessmentScreen> {
  final selected = <String>{};
  final temperature = TextEditingController();
  final notes = TextEditingController();
  String severity = 'moderate';
  bool saving = false;
  @override
  void dispose() {
    temperature.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symptoms = ref.watch(healthSymptomsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Health check / Sehat check')),
      body: symptoms.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => Form(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Choose the signs you can see. The app shows possible diseases only; it does not confirm disease or prescribe medicine. Emergency sign ho to foran vet ko bulayein.',
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: severity,
                decoration: const InputDecoration(
                  labelText: 'How serious? / Kitna serious?',
                ),
                items: const [
                  DropdownMenuItem(value: 'mild', child: Text('Mild')),
                  DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                  DropdownMenuItem(
                    value: 'severe',
                    child: Text('Severe / urgent'),
                  ),
                ],
                onChanged: (v) => setState(() => severity = v ?? 'moderate'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: temperature,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Temperature °C (optional)',
                ),
              ),
              const SizedBox(height: 16),
              for (final group in _groups(items).entries) ...[
                _title(group.key),
                for (final symptom in group.value)
                  CheckboxListTile(
                    value: selected.contains(symptom.id),
                    title: Text(
                      '${symptom.name} / ${symptom.nameRomanUrdu ?? _romanUrdu[symptom.code] ?? 'Yeh alamat'}',
                    ),
                    subtitle: symptom.isEmergency
                        ? const Text(
                            'Emergency warning / Foran doctor bulayein',
                            style: TextStyle(color: Colors.red),
                          )
                        : null,
                    onChanged: (v) => setState(
                      () => v == true
                          ? selected.add(symptom.id)
                          : selected.remove(symptom.id),
                    ),
                  ),
              ],
              TextField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes / Mazeed maloomat',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: saving ? null : _submit,
                icon: const Icon(Icons.rule_outlined),
                label: const Text(
                  'Check possible diseases / Mumkin bimari dekhein',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<HealthSymptom>> _groups(List<HealthSymptom> items) {
    final result = <String, List<HealthSymptom>>{};
    for (final item in items) {
      (result[item.bodySystem] ??= []).add(item);
    }
    return result;
  }

  Widget _title(String value) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(
      value.toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  );
  Future<void> _submit() async {
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one symptom.')),
      );
      return;
    }
    setState(() => saving = true);
    try {
      final result = await ref
          .read(healthRepositoryProvider)
          .assess(widget.animalId, {
            'severity': severity,
            'temperature_c': temperature.text.trim().isEmpty
                ? null
                : temperature.text.trim(),
            'symptom_ids': selected.toList(),
            'notes': notes.text.trim().isEmpty ? null : notes.text.trim(),
          });
      ref.invalidate(animalHealthCasesProvider(widget.animalId));
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              result.emergency ? 'Emergency assessment' : 'Assessment saved',
            ),
            content: Text(
              result.emergencyMessage ??
                  (result.differentials.isEmpty
                      ? 'No reliable match. Contact a veterinarian.'
                      : 'Top possible condition: ${result.differentials.first.name}. This is not a confirmed diagnosis.'),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
        if (mounted) {
          context.pop();
        }
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

const _romanUrdu = <String, String>{
  'fever': 'Bukhar',
  'low_temperature': 'Jism thanda',
  'loss_of_appetite': 'Bhook kam',
  'reduced_milk': 'Doodh kam',
  'diarrhea': 'Dast',
  'bloody_diarrhea': 'Khoon walay dast',
  'cough': 'Khansi',
  'nasal_discharge': 'Naak se pani',
  'difficulty_breathing': 'Saans mein mushkil',
  'lameness': 'Langrahat',
  'swollen_joint': 'Jor soojna',
  'udder_swelling': 'Than soojna',
  'abnormal_milk': 'Doodh mein tabdeeli',
  'bloat': 'Pait phoolna',
  'salivation': 'Munh se ral',
  'weakness': 'Kamzori',
  'dehydration': 'Pani ki kami',
  'neurological_signs': 'Asabi alamat',
};

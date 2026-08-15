import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/features/health/application/health_providers.dart';
import 'package:dairycare_mobile/features/health/domain/health_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final class HealthMedicineEvidenceScreen extends ConsumerWidget {
  const HealthMedicineEvidenceScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(healthMedicineEvidenceProvider);
    final canReview =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('health.medicine_evidence.review') ??
        false;
    return Scaffold(
      appBar: AppBar(title: const Text('Pakistan Medicine Evidence')),
      body: records.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Evidence could not load: $e'),
              FilledButton(
                onPressed: () => ref.invalidate(healthMedicineEvidenceProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(
                child: Text(
                  'No DRAP evidence has been entered and approved yet.',
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Card(
                    color: Color(0xFFFFE5E5),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'DRAP registration is regulatory evidence, not treatment advice. Product choice and dose must come from a veterinarian for the specific animal and current label.',
                      ),
                    ),
                  ),
                  for (final item in items)
                    Card(
                      child: ExpansionTile(
                        title: Text(
                          '${item.activeIngredient} · ${item.brandName}',
                        ),
                        subtitle: Text(
                          '${item.diseaseName} · ${item.reviewStatus} · v${item.reviewVersion}',
                        ),
                        childrenPadding: const EdgeInsets.all(16),
                        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _line('Manufacturer', item.manufacturer),
                          _line('Dosage form', item.dosageForm),
                          _line(
                            'DRAP registration',
                            item.drapRegistrationNumber,
                          ),
                          _line('Evidence indication', item.indication),
                          _line('Species scope', item.speciesScope),
                          _line('Contraindications', item.contraindications),
                          _line('Withdrawal guidance', item.withdrawalGuidance),
                          Text(
                            item.prescribingNotice,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                launchUrl(Uri.parse(item.drapRegistryUrl)),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open DRAP registry evidence'),
                          ),
                          if (canReview)
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: () => _review(context, ref, item),
                                icon: const Icon(Icons.fact_check),
                                label: const Text('Veterinary review'),
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

  static Widget _line(String title, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text('$title: $value'),
  );
  static Future<void> _review(
    BuildContext context,
    WidgetRef ref,
    HealthMedicineEvidence item,
  ) async {
    final form = GlobalKey<FormState>();
    final name = TextEditingController(),
        registration = TextEditingController(),
        notes = TextEditingController();
    var decision = 'approved';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Signed veterinary review'),
          content: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: decision,
                    items: const [
                      DropdownMenuItem(
                        value: 'approved',
                        child: Text('Approve'),
                      ),
                      DropdownMenuItem(
                        value: 'changes_requested',
                        child: Text('Request changes'),
                      ),
                      DropdownMenuItem(
                        value: 'rejected',
                        child: Text('Reject'),
                      ),
                    ],
                    onChanged: (v) => decision = v ?? decision,
                  ),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Veterinarian name',
                    ),
                    validator: _required,
                  ),
                  TextFormField(
                    controller: registration,
                    decoration: const InputDecoration(
                      labelText: 'PVMC/registration',
                    ),
                    validator: _required,
                  ),
                  TextFormField(
                    controller: notes,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Clinical review notes',
                    ),
                    validator: (v) => (v?.trim().length ?? 0) < 10
                        ? 'Enter at least 10 characters.'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!form.currentState!.validate()) return;
                await ref
                    .read(healthRepositoryProvider)
                    .reviewMedicineEvidence(item.id, {
                      'decision': decision,
                      'reviewer_name': name.text.trim(),
                      'reviewer_registration': registration.text.trim(),
                      'reviewer_notes': notes.text.trim(),
                    });
                ref.invalidate(healthMedicineEvidenceProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save signed review'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    registration.dispose();
    notes.dispose();
  }

  static String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Required' : null;
}

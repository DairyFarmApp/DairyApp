import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/features/health/application/health_providers.dart';
import 'package:dairycare_mobile/features/health/domain/health_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

final class HealthKnowledgeScreen extends ConsumerWidget {
  const HealthKnowledgeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(healthKnowledgeProvider);
    final canReview =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('health.knowledge.review') ??
        false;
    final canReviewAi =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('health.ai.review') ??
        false;
    final canManageMedicineEvidence =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('health.medicine_evidence.manage') ??
        false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Health Guide / Janwaron ki sehat'),
      ),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Guide could not load / Guide load nahi hui: $e'),
        ),
        data: (items) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.health_and_safety_outlined),
                title: const Text(
                  'Ask the health guide / Sehat guide se poochain',
                ),
                subtitle: const Text(
                  'Select signs and get simple guidance from approved veterinary sources.',
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => context.go('/health-guide/ask'),
              ),
            ),
            if (canReviewAi)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.fact_check_outlined),
                  title: const Text('AI veterinary review / AI vet tasdeeq'),
                  subtitle: const Text(
                    'Review bilingual benchmark cases and sign decisions.',
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => context.go('/health-guide/review'),
                ),
              ),
            if (canManageMedicineEvidence)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.medication_outlined),
                  title: const Text('Pakistan medicine evidence'),
                  subtitle: const Text(
                    'DRAP registration facts and veterinary approval; no dose advice.',
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => context.go('/health-guide/medicine-evidence'),
                ),
              ),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'This guide gives possible information and safe first steps. It is not a diagnosis or prescription. Emergency ho to janwar alag karein aur foran veterinarian ko bulayein. Antibiotic ya dose khud select na karein.',
                ),
              ),
            ),
            for (final item in items)
              Card(
                child: ExpansionTile(
                  leading: Icon(
                    item.urgency == 'emergency'
                        ? Icons.warning_amber_rounded
                        : Icons.medical_information_outlined,
                    color: item.urgency == 'emergency' ? Colors.red : null,
                  ),
                  title: Text(
                    '${item.name}${item.nameRomanUrdu == null ? '' : ' / ${item.nameRomanUrdu}'}',
                  ),
                  subtitle: Text(
                    '${item.species.join(', ')} · ${item.urgency} · ${item.reviewStatus} · v${item.version}',
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _section(
                      'What it means / Kya matlab hai',
                      item.summary,
                      item.summaryRomanUrdu,
                    ),
                    _section('Signs / Alamat', item.symptoms.join(', '), null),
                    _section(
                      'Do now / Abhi kya karein',
                      item.immediateCare,
                      item.immediateCareRomanUrdu,
                    ),
                    if (item.safeHomeCare != null)
                      _section(
                        'Safe support / Mehfooz dekh bhaal',
                        item.safeHomeCare!,
                        item.safeHomeCareRomanUrdu,
                      ),
                    _section(
                      'How vet confirms / Vet kaise check karega',
                      item.confirmationGuidance,
                      item.confirmationRomanUrdu,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => launchUrl(Uri.parse(item.sourceUrl)),
                        icon: const Icon(Icons.open_in_new),
                        label: Text('Source: ${item.sourceTitle}'),
                      ),
                    ),
                    if (canReview)
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => _review(context, ref, item),
                          icon: const Icon(Icons.fact_check_outlined),
                          label: const Text('Veterinary review / Vet tasdeeq'),
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

  Widget _section(String title, String english, String? roman) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(english),
        if (roman?.isNotEmpty ?? false)
          Text(roman!, style: const TextStyle(fontStyle: FontStyle.italic)),
      ],
    ),
  );

  Future<void> _review(
    BuildContext context,
    WidgetRef ref,
    HealthKnowledgeEntry item,
  ) async {
    final name = TextEditingController();
    final registration = TextEditingController();
    final notes = TextEditingController();
    var decision = 'approved';
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Veterinary review / Vet tasdeeq'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Only a qualified veterinary reviewer should approve clinical content.',
                ),
                DropdownButtonFormField<String>(
                  initialValue: decision,
                  items: const [
                    DropdownMenuItem(value: 'approved', child: Text('Approve')),
                    DropdownMenuItem(
                      value: 'changes_requested',
                      child: Text('Request changes'),
                    ),
                    DropdownMenuItem(value: 'rejected', child: Text('Reject')),
                  ],
                  onChanged: (v) => setState(() => decision = v ?? decision),
                ),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Veterinarian name',
                  ),
                ),
                TextField(
                  controller: registration,
                  decoration: const InputDecoration(
                    labelText: 'PVMC/registration number',
                  ),
                ),
                TextField(
                  controller: notes,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Review notes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if ([
                  name.text,
                  registration.text,
                  notes.text,
                ].any((v) => v.trim().isEmpty)) {
                  return;
                }
                await ref
                    .read(healthRepositoryProvider)
                    .reviewKnowledge(item.id, {
                      'decision': decision,
                      'reviewer_name': name.text.trim(),
                      'reviewer_registration': registration.text.trim(),
                      'reviewer_notes': notes.text.trim(),
                    });
                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('Save review'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    registration.dispose();
    notes.dispose();
    if (saved == true) ref.invalidate(healthKnowledgeProvider);
  }
}

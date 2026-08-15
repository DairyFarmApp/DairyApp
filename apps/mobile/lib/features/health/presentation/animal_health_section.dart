import 'package:dairycare_mobile/features/health/application/health_providers.dart';
import 'package:dairycare_mobile/features/health/domain/health_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class AnimalHealthSection extends ConsumerWidget {
  const AnimalHealthSection({
    super.key,
    required this.animalId,
    required this.canAssess,
    required this.canTreat,
  });
  final String animalId;
  final bool canAssess;
  final bool canTreat;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(animalHealthCasesProvider(animalId));
    final treatments = ref.watch(animalTreatmentsProvider(animalId));
    final preventive = ref.watch(animalPreventiveCareProvider(animalId));
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
                    'Health history',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (canAssess)
                  FilledButton.icon(
                    onPressed: () =>
                        context.push('/animals/$animalId/health-assessment'),
                    icon: const Icon(Icons.health_and_safety_outlined),
                    label: const Text('Check symptoms'),
                  ),
                if (canTreat) ...[
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        context.push('/animals/$animalId/treatments/new'),
                    icon: const Icon(Icons.medication_outlined),
                    label: const Text('Record treatment / Dawa'),
                  ),
                ],
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Vaccination & deworming / Vaccine aur keeron ki dawa',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (canTreat)
                  TextButton.icon(
                    onPressed: () =>
                        context.push('/animals/$animalId/preventive-care/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
              ],
            ),
            preventive.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
              data: (items) => items.isEmpty
                  ? const Text('No preventive record / Koi record nahi')
                  : Column(
                      children: [
                        for (final item in items)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              item.type == 'vaccination'
                                  ? Icons.vaccines
                                  : Icons.medication_liquid,
                            ),
                            title: Text(
                              '${item.type} · ${item.dose} ${item.doseUnit}',
                            ),
                            subtitle: Text(
                              '${DateFormat.yMMMd().format(item.administeredAt.toLocal())}${item.nextDueDate == null ? '' : ' · next ${DateFormat.yMMMd().format(item.nextDueDate!)} · ${item.dueStatus}'}',
                            ),
                          ),
                      ],
                    ),
            ),
            const Divider(height: 28),
            Text(
              'Treatment & withdrawal / Dawa aur pabandi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            treatments.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) =>
                  Text('Treatment history could not be loaded: $e'),
              data: (items) => items.isEmpty
                  ? const Text(
                      'No treatment recorded / Koi dawa record nahi hui.',
                    )
                  : Column(
                      children: [
                        for (final item in items)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.vaccines_outlined),
                            title: Text(
                              '${item.number} · ${item.dose} ${item.doseUnit} (${item.route})',
                            ),
                            subtitle: Text(
                              '${DateFormat.yMMMd().add_jm().format(item.administeredAt.toLocal())} · Vet: ${item.veterinarianName}\n${item.withdrawals.isEmpty ? 'No withdrawal / Koi pabandi nahi' : item.withdrawals.map((w) => '${w.type}: until ${DateFormat.yMMMd().add_jm().format(w.endsAt.toLocal())}').join(' · ')}',
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
            cases.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Health history could not be loaded: $e'),
              data: (items) => items.isEmpty
                  ? const Text('No health assessments recorded.')
                  : Column(
                      children: [
                        for (final item in items) _case(context, item),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _case(BuildContext context, AnimalHealthCase item) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      item.emergency
          ? Icons.warning_amber_rounded
          : Icons.medical_information_outlined,
      color: item.emergency ? Colors.red : null,
    ),
    title: Text(
      '${item.caseNumber} · ${item.differentials.isEmpty ? 'Needs veterinary assessment' : item.differentials.first.name}',
    ),
    subtitle: Text(
      '${DateFormat.yMMMd().add_jm().format(item.reportedAt.toLocal())} · ${item.severity}\n${item.emergencyMessage ?? 'Decision support only — not a confirmed diagnosis.'}',
    ),
    isThreeLine: true,
    onTap: () => showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.caseNumber),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.emergency)
                  Text(
                    item.emergencyMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                for (final result in item.differentials)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${result.rank}. ${result.name} — ${result.score.toStringAsFixed(0)}% match',
                    ),
                    subtitle: Text(
                      '${result.summary}\n\nImmediate care: ${result.immediateCare}\n\nConfirmation: ${result.confirmationGuidance}\nSource: ${result.sourceTitle}',
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    ),
  );
}

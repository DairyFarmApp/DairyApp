import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/features/health/application/health_providers.dart';
import 'package:dairycare_mobile/features/health/domain/health_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class HealthAiReviewScreen extends ConsumerWidget {
  const HealthAiReviewScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(healthAiEvaluationCasesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('AI Veterinary Review / Vet Tasdeeq')),
      body: cases.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cases could not load: $e'),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(healthAiEvaluationCasesProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No evaluation cases.'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Card(
                    color: Color(0xFFFFF8E1),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Only a qualified veterinarian should approve these cases. Check both languages, symptoms, expected match and emergency level.',
                      ),
                    ),
                  ),
                  for (final item in items)
                    Card(
                      child: ExpansionTile(
                        leading: Icon(
                          item.reviewStatus == 'approved'
                              ? Icons.verified
                              : Icons.pending_actions,
                          color: item.reviewStatus == 'approved'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        title: Text('${item.code} · ${item.species}'),
                        subtitle: Text(
                          '${item.reviewStatus} · review v${item.reviewVersion}',
                        ),
                        childrenPadding: const EdgeInsets.all(16),
                        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _line('English question', item.questionEn),
                          _line('Roman Urdu', item.questionRomanUrdu),
                          _line(
                            'Symptoms',
                            item.symptomCodes.isEmpty
                                ? 'None / unsupported-question check'
                                : item.symptomCodes.join(', '),
                          ),
                          _line(
                            'Expected result',
                            item.expectsMatch
                                ? item.expectedDiseaseCodes.join(', ')
                                : 'No approved match',
                          ),
                          _line(
                            'Emergency',
                            item.expectedEmergency ? 'Yes / Haan' : 'No / Nahi',
                          ),
                          if (item.reviewerName != null)
                            _line(
                              'Last reviewer',
                              '${item.reviewerName} · ${item.reviewerRegistration ?? ''}',
                            ),
                          _ReviewHistory(caseId: item.id),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: () => _review(context, ref, item),
                              icon: const Icon(Icons.fact_check),
                              label: const Text('Review / Tasdeeq'),
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
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    ),
  );
  static Future<void> _review(
    BuildContext context,
    WidgetRef ref,
    HealthAiEvaluationCase item,
  ) async {
    final form = GlobalKey<FormState>();
    final name = TextEditingController(text: item.reviewerName);
    final reg = TextEditingController(text: item.reviewerRegistration);
    final notes = TextEditingController();
    var decision = 'approved';
    var saving = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Review ${item.code}'),
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
                    controller: reg,
                    decoration: const InputDecoration(
                      labelText: 'PVMC/registration number',
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
              onPressed: saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      setState(() => saving = true);
                      try {
                        await ref
                            .read(healthRepositoryProvider)
                            .reviewEvaluationCase(item.id, {
                              'decision': decision,
                              'reviewer_name': name.text.trim(),
                              'reviewer_registration': reg.text.trim(),
                              'reviewer_notes': notes.text.trim(),
                            });
                        ref.invalidate(healthAiEvaluationCasesProvider);
                        ref.invalidate(
                          healthAiEvaluationReviewHistoryProvider(item.id),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } on AppException catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.message)));
                        }
                        setState(() => saving = false);
                      }
                    },
              child: Text(saving ? 'Saving...' : 'Save signed review'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    reg.dispose();
    notes.dispose();
  }

  static String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Required' : null;
}

final class _ReviewHistory extends ConsumerWidget {
  const _ReviewHistory({required this.caseId});
  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(healthAiEvaluationReviewHistoryProvider(caseId));
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('Complete review history / Mukammal record'),
      children: [
        history.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => ListTile(
            title: const Text('Review history could not load.'),
            subtitle: Text('$error'),
            trailing: IconButton(
              onPressed: () => ref.invalidate(
                healthAiEvaluationReviewHistoryProvider(caseId),
              ),
              icon: const Icon(Icons.refresh),
            ),
          ),
          data: (reviews) => reviews.isEmpty
              ? const ListTile(
                  title: Text(
                    'No signed reviews yet / Abhi koi signed review nahi',
                  ),
                )
              : Column(
                  children: [
                    for (var index = 0; index < reviews.length; index++)
                      _ReviewHistoryItem(
                        review: reviews[index],
                        number: reviews.length - index,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

final class _ReviewHistoryItem extends StatelessWidget {
  const _ReviewHistoryItem({required this.review, required this.number});
  final HealthAiEvaluationReview review;
  final int number;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(child: Text('$number')),
    title: Text('${review.decision} · ${review.reviewerName}'),
    subtitle: Text(
      '${review.reviewerRegistration}\n${review.notes}\n${MaterialLocalizations.of(context).formatMediumDate(review.reviewedAt.toLocal())}',
    ),
    isThreeLine: true,
  );
}

import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/features/health/application/health_providers.dart';
import 'package:dairycare_mobile/features/health/domain/health_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final class HealthAiAskScreen extends ConsumerStatefulWidget {
  const HealthAiAskScreen({super.key});

  @override
  ConsumerState<HealthAiAskScreen> createState() => _HealthAiAskScreenState();
}

final class _HealthAiAskScreenState extends ConsumerState<HealthAiAskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _question = TextEditingController();
  final _selectedSymptoms = <String>{};
  String _species = 'cattle';
  String _language = 'both';
  bool _loading = false;
  HealthAiAnswer? _result;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symptoms = ref.watch(healthSymptomsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ask Health Guide / Sehat Guide')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Card(
              color: Color(0xFFFFF8E1),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'This shows possible conditions and safe first steps only. It cannot diagnose or prescribe medicine. Halat serious ho to foran veterinarian ko bulayein.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 280,
                  child: DropdownButtonFormField<String>(
                    initialValue: _species,
                    decoration: const InputDecoration(
                      labelText: 'Animal / Janwar',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'cattle',
                        child: Text('Cow / Cattle'),
                      ),
                      DropdownMenuItem(
                        value: 'buffalo',
                        child: Text('Buffalo / Bhains'),
                      ),
                      DropdownMenuItem(
                        value: 'goat',
                        child: Text('Goat / Bakri'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _species = value ?? _species),
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: DropdownButtonFormField<String>(
                    initialValue: _language,
                    decoration: const InputDecoration(
                      labelText: 'Answer language',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'both',
                        child: Text('English + Roman Urdu'),
                      ),
                      DropdownMenuItem(
                        value: 'english',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'roman_urdu',
                        child: Text('Roman Urdu'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _language = value ?? _language),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _question,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What is happening? / Kya masla hai?',
                hintText: 'Example: The udder is swollen and milk has clots.',
              ),
              validator: (value) => (value?.trim().length ?? 0) < 5
                  ? 'Please describe the problem in at least 5 characters.'
                  : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Visible signs / Nazar anay wali alamat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            symptoms.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => ListTile(
                title: const Text('Symptoms could not load.'),
                subtitle: Text('$error'),
                trailing: IconButton(
                  onPressed: () => ref.invalidate(healthSymptomsProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ),
              data: (items) => ExpansionTile(
                initiallyExpanded: true,
                title: Text(
                  '${_selectedSymptoms.length} selected / select karein',
                ),
                children: [
                  for (final symptom in items)
                    CheckboxListTile(
                      value: _selectedSymptoms.contains(symptom.code),
                      title: Text(
                        '${symptom.name}${symptom.nameRomanUrdu == null ? '' : ' / ${symptom.nameRomanUrdu}'}',
                      ),
                      subtitle: symptom.isEmergency
                          ? const Text(
                              'Emergency sign / Fori alamat',
                              style: TextStyle(color: Colors.red),
                            )
                          : null,
                      onChanged: (checked) => setState(() {
                        checked == true
                            ? _selectedSymptoms.add(symptom.code)
                            : _selectedSymptoms.remove(symptom.code);
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading ? null : _ask,
              icon: _loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: const Text('Show safe guidance / Mehfooz rehnumai'),
            ),
            if (_result case final result?) ...[
              const SizedBox(height: 20),
              _AnswerCard(result: result, language: _language),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _ask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final answer = await ref.read(healthRepositoryProvider).askHealthGuide({
        'question': _question.text.trim(),
        'species': _species,
        'symptom_codes': _selectedSymptoms.toList(),
        'language': _language,
      });
      if (mounted) setState(() => _result = answer);
    } on AppException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

final class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.result, required this.language});
  final HealthAiAnswer result;
  final String language;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (result.emergency)
        const Card(
          color: Color(0xFFFFE5E5),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'EMERGENCY: Isolate the animal and contact a veterinarian now. / Janwar alag karein aur foran vet ko bulayein.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                label: Text(
                  result.mode == 'local_model_grounded'
                      ? 'Local AI + approved guide'
                      : 'Approved guide match',
                ),
              ),
              if (language != 'roman_urdu') Text(result.answer),
              if (language != 'english' &&
                  result.answerRomanUrdu.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  result.answerRomanUrdu,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
              const Divider(height: 24),
              Text(
                result.safetyNotice,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      if (result.matches.isEmpty)
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No approved match found. Please contact a veterinarian.',
            ),
          ),
        ),
      for (final match in result.matches) _MatchCard(match: match),
    ],
  );
}

final class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});
  final HealthAiMatch match;

  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(
      initiallyExpanded: match.urgency == 'emergency',
      leading: Icon(
        match.urgency == 'emergency'
            ? Icons.warning_amber
            : Icons.medical_information_outlined,
        color: match.urgency == 'emergency' ? Colors.red : null,
      ),
      title: Text(
        '${match.name}${match.nameRomanUrdu == null ? '' : ' / ${match.nameRomanUrdu}'}',
      ),
      subtitle: Text('Possible match only · ${match.urgency}'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section('What it may mean', match.summary),
        _section('Do now / Abhi kya karein', match.immediateCare),
        if (match.immediateCareRomanUrdu?.isNotEmpty ?? false)
          _section('Roman Urdu', match.immediateCareRomanUrdu!),
        if (match.doNotDo?.isNotEmpty ?? false)
          _section('Do not do / Yeh na karein', match.doNotDo!),
        if (match.feedWaterGuidance?.isNotEmpty ?? false)
          _section('Feed and water', match.feedWaterGuidance!),
        if (match.confirmationGuidance?.isNotEmpty ?? false)
          _section('Veterinary confirmation', match.confirmationGuidance!),
        TextButton.icon(
          onPressed: match.source.url.isEmpty
              ? null
              : () => launchUrl(Uri.parse(match.source.url)),
          icon: const Icon(Icons.verified_outlined),
          label: Text(
            'Approved source: ${match.source.title}${match.source.reviewedOn == null ? '' : ' · reviewed ${match.source.reviewedOn}'}',
          ),
        ),
      ],
    ),
  );

  Widget _section(String title, String value) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    ),
  );
}

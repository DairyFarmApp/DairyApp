import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
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
  final _question = TextEditingController();
  final _conversation = <_ChatExchange>[];
  String? _rememberedSpecies;
  String? _selectedAnimalId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(animalListControllerProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animals = ref.watch(animalListControllerProvider);
    final selectedAnimal = animals.asData?.value.items
        .where((animal) => animal.id == _selectedAnimalId)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Health Assistant / Sehat Assistant'),
        actions: [
          TextButton.icon(
            onPressed: _conversation.isEmpty || _loading ? null : _newChat,
            icon: const Icon(Icons.add_comment_outlined),
            label: const Text('New Chat'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: animals.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text(
                    'Animal list could not load. You can still ask a general question.',
                  ),
                  data: (state) => DropdownButtonFormField<String?>(
                    initialValue: _selectedAnimalId,
                    decoration: const InputDecoration(
                      labelText: 'Select animal / Janwar select karein',
                      prefixIcon: Icon(Icons.pets_outlined),
                      helperText:
                          'Uses this animal\'s saved disease and treatment history.',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('General question / Koi khaas janwar nahi'),
                      ),
                      ...state.items.map(
                        (animal) => DropdownMenuItem<String?>(
                          value: animal.id,
                          child: Text(_animalLabel(animal)),
                        ),
                      ),
                    ],
                    onChanged: _loading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedAnimalId = value;
                              _conversation.clear();
                              _question.clear();
                              _rememberedSpecies = value == null
                                  ? null
                                  : _speciesFromAnimal(
                                      state.items.firstWhere(
                                        (animal) => animal.id == value,
                                      ),
                                    );
                            });
                          },
                  ),
                ),
              ),
            ),
          ),
          if (selectedAnimal != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.history_rounded, size: 18),
                  label: Text(
                    'History linked: ${_animalLabel(selectedAnimal)}',
                  ),
                ),
              ),
            ),
          Expanded(
            child: _conversation.isEmpty
                ? const _ChatWelcome()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    itemCount: _conversation.length,
                    itemBuilder: (context, index) {
                      final exchange = _conversation[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 720),
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                exchange.question,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          _AnswerCard(
                            result: exchange.answer,
                            language: 'both',
                          ),
                          const SizedBox(height: 28),
                        ],
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: TextField(
                controller: _question,
                minLines: 1,
                maxLines: 4,
                onSubmitted: (_) => _loading ? null : _ask(),
                decoration: InputDecoration(
                  hintText:
                      'Describe the problem in English or Roman Urdu... / Masla likhein...',
                  helperText: _rememberedSpecies == null
                      ? 'Mention cow/gai, buffalo/bhains, or goat/bakri in your first message.'
                      : 'Chat context active: ${_speciesLabel(_rememberedSpecies!)}. Follow-up messages will remember earlier details.',
                  suffixIcon: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          tooltip: 'Send / Bhejein',
                          onPressed: _ask,
                          icon: const Icon(Icons.send_rounded),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ask() async {
    final question = _question.text.trim();
    if (question.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the problem in a little more detail.'),
        ),
      );
      return;
    }
    final species = _detectSpecies(question) ?? _rememberedSpecies;
    if (species == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please mention the animal: cow/gai, buffalo/bhains, or goat/bakri.',
          ),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final answer = await ref.read(healthRepositoryProvider).askHealthGuide({
        'question': _questionWithContext(question),
        'species': species,
        'symptom_codes': <String>[],
        'language': 'both',
        if (_selectedAnimalId != null) 'animal_id': _selectedAnimalId,
      });
      if (mounted) {
        setState(() {
          _rememberedSpecies = species;
          _conversation.add(
            _ChatExchange(question: question, answer: answer, language: 'both'),
          );
          _question.clear();
        });
      }
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

  String? _detectSpecies(String question) {
    final text = question.toLowerCase();
    if (RegExp(r'\b(goat|bakri|bakra)\b').hasMatch(text)) return 'goat';
    if (RegExp(r'\b(buffalo|bhains|bhais)\b').hasMatch(text)) return 'buffalo';
    if (RegExp(r'\b(cow|cattle|gai|gaaye|gay)\b').hasMatch(text)) {
      return 'cattle';
    }
    return null;
  }

  String _questionWithContext(String currentQuestion) {
    var context = 'Current message: ${_shorten(currentQuestion, 700)}';
    for (final exchange in _conversation.reversed.take(4)) {
      final possibleConditions = exchange.answer.matches
          .map((match) => match.code)
          .take(2)
          .join(', ');
      final previous =
          'Earlier message: ${_shorten(exchange.question, 160)}'
          '${possibleConditions.isEmpty ? '' : ' (earlier possible matches: $possibleConditions)'}\n';
      if (previous.length + context.length > 980) break;
      context = previous + context;
    }
    return context;
  }

  String _shorten(String value, int maximum) =>
      value.length <= maximum ? value : value.substring(0, maximum);

  String _speciesLabel(String species) => switch (species) {
    'goat' => 'Goat / Bakri',
    'buffalo' => 'Buffalo / Bhains',
    _ => 'Cow / Gai',
  };

  String _speciesFromAnimal(Animal animal) {
    final species = animal.speciesName.toLowerCase();
    if (species.contains('goat')) return 'goat';
    if (species.contains('buffalo')) return 'buffalo';
    return 'cattle';
  }

  String _animalLabel(Animal animal) =>
      '${animal.animalNumber}${animal.name?.trim().isNotEmpty ?? false ? ' · ${animal.name}' : ''} · ${animal.speciesName}';

  void _newChat() {
    setState(() {
      _conversation.clear();
      if (_selectedAnimalId == null) _rememberedSpecies = null;
      _question.clear();
    });
  }
}

final class _ChatExchange {
  const _ChatExchange({
    required this.question,
    required this.answer,
    required this.language,
  });

  final String question;
  final HealthAiAnswer answer;
  final String language;
}

final class _ChatWelcome extends StatelessWidget {
  const _ChatWelcome();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.smart_toy_outlined,
                  size: 54,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'How can I help your animal?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Apne janwar ka masla seedhay alfaaz mein likhein. You may write in English or Roman Urdu. Symptoms are optional.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'For emergencies, isolate the animal and contact a veterinarian immediately.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

final class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.result, required this.language});
  final HealthAiAnswer result;
  final String language;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (result.emergency) ...[
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
        const SizedBox(height: 12),
      ],
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Chip(label: Text('Animal health guidance')),
              const SizedBox(height: 14),
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
      for (final match in result.matches) ...[
        const SizedBox(height: 12),
        _MatchCard(match: match),
      ],
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
        _section(
          'Medicine options in Pakistan',
          match.medicines.isEmpty
              ? 'No DRAP-sourced medicine record is available for this possible condition yet.'
              : match.medicines.map(_medicineText).join('\n\n'),
        ),
        if (match.confirmationGuidance?.isNotEmpty ?? false)
          _section('Veterinary confirmation', match.confirmationGuidance!),
        TextButton.icon(
          onPressed: match.source.url.isEmpty
              ? null
              : () => launchUrl(Uri.parse(match.source.url)),
          icon: const Icon(Icons.verified_outlined),
          label: Text(
            'Authentic reference: ${match.source.title}${match.source.reviewedOn == null ? '' : ' · checked ${match.source.reviewedOn}'}',
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

  String _medicineText(HealthAiMedicine medicine) {
    final identity = [
      medicine.brandName,
      medicine.activeIngredient,
      medicine.dosageForm,
    ].whereType<String>().where((value) => value.isNotEmpty).join(' Â· ');
    final details = <String>[
      identity,
      if (medicine.manufacturer?.isNotEmpty ?? false)
        'Manufacturer: ${medicine.manufacturer}',
      if (medicine.drapRegistrationNumber?.isNotEmpty ?? false)
        'DRAP registration: ${medicine.drapRegistrationNumber}',
      'Use: ${medicine.indication}',
      if (medicine.speciesScope?.isNotEmpty ?? false)
        'Species: ${medicine.speciesScope}',
      if (medicine.contraindications?.isNotEmpty ?? false)
        'Do not use / precautions: ${medicine.contraindications}',
      if (medicine.withdrawalGuidance?.isNotEmpty ?? false)
        'Milk/meat withdrawal: ${medicine.withdrawalGuidance}',
    ];
    return details.where((value) => value.isNotEmpty).join('\n');
  }
}

import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_repository.dart';
import 'package:dairycare_mobile/features/animals/domain/animal_models.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_registry_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class AnimalFormScreen extends ConsumerStatefulWidget {
  const AnimalFormScreen({super.key, this.animalId});

  final String? animalId;

  bool get isEditing => animalId != null;

  @override
  ConsumerState<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends ConsumerState<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _animalNumber = TextEditingController();
  final _earTag = TextEditingController();
  final _rfid = TextEditingController();
  final _name = TextEditingController();
  final _registration = TextEditingController();
  final _colour = TextEditingController();
  final _marks = TextEditingController();
  final _externalSire = TextEditingController();
  final _source = TextEditingController();
  final _notes = TextEditingController();

  bool _initialized = false;
  bool _saving = false;
  String? _error;
  String? _speciesId;
  String? _breedId;
  String? _farmId;
  String? _shedId;
  String? _groupId;
  String? _motherId;
  String? _fatherId;
  String _sex = 'female';
  String _lifeStage = 'adult';
  String _origin = 'born_on_farm';
  String _operationalStatus = 'active';
  DateTime? _dateOfBirth;
  DateTime? _acquisitionDate;
  bool _estimatedBirthDate = false;

  @override
  void dispose() {
    for (final controller in [
      _animalNumber,
      _earTag,
      _rfid,
      _name,
      _registration,
      _colour,
      _marks,
      _externalSire,
      _source,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final organizationId = session?.activeOrganizationId;
    if (organizationId == null) {
      return const Scaffold(
        body: EmptyStateView(message: 'Select an organization.'),
      );
    }
    final references = ref.watch(animalReferencesProvider(organizationId));
    final animal = widget.animalId == null
        ? const AsyncValue<Animal?>.data(null)
        : ref
              .watch(animalDetailProvider(widget.animalId!))
              .whenData((value) => value);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? AnimalRegistryStrings.editAnimal
              : AnimalRegistryStrings.addAnimal,
        ),
      ),
      body: references.when(
        loading: () => const LoadingStateView(label: 'Loading form data...'),
        error: (error, _) => ErrorStateView(
          message: error.toString(),
          onRetry: () =>
              ref.invalidate(animalReferencesProvider(organizationId)),
        ),
        data: (referenceData) => animal.when(
          loading: () => const LoadingStateView(label: 'Loading animal...'),
          error: (error, _) => ErrorStateView(
            message: error.toString(),
            onRetry: () =>
                ref.invalidate(animalDetailProvider(widget.animalId!)),
          ),
          data: (existing) {
            _initialize(referenceData, existing, session?.activeFarmId);
            return _form(
              context,
              referenceData,
              existing,
              session?.can('animals.manage_identifiers') ?? false,
            );
          },
        ),
      ),
    );
  }

  void _initialize(
    AnimalReferenceData references,
    Animal? animal,
    String? activeFarmId,
  ) {
    if (_initialized) return;
    _initialized = true;
    if (animal == null) {
      _farmId = activeFarmId ?? references.farms.firstOrNull?.id;
      _speciesId = references.species
          .where((item) => item.isActive)
          .firstOrNull
          ?.id;
      _breedId = _activeBreeds(references).firstOrNull?.id;
      _shedId = _farmSheds(references).firstOrNull?.id;
      return;
    }
    _animalNumber.text = animal.animalNumber;
    _earTag.text = animal.earTagNumber ?? '';
    _rfid.text = animal.rfidNumber ?? '';
    _name.text = animal.name ?? '';
    _registration.text = animal.registrationNumber ?? '';
    _colour.text = animal.colour ?? '';
    _marks.text = animal.identifyingMarks ?? '';
    _externalSire.text = animal.externalSireReference ?? '';
    _source.text = animal.sourceDescription ?? '';
    _notes.text = animal.notes ?? '';
    _speciesId = animal.speciesId;
    _breedId = animal.breedId;
    _sex = animal.sex;
    _lifeStage = animal.lifeStage;
    _dateOfBirth = animal.dateOfBirth;
    _estimatedBirthDate = animal.isDateOfBirthEstimated;
    _farmId = animal.currentFarmId;
    _shedId = animal.currentShedId;
    _groupId = animal.currentAnimalGroupId;
    _motherId = animal.motherAnimalId;
    _fatherId = animal.fatherAnimalId;
    _origin = animal.origin;
    _acquisitionDate = animal.acquisitionDate;
    _operationalStatus = animal.operationalStatus;
  }

  Widget _form(
    BuildContext context,
    AnimalReferenceData references,
    Animal? animal,
    bool canManageIdentifiers,
  ) {
    final breeds = _activeBreeds(references, preserveId: animal?.breedId);
    final sheds = _farmSheds(references);
    final groups = references.groups
        .where(
          (item) =>
              item.farmId == _farmId &&
              (!item.isArchived || item.id == animal?.currentAnimalGroupId) &&
              (item.isActive || item.id == animal?.currentAnimalGroupId),
        )
        .toList();
    final potentialMothers = references.animals
        .where((item) => item.sex == 'female' && item.id != animal?.id)
        .toList();
    final potentialFathers = references.animals
        .where((item) => item.sex == 'male' && item.id != animal?.id)
        .toList();
    final width = MediaQuery.sizeOf(context).width;
    final contentWidth = width >= 900 ? 820.0 : double.infinity;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: SizedBox(
              width: contentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle(context, 'Identity'),
                  if (!widget.isEditing && canManageIdentifiers)
                    TextFormField(
                      key: const Key('animal_number_field'),
                      controller: _animalNumber,
                      decoration: const InputDecoration(
                        labelText: 'Animal number (optional)',
                        helperText: 'Leave blank to generate the next number.',
                      ),
                    ),
                  if (widget.isEditing)
                    _readOnlyValue('Animal number', animal!.animalNumber),
                  if (!widget.isEditing || canManageIdentifiers) ...[
                    TextFormField(
                      key: const Key('ear_tag_field'),
                      controller: _earTag,
                      decoration: const InputDecoration(
                        labelText: 'Ear tag number',
                      ),
                    ),
                    TextFormField(
                      key: const Key('rfid_field'),
                      controller: _rfid,
                      decoration: const InputDecoration(
                        labelText: 'RFID number',
                      ),
                    ),
                  ] else ...[
                    _readOnlyValue('Ear tag number', animal!.earTagNumber),
                    _readOnlyValue('RFID number', animal.rfidNumber),
                  ],
                  TextFormField(
                    key: const Key('animal_name_field'),
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Animal name'),
                    maxLength: 120,
                  ),
                  TextFormField(
                    controller: _registration,
                    decoration: const InputDecoration(
                      labelText: 'Registration number',
                    ),
                    maxLength: 120,
                  ),
                  _sectionTitle(context, 'Classification'),
                  DropdownButtonFormField<String>(
                    key: const Key('species_field'),
                    initialValue: _speciesId,
                    decoration: const InputDecoration(labelText: 'Species *'),
                    items: [
                      for (final item in references.species.where(
                        (item) => item.isActive || item.id == animal?.speciesId,
                      ))
                        DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                    ],
                    validator: _requiredSelection,
                    onChanged: (value) => setState(() {
                      _speciesId = value;
                      _breedId = null;
                    }),
                  ),
                  DropdownButtonFormField<String>(
                    key: ValueKey('breed-$_speciesId-$_breedId'),
                    initialValue: breeds.any((item) => item.id == _breedId)
                        ? _breedId
                        : null,
                    decoration: const InputDecoration(labelText: 'Breed *'),
                    items: [
                      for (final item in breeds)
                        DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                    ],
                    validator: _requiredSelection,
                    onChanged: (value) => setState(() => _breedId = value),
                  ),
                  _enumDropdown(
                    key: const Key('sex_field'),
                    label: 'Sex *',
                    value: _sex,
                    values: const ['female', 'male'],
                    onChanged: (value) => setState(() => _sex = value!),
                  ),
                  _enumDropdown(
                    label: 'Life stage *',
                    value: _lifeStage,
                    values: const ['calf', 'juvenile', 'adult'],
                    onChanged: (value) => setState(() => _lifeStage = value!),
                  ),
                  _dateField(
                    label: 'Date of birth',
                    value: _dateOfBirth,
                    onChanged: (value) => setState(() => _dateOfBirth = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date of birth is estimated'),
                    value: _estimatedBirthDate,
                    onChanged: (value) =>
                        setState(() => _estimatedBirthDate = value),
                  ),
                  TextFormField(
                    controller: _colour,
                    decoration: const InputDecoration(labelText: 'Colour'),
                    maxLength: 80,
                  ),
                  TextFormField(
                    controller: _marks,
                    decoration: const InputDecoration(
                      labelText: 'Identifying marks',
                    ),
                    maxLines: 2,
                    maxLength: 2000,
                  ),
                  _sectionTitle(context, 'Initial location'),
                  if (widget.isEditing) ...[
                    _readOnlyValue('Farm', animal!.currentFarmName),
                    _readOnlyValue('Shed', animal.currentShedName),
                    _readOnlyValue('Group', animal.currentAnimalGroupName),
                    const Text(
                      'Location changes are recorded through the animal movement workflow.',
                    ),
                  ] else ...[
                    DropdownButtonFormField<String>(
                      key: const Key('farm_field'),
                      initialValue: _farmId,
                      decoration: const InputDecoration(labelText: 'Farm *'),
                      items: [
                        for (final item in references.farms)
                          DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                      ],
                      validator: _requiredSelection,
                      onChanged: (value) => setState(() {
                        _farmId = value;
                        _shedId = null;
                        _groupId = null;
                      }),
                    ),
                    DropdownButtonFormField<String>(
                      key: ValueKey('shed-$_farmId-$_shedId'),
                      initialValue: sheds.any((item) => item.id == _shedId)
                          ? _shedId
                          : null,
                      decoration: const InputDecoration(labelText: 'Shed *'),
                      items: [
                        for (final item in sheds)
                          DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                      ],
                      validator: _requiredSelection,
                      onChanged: (value) => setState(() => _shedId = value),
                    ),
                    DropdownButtonFormField<String>(
                      key: ValueKey('group-$_farmId-$_groupId'),
                      initialValue: groups.any((item) => item.id == _groupId)
                          ? _groupId
                          : null,
                      decoration: const InputDecoration(labelText: 'Group'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No group'),
                        ),
                        for (final item in groups)
                          DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                      ],
                      onChanged: (value) => setState(() => _groupId = value),
                    ),
                  ],
                  _sectionTitle(context, 'Parentage'),
                  _animalDropdown(
                    label: 'Mother',
                    value: _motherId,
                    animals: potentialMothers,
                    onChanged: (value) => setState(() => _motherId = value),
                  ),
                  _animalDropdown(
                    label: 'Father',
                    value: _fatherId,
                    animals: potentialFathers,
                    onChanged: (value) => setState(() => _fatherId = value),
                  ),
                  TextFormField(
                    controller: _externalSire,
                    decoration: const InputDecoration(
                      labelText: 'External sire reference',
                    ),
                    maxLength: 160,
                  ),
                  _sectionTitle(context, 'Origin and status'),
                  _enumDropdown(
                    label: 'Origin *',
                    value: _origin,
                    values: const [
                      'born_on_farm',
                      'purchased',
                      'transferred_in',
                      'other',
                    ],
                    onChanged: (value) => setState(() => _origin = value!),
                  ),
                  _dateField(
                    label: 'Acquisition date',
                    value: _acquisitionDate,
                    onChanged: (value) =>
                        setState(() => _acquisitionDate = value),
                  ),
                  TextFormField(
                    controller: _source,
                    decoration: const InputDecoration(
                      labelText: 'Source description',
                    ),
                    maxLength: 255,
                  ),
                  if (!widget.isEditing)
                    _enumDropdown(
                      label: 'Initial operational status *',
                      value: _operationalStatus,
                      values: const ['active', 'inactive', 'missing'],
                      onChanged: (value) =>
                          setState(() => _operationalStatus = value!),
                    )
                  else ...[
                    _readOnlyValue(
                      'Operational status',
                      _label(_operationalStatus),
                    ),
                    const Text(
                      'Post-registration status changes are recorded through the operational-status workflow.',
                    ),
                  ],
                  TextFormField(
                    controller: _notes,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 4,
                    maxLength: 5000,
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('save_animal_button'),
                    onPressed: _saving
                        ? null
                        : () => _save(animal, canManageIdentifiers),
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text(AnimalRegistryStrings.save),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<AnimalBreed> _activeBreeds(
    AnimalReferenceData references, {
    String? preserveId,
  }) => references.breeds
      .where(
        (item) =>
            item.speciesId == _speciesId &&
            ((!item.isArchived && item.isActive) || item.id == preserveId),
      )
      .toList();

  List<LocalShed> _farmSheds(AnimalReferenceData references) => references.sheds
      .where((item) => item.farmId == _farmId && !item.isDeleted)
      .toList();

  Future<void> _save(Animal? animal, bool canManageIdentifiers) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_speciesId == null ||
        _breedId == null ||
        _farmId == null ||
        _shedId == null) {
      setState(() => _error = 'Complete all required fields.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final draft = AnimalDraft(
      animalNumber: canManageIdentifiers ? _animalNumber.text : null,
      earTagNumber: _earTag.text,
      rfidNumber: _rfid.text,
      name: _name.text,
      registrationNumber: _registration.text,
      speciesId: _speciesId!,
      breedId: _breedId!,
      sex: _sex,
      lifeStage: _lifeStage,
      dateOfBirth: _dateOfBirth,
      isDateOfBirthEstimated: _estimatedBirthDate,
      colour: _colour.text,
      identifyingMarks: _marks.text,
      currentFarmId: _farmId!,
      currentShedId: _shedId!,
      currentAnimalGroupId: _groupId,
      motherAnimalId: _motherId,
      fatherAnimalId: _fatherId,
      externalSireReference: _externalSire.text,
      origin: _origin,
      acquisitionDate: _acquisitionDate,
      sourceDescription: _source.text,
      notes: _notes.text,
      operationalStatus: _operationalStatus,
    );
    try {
      final repository = ref.read(animalRepositoryProvider);
      final saved = animal == null
          ? await repository.createAnimal(draft)
          : await repository.updateAnimal(
              animal,
              draft,
              canManageIdentifiers: canManageIdentifiers,
            );
      ref.invalidate(animalListControllerProvider);
      ref.invalidate(animalDetailProvider(saved.id));
      if (mounted) context.go('/animals/${saved.id}');
    } on ValidationException catch (error) {
      setState(
        () => _error = [
          error.message,
          ...error.fieldErrors.values.expand((value) => value),
        ].join('\n'),
      );
    } on AppException catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );

  Widget _readOnlyValue(String label, String? value) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(value == null || value.isEmpty ? '-' : value),
  );

  DropdownButtonFormField<String> _enumDropdown({
    Key? key,
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) => DropdownButtonFormField<String>(
    key: key,
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final item in values)
        DropdownMenuItem(value: item, child: Text(_label(item))),
    ],
    onChanged: onChanged,
  );

  Widget _animalDropdown({
    required String label,
    required String? value,
    required List<Animal> animals,
    required ValueChanged<String?> onChanged,
  }) => DropdownButtonFormField<String>(
    initialValue: animals.any((item) => item.id == value) ? value : null,
    decoration: InputDecoration(labelText: label),
    items: [
      const DropdownMenuItem(value: null, child: Text('Not recorded')),
      for (final animal in animals)
        DropdownMenuItem(
          value: animal.id,
          child: Text(
            animal.name == null
                ? animal.animalNumber
                : '${animal.animalNumber} - ${animal.name}',
          ),
        ),
    ],
    onChanged: onChanged,
  );

  Widget _dateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) => Row(
    children: [
      Expanded(
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Text(
            value == null ? 'Not recorded' : DateFormat.yMMMd().format(value),
          ),
        ),
      ),
      IconButton(
        tooltip: 'Select $label',
        onPressed: () async {
          final selected = await showDatePicker(
            context: context,
            firstDate: DateTime(1990),
            lastDate: DateTime.now(),
            initialDate: value ?? DateTime.now(),
          );
          if (selected != null) onChanged(selected);
        },
        icon: const Icon(Icons.calendar_today_outlined),
      ),
      if (value != null)
        IconButton(
          tooltip: 'Clear $label',
          onPressed: () => onChanged(null),
          icon: const Icon(Icons.clear),
        ),
    ],
  );

  String? _requiredSelection(String? value) =>
      value == null ? 'This field is required.' : null;

  String _label(String value) => value
      .split('_')
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

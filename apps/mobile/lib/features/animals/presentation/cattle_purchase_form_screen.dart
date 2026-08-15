import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/formatting/pkr.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/animals/application/animal_providers.dart';
import 'package:dairycare_mobile/features/animals/data/animal_sales_repository.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CattlePurchaseFormScreen extends ConsumerStatefulWidget {
  const CattlePurchaseFormScreen({super.key});

  @override
  ConsumerState<CattlePurchaseFormScreen> createState() =>
      _CattlePurchaseFormScreenState();
}

class _CattlePurchaseFormScreenState
    extends ConsumerState<CattlePurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purchaseDateController = TextEditingController();
  final _supplierController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _transportationCostController = TextEditingController();
  final _veterinaryCostController = TextEditingController();
  final _notesController = TextEditingController();

  static const _animalImages = XTypeGroup(
    label: 'Animal photos',
    extensions: ['jpg', 'jpeg', 'png', 'webp'],
  );
  final List<XFile> _photos = [];

  DateTime? _purchaseDate;
  String? _speciesId;
  String? _breedId;
  String _sex = 'female';
  String _lifeStage = 'adult';
  String? _shedId;
  bool _saving = false;

  @override
  void dispose() {
    _purchaseDateController.dispose();
    _supplierController.dispose();
    _purchasePriceController.dispose();
    _transportationCostController.dispose();
    _veterinaryCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photos.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least four animal photos.')),
      );
      return;
    }
    if (_purchaseDate == null ||
        _speciesId == null ||
        _breedId == null ||
        _shedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required dropdowns and dates.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final data = {
        'purchase_date': DateFormat('yyyy-MM-dd').format(_purchaseDate!),
        'supplier': _supplierController.text.trim(),
        'purchase_price': double.tryParse(_purchasePriceController.text) ?? 0,
        'transportation_cost':
            double.tryParse(_transportationCostController.text) ?? 0,
        'veterinary_cost': double.tryParse(_veterinaryCostController.text) ?? 0,
        'notes': _notesController.text.trim(),
        'species_id': _speciesId,
        'breed_id': _breedId,
        'sex': _sex,
        'life_stage': _lifeStage,
        'shed_id': _shedId,
      };

      final purchase = await ref
          .read(animalSalesRepositoryProvider)
          .createPurchase(data);
      final animalId = purchase['animal_id'] as String;
      for (final photo in _photos) {
        await ref
            .read(animalRepositoryProvider)
            .uploadPhoto(
              animalId: animalId,
              bytes: await photo.readAsBytes(),
              filename: photo.name,
            );
      }
      ref.invalidate(animalPurchasesProvider);
      ref.invalidate(animalListControllerProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Purchase registered successfully. Animal added to In-House Registry.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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

    return Scaffold(
      appBar: AppBar(title: const Text('New Cattle Purchase')),
      body: references.when(
        loading: () =>
            const LoadingStateView(label: 'Loading reference data...'),
        error: (err, _) => ErrorStateView(
          message: err.toString(),
          onRetry: () =>
              ref.invalidate(animalReferencesProvider(organizationId)),
        ),
        data: (refs) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Purchase Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _supplierController,
                                  decoration: const InputDecoration(
                                    labelText: 'Supplier Name',
                                    filled: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _purchaseDateController,
                                  decoration: const InputDecoration(
                                    labelText: 'Purchase Date *',
                                    filled: true,
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _purchaseDate = date;
                                        _purchaseDateController.text =
                                            DateFormat.yMMMd().format(date);
                                      });
                                    }
                                  },
                                  validator: (v) =>
                                      v!.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _purchasePriceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Purchase Price (PKR) *',
                                    filled: true,
                                    prefixText: 'PKR ',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: pkrInputFormatters,
                                  validator: (value) => validatePkrAmount(
                                    value,
                                    allowZero: false,
                                    required: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _transportationCostController,
                                  decoration: const InputDecoration(
                                    labelText: 'Transportation Cost (PKR)',
                                    filled: true,
                                    prefixText: 'PKR ',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: pkrInputFormatters,
                                  validator: validatePkrAmount,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _veterinaryCostController,
                                  decoration: const InputDecoration(
                                    labelText: 'Veterinary Cost (PKR)',
                                    filled: true,
                                    prefixText: 'PKR ',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: pkrInputFormatters,
                                  validator: validatePkrAmount,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'Animal Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          const ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.numbers_rounded),
                            title: Text('Animal number'),
                            subtitle: Text(
                              'Generated automatically in sequence when the purchase is saved.',
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _speciesId,
                                  decoration: const InputDecoration(
                                    labelText: 'Species *',
                                    filled: true,
                                  ),
                                  items: refs.species
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s.id,
                                          child: Text(s.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setState(() {
                                    _speciesId = v;
                                    _breedId =
                                        null; // reset breed when species changes
                                  }),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _breedId,
                                  decoration: const InputDecoration(
                                    labelText: 'Breed *',
                                    filled: true,
                                  ),
                                  items: refs.breeds
                                      .where(
                                        (b) =>
                                            _speciesId == null ||
                                            b.speciesId == _speciesId,
                                      )
                                      .map(
                                        (b) => DropdownMenuItem(
                                          value: b.id,
                                          child: Text(b.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _breedId = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _sex,
                                  decoration: const InputDecoration(
                                    labelText: 'Sex *',
                                    filled: true,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'female',
                                      child: Text('Female'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'male',
                                      child: Text('Male'),
                                    ),
                                  ],
                                  onChanged: (v) => setState(() => _sex = v!),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _lifeStage,
                                  decoration: const InputDecoration(
                                    labelText: 'Life Stage *',
                                    filled: true,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'adult',
                                      child: Text('Adult'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'juvenile',
                                      child: Text('Juvenile'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'calf',
                                      child: Text('Calf'),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _lifeStage = v!),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _shedId,
                                  decoration: const InputDecoration(
                                    labelText: 'Assign to Shed *',
                                    filled: true,
                                  ),
                                  items: refs.sheds
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s.id,
                                          child: Text(s.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setState(() => _shedId = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Animal Photos * (${_photos.length}/4 minimum)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            key: const Key('select_purchase_animal_photos'),
                            onPressed: _saving ? null : _selectPhotos,
                            icon: const Icon(Icons.add_a_photo_outlined),
                            label: const Text('Select 4 or more photos'),
                          ),
                          for (final photo in _photos)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.image_outlined),
                              title: Text(photo.name),
                              trailing: IconButton(
                                tooltip: 'Remove photo',
                                onPressed: _saving
                                    ? null
                                    : () =>
                                          setState(() => _photos.remove(photo)),
                                icon: const Icon(Icons.close),
                              ),
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              filled: true,
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _saving ? null : () => context.pop(),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 16),
                              FilledButton(
                                onPressed: _saving ? null : _submit,
                                child: _saving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Register Purchase'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectPhotos() async {
    final selected = await openFiles(acceptedTypeGroups: [_animalImages]);
    if (!mounted) return;
    setState(() {
      for (final photo in selected) {
        if (_photos.length >= 12) break;
        if (!_photos.any((existing) => existing.path == photo.path)) {
          _photos.add(photo);
        }
      }
    });
  }
}

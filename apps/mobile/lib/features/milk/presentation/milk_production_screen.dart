import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/milk/application/milk_providers.dart';
import 'package:dairycare_mobile/features/milk/domain/milk_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final class MilkProductionScreen extends ConsumerStatefulWidget {
  const MilkProductionScreen({super.key});

  @override
  ConsumerState<MilkProductionScreen> createState() =>
      _MilkProductionScreenState();
}

final class _MilkProductionScreenState
    extends ConsumerState<MilkProductionScreen> {
  DateTime _date = DateTime.now();
  MilkingSession _session = _defaultSession();
  bool _saving = false;
  final Map<String, TextEditingController> _quantity = {};
  final Map<String, TextEditingController> _rejected = {};
  final Map<String, TextEditingController> _reason = {};

  static MilkingSession _defaultSession() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MilkingSession.morning;
    if (hour < 16) return MilkingSession.afternoon;
    return MilkingSession.evening;
  }

  @override
  void dispose() {
    _clearControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider).asData?.value;
    final organizationId = auth?.activeOrganizationId;
    final farmId = auth?.activeFarmId;
    if (organizationId == null || farmId == null) {
      return const Scaffold(
        body: EmptyStateView(
          title: 'Choose a farm first',
          message: 'Milk production belongs to the active dairy farm.',
        ),
      );
    }
    final query = (
      organizationId: organizationId,
      farmId: farmId,
      date: DateTime(_date.year, _date.month, _date.day),
      session: _session,
    );
    final daily = ref.watch(milkDailyProvider(query));
    final canCreate = auth?.can('milk.create') ?? false;
    final canCorrect = auth?.can('milk.correct') ?? false;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(milkDailyProvider(query).future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContent(
            maxWidth: 1440,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  eyebrow: 'Daily production',
                  title: 'Milk production',
                  subtitle:
                      'Record each animal once per milking session. Totals come directly from saved production records.',
                  actions: [
                    OutlinedButton.icon(
                      onPressed: () => _pickDate(context),
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(DateFormat.yMMMd().format(_date)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SessionSelector(
                  selected: _session,
                  onChanged: (value) {
                    _clearControllers();
                    setState(() => _session = value);
                  },
                ),
                const SizedBox(height: 20),
                daily.when(
                  loading: () =>
                      const LoadingStateView(label: 'Loading daily milk…'),
                  error: (error, _) => ErrorStateView(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(milkDailyProvider(query)),
                  ),
                  data: (data) => _DailyContent(
                    data: data,
                    canCreate: canCreate,
                    canCorrect: canCorrect,
                    saving: _saving,
                    quantityController: _quantityController,
                    rejectedController: _rejectedController,
                    reasonController: _reasonController,
                    onSave: () => _save(data, query),
                    onCorrect: (entry) => _correct(entry, query),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextEditingController _quantityController(String animalId) =>
      _quantity.putIfAbsent(animalId, TextEditingController.new);

  TextEditingController _rejectedController(String animalId) =>
      _rejected.putIfAbsent(animalId, () => TextEditingController(text: '0'));

  TextEditingController _reasonController(String animalId) =>
      _reason.putIfAbsent(animalId, TextEditingController.new);

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Choose production date',
    );
    if (picked == null || !mounted) return;
    _clearControllers();
    setState(() => _date = picked);
  }

  Future<void> _save(MilkDailyData data, MilkDailyQuery query) async {
    final recorded = data.entries.map((entry) => entry.animalId).toSet();
    final drafts = <MilkEntryDraft>[];
    for (final animal in data.eligibleAnimals) {
      if (recorded.contains(animal.id)) continue;
      final quantityText = _quantityController(animal.id).text.trim();
      if (quantityText.isEmpty) continue;
      final quantity = double.tryParse(quantityText);
      final rejectedText = _rejectedController(animal.id).text.trim();
      final rejected = double.tryParse(
        rejectedText.isEmpty ? '0' : rejectedText,
      );
      final reason = _reasonController(animal.id).text.trim();
      if (quantity == null || quantity <= 0) {
        _message('Enter a valid milk quantity for ${animal.animalNumber}.');
        return;
      }
      if (rejected == null || rejected < 0 || rejected > quantity) {
        _message(
          'Rejected milk for ${animal.animalNumber} must be between 0 and the total quantity.',
        );
        return;
      }
      if (rejected > 0 && reason.isEmpty) {
        _message('Enter a rejection reason for ${animal.animalNumber}.');
        return;
      }
      drafts.add(
        MilkEntryDraft(
          animal: animal,
          quantityLitres: quantity.toStringAsFixed(3),
          rejectedQuantityLitres: rejected.toStringAsFixed(3),
          rejectionReason: reason.isEmpty ? null : reason,
        ),
      );
    }
    if (drafts.isEmpty) {
      _message('Enter milk for at least one unrecorded animal.');
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await ref
          .read(milkRepositoryProvider)
          .saveBulk(
            organizationId: query.organizationId,
            farmId: query.farmId,
            productionDate: query.date,
            session: query.session,
            drafts: drafts,
          );
      if (!mounted) return;
      _clearControllers();
      ref.invalidate(milkDailyProvider(query));
      _message(
        result.queuedOffline
            ? '${drafts.length} milk entries saved offline and waiting to sync.'
            : '${drafts.length} milk entries saved.',
      );
    } catch (error) {
      if (mounted) _message(error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _correct(MilkEntry entry, MilkDailyQuery query) async {
    final values = await showDialog<_CorrectionValues>(
      context: context,
      builder: (context) => _CorrectionDialog(entry: entry),
    );
    if (values == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(milkRepositoryProvider)
          .correct(
            entry: entry,
            quantityLitres: values.quantity,
            rejectedQuantityLitres: values.rejected,
            rejectionReason: values.rejectionReason,
            notes: values.notes,
            correctionReason: values.correctionReason,
          );
      if (!mounted) return;
      ref.invalidate(milkDailyProvider(query));
      _message('Milk entry corrected. The original remains in history.');
    } catch (error) {
      if (mounted) _message(error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _clearControllers() {
    for (final controller in [
      ..._quantity.values,
      ..._rejected.values,
      ..._reason.values,
    ]) {
      controller.dispose();
    }
    _quantity.clear();
    _rejected.clear();
    _reason.clear();
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }
}

final class _DailyContent extends StatelessWidget {
  const _DailyContent({
    required this.data,
    required this.canCreate,
    required this.canCorrect,
    required this.saving,
    required this.quantityController,
    required this.rejectedController,
    required this.reasonController,
    required this.onSave,
    required this.onCorrect,
  });

  final MilkDailyData data;
  final bool canCreate;
  final bool canCorrect;
  final bool saving;
  final TextEditingController Function(String animalId) quantityController;
  final TextEditingController Function(String animalId) rejectedController;
  final TextEditingController Function(String animalId) reasonController;
  final VoidCallback onSave;
  final ValueChanged<MilkEntry> onCorrect;

  @override
  Widget build(BuildContext context) {
    final recorded = {for (final entry in data.entries) entry.animalId: entry};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data.isCached) ...[
          const _OfflineBanner(),
          const SizedBox(height: 16),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth >= 1100
                ? (constraints.maxWidth - 64) / 5
                : constraints.maxWidth >= 680
                ? (constraints.maxWidth - 32) / 3
                : (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  height: 230,
                  child: MetricCard(
                    label: 'Total milk',
                    value: '${data.summary.totalLitres} L',
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFF2D9CDB),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  height: 230,
                  child: MetricCard(
                    label: 'Sellable milk',
                    value: '${data.summary.sellableLitres} L',
                    icon: Icons.verified_rounded,
                    color: const Color(0xFF2BAE74),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  height: 230,
                  child: MetricCard(
                    label: 'Rejected',
                    value: '${data.summary.rejectedLitres} L',
                    icon: Icons.block_rounded,
                    color: const Color(0xFFE85D75),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  height: 230,
                  child: MetricCard(
                    label: 'Yesterday',
                    value: '${data.summary.yesterdaySellableLitres} L',
                    icon: Icons.history_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  height: 230,
                  child: MetricCard(
                    label: '7-day average',
                    value: '${data.summary.sevenDayDailyAverageLitres} L',
                    icon: Icons.show_chart_rounded,
                    helper: '${data.summary.animalsRecorded} animals recorded',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: '${data.session.label} quick entry',
          subtitle:
              'Enter litres for unrecorded adult female animals. Existing records are protected and corrected separately.',
          trailing: canCreate
              ? FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: const Text('Save entries'),
                )
              : null,
          child: data.eligibleAnimals.isEmpty
              ? const EmptyStateView(
                  title: 'No eligible animals',
                  message:
                      'Add an active adult female animal before recording milk.',
                )
              : Column(
                  children: [
                    for (final animal in data.eligibleAnimals) ...[
                      _AnimalMilkRow(
                        animal: animal,
                        existing: recorded[animal.id],
                        canCreate: canCreate,
                        canCorrect: canCorrect,
                        quantity: quantityController(animal.id),
                        rejected: rejectedController(animal.id),
                        reason: reasonController(animal.id),
                        onCorrect: onCorrect,
                      ),
                      if (animal != data.eligibleAnimals.last)
                        const Divider(height: 28),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

final class _AnimalMilkRow extends StatelessWidget {
  const _AnimalMilkRow({
    required this.animal,
    required this.existing,
    required this.canCreate,
    required this.canCorrect,
    required this.quantity,
    required this.rejected,
    required this.reason,
    required this.onCorrect,
  });

  final MilkEligibleAnimal animal;
  final MilkEntry? existing;
  final bool canCreate;
  final bool canCorrect;
  final TextEditingController quantity;
  final TextEditingController rejected;
  final TextEditingController reason;
  final ValueChanged<MilkEntry> onCorrect;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final identity = ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          child: Text(
            animal.animalNumber.characters.firstOrNull?.toUpperCase() ?? 'A',
          ),
        ),
        title: Text(
          animal.name?.isNotEmpty == true
              ? '${animal.animalNumber} · ${animal.name}'
              : animal.animalNumber,
        ),
        subtitle: Text(animal.shedName ?? 'Assigned shed'),
      );
      if (existing != null) {
        final recorded = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              existing!.syncState == 'synced'
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_upload_outlined,
              color: existing!.syncState == 'synced'
                  ? Colors.green
                  : Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 8),
            Text(
              '${existing!.quantityLitres} L'
              '${existing!.rejectedQuantity > 0 ? ' · ${existing!.rejectedQuantityLitres} L rejected' : ''}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (canCorrect && existing!.syncState == 'synced') ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Correct entry',
                onPressed: () => onCorrect(existing!),
                icon: const Icon(Icons.edit_note_rounded),
              ),
            ],
          ],
        );
        return constraints.maxWidth < 700
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [identity, recorded],
              )
            : Row(
                children: [
                  Expanded(flex: 3, child: identity),
                  recorded,
                ],
              );
      }
      final fields = [
        SizedBox(
          width: 150,
          child: TextField(
            controller: quantity,
            enabled: canCreate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Milk litres',
              suffixText: 'L',
            ),
          ),
        ),
        SizedBox(
          width: 150,
          child: TextField(
            controller: rejected,
            enabled: canCreate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Rejected',
              suffixText: 'L',
            ),
          ),
        ),
        SizedBox(
          width: 220,
          child: TextField(
            controller: reason,
            enabled: canCreate,
            decoration: const InputDecoration(
              labelText: 'Rejection reason',
              hintText: 'Only when rejected',
            ),
          ),
        ),
      ];
      return constraints.maxWidth < 800
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                identity,
                Wrap(spacing: 12, runSpacing: 12, children: fields),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 3, child: identity),
                const SizedBox(width: 16),
                ...fields.expand((field) => [field, const SizedBox(width: 12)]),
              ],
            );
    },
  );
}

final class _SessionSelector extends StatelessWidget {
  const _SessionSelector({required this.selected, required this.onChanged});

  final MilkingSession selected;
  final ValueChanged<MilkingSession> onChanged;

  @override
  Widget build(BuildContext context) => GlassSurface(
    padding: const EdgeInsets.all(8),
    child: SegmentedButton<MilkingSession>(
      segments: [
        for (final session in MilkingSession.values)
          ButtonSegment(
            value: session,
            label: Text(session.label),
            icon: Icon(switch (session) {
              MilkingSession.morning => Icons.wb_sunny_outlined,
              MilkingSession.afternoon => Icons.light_mode_outlined,
              MilkingSession.evening => Icons.nights_stay_outlined,
            }),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (value) => onChanged(value.first),
      showSelectedIcon: false,
    ),
  );
}

final class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.tertiaryContainer,
    borderRadius: BorderRadius.circular(16),
    child: const Padding(
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.offline_bolt_rounded),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Showing saved device data. New milk entries will remain safely queued until synchronization succeeds.',
            ),
          ),
        ],
      ),
    ),
  );
}

final class _CorrectionValues {
  const _CorrectionValues({
    required this.quantity,
    required this.rejected,
    required this.correctionReason,
    this.rejectionReason,
    this.notes,
  });

  final String quantity;
  final String rejected;
  final String? rejectionReason;
  final String? notes;
  final String correctionReason;
}

final class _CorrectionDialog extends StatefulWidget {
  const _CorrectionDialog({required this.entry});

  final MilkEntry entry;

  @override
  State<_CorrectionDialog> createState() => _CorrectionDialogState();
}

final class _CorrectionDialogState extends State<_CorrectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantity;
  late final TextEditingController _rejected;
  late final TextEditingController _rejectionReason;
  late final TextEditingController _notes;
  final _correctionReason = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantity = TextEditingController(text: widget.entry.quantityLitres);
    _rejected = TextEditingController(
      text: widget.entry.rejectedQuantityLitres,
    );
    _rejectionReason = TextEditingController(
      text: widget.entry.rejectionReason,
    );
    _notes = TextEditingController(text: widget.entry.notes);
  }

  @override
  void dispose() {
    _quantity.dispose();
    _rejected.dispose();
    _rejectionReason.dispose();
    _notes.dispose();
    _correctionReason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Correct ${widget.entry.animalNumber}'),
    content: SizedBox(
      width: 480,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _quantity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Milk litres'),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  return parsed == null || parsed <= 0
                      ? 'Enter a positive quantity.'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rejected,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Rejected litres'),
                validator: (value) {
                  final total = double.tryParse(_quantity.text) ?? 0;
                  final parsed = double.tryParse(value ?? '');
                  return parsed == null || parsed < 0 || parsed > total
                      ? 'Rejected milk must be between 0 and total milk.'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rejectionReason,
                decoration: const InputDecoration(
                  labelText: 'Rejection reason',
                ),
                validator: (value) {
                  final rejected = double.tryParse(_rejected.text) ?? 0;
                  return rejected > 0 && (value ?? '').trim().isEmpty
                      ? 'Explain why milk was rejected.'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correctionReason,
                decoration: const InputDecoration(
                  labelText: 'Why is this correction required?',
                ),
                maxLines: 2,
                validator: (value) => (value ?? '').trim().length < 5
                    ? 'Enter a clear correction reason.'
                    : null,
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            _CorrectionValues(
              quantity: double.parse(_quantity.text).toStringAsFixed(3),
              rejected: double.parse(_rejected.text).toStringAsFixed(3),
              rejectionReason: _rejectionReason.text.trim().isEmpty
                  ? null
                  : _rejectionReason.text.trim(),
              notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
              correctionReason: _correctionReason.text.trim(),
            ),
          );
        },
        child: const Text('Save correction'),
      ),
    ],
  );
}

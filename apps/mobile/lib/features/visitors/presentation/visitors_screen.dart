import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/features/visitors/data/visitor_repository.dart';
import 'package:dairycare_mobile/features/visitors/domain/visitor_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final visitorRepositoryProvider = Provider(
  (ref) => VisitorRepository(ref.watch(apiClientProvider)),
);
final visitorsProvider = FutureProvider<List<VisitorRecord>>(
  (ref) => ref.watch(visitorRepositoryProvider).list(),
);

final class VisitorsScreen extends ConsumerStatefulWidget {
  const VisitorsScreen({super.key});
  @override
  ConsumerState<VisitorsScreen> createState() => _VisitorsScreenState();
}

final class _VisitorsScreenState extends ConsumerState<VisitorsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _purpose = TextEditingController();
  DateTime _visitedAt = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _purpose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canManage =
        ref
            .watch(authControllerProvider)
            .asData
            ?.value
            ?.can('visitors.manage') ??
        false;
    final visitors = ref.watch(visitorsProvider);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(visitorsProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContent(
            maxWidth: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageHeader(
                  eyebrow: 'Farm security',
                  title: 'Visitors',
                  subtitle:
                      'Record every visitor, their arrival date and time, and purpose.',
                ),
                const SizedBox(height: 20),
                if (canManage)
                  SectionCard(
                    title: 'Add visitor',
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(
                              labelText: 'Visitor name *',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Enter visitor name.'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.schedule),
                            title: const Text('Visit date and time'),
                            subtitle: Text(
                              DateFormat.yMMMd().add_jm().format(_visitedAt),
                            ),
                            trailing: const Icon(Icons.edit_calendar),
                            onTap: _chooseDateTime,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _purpose,
                            maxLength: 500,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Purpose of visit *',
                              prefixIcon: Icon(Icons.notes),
                            ),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Enter purpose of visit.'
                                : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: const Text('Save visitor'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (canManage) const SizedBox(height: 20),
                SectionCard(
                  title: 'Visitor history',
                  child: visitors.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) =>
                        Text('Visitor records could not load: $error'),
                    data: (items) => items.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text('No visitors recorded yet.'),
                            ),
                          )
                        : Column(
                            children: [
                              for (final item in items)
                                ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.badge_outlined),
                                  ),
                                  title: Text(item.name),
                                  subtitle: Text(
                                    '${DateFormat.yMMMd().add_jm().format(item.visitedAt)}\n${item.purpose}',
                                  ),
                                  isThreeLine: true,
                                  trailing: canManage
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          tooltip: 'Delete visitor record',
                                          onPressed: () => _delete(item),
                                        )
                                      : null,
                                ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _chooseDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _visitedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_visitedAt),
    );
    if (time == null) return;
    setState(
      () => _visitedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(visitorRepositoryProvider)
          .create(
            name: _name.text.trim(),
            visitedAt: _visitedAt,
            purpose: _purpose.text.trim(),
          );
      _name.clear();
      _purpose.clear();
      _visitedAt = DateTime.now();
      ref.invalidate(visitorsProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Visitor saved.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(VisitorRecord item) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete visitor record?'),
            content: Text('Remove ${item.name} from visitor history?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await ref.read(visitorRepositoryProvider).delete(item.id);
    ref.invalidate(visitorsProvider);
  }
}

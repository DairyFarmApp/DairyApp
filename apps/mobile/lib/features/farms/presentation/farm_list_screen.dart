import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/farms/application/foundation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class FarmListScreen extends ConsumerWidget {
  const FarmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final organizationId = session?.activeOrganizationId;
    final farmId = session?.activeFarmId;
    if (organizationId == null || farmId == null) {
      return const Scaffold(
        body: EmptyStateView(
          title: 'Farm unavailable',
          message: 'Sign in to your farm account first.',
        ),
      );
    }
    final query = (organizationId: organizationId, farmId: farmId);
    final farm = ref.watch(farmProfileProvider(query));
    final canCreate = session?.can('farms.create') ?? false;
    final canUpdate = session?.can('farms.update') ?? false;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(farmProfileProvider(query).future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContent(
            maxWidth: 980,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  eyebrow: 'Organization farm management',
                  title: 'Farm profile',
                  subtitle:
                      'Create and manage farms in your organization. Each farm keeps its own sheds, animals, milk, inventory, employees, and finance records.',
                  actions: [
                    if (canCreate)
                      FilledButton.icon(
                        key: const Key('add_farm_action'),
                        onPressed: farm.asData == null
                            ? null
                            : () => _create(
                                context,
                                ref,
                                farm.requireValue.timezone,
                              ),
                        icon: const Icon(Icons.add_business_rounded),
                        label: const Text('Add farm'),
                      ),
                    if (canUpdate && farm.asData != null)
                      OutlinedButton.icon(
                        key: const Key('edit_farm_action'),
                        onPressed: () =>
                            _edit(context, ref, query, farm.requireValue),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit farm'),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                farm.when(
                  loading: () =>
                      const LoadingStateView(label: 'Loading farm profile...'),
                  error: (error, _) => ErrorStateView(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(farmProfileProvider(query)),
                  ),
                  data: (item) => _FarmDetails(farm: item),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _create(
    BuildContext context,
    WidgetRef ref,
    String defaultTimezone,
  ) async {
    final values = await showDialog<_FarmValues>(
      context: context,
      builder: (_) => _FarmDialog(defaultTimezone: defaultTimezone),
    );
    if (values == null) return;
    try {
      final created = await ref
          .read(foundationRepositoryProvider)
          .createFarm(name: values.name, timezone: values.timezone);
      await ref.read(authControllerProvider.notifier).reload();
      await ref.read(authControllerProvider.notifier).switchFarm(created.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${created.name} created and selected.')),
        );
      }
    } on AppException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    FarmProfileQuery query,
    LocalFarm farm,
  ) async {
    final values = await showDialog<_FarmValues>(
      context: context,
      builder: (_) => _FarmDialog(farm: farm),
    );
    if (values == null) return;
    try {
      await ref
          .read(foundationRepositoryProvider)
          .updateFarm(farm: farm, name: values.name, timezone: values.timezone);
      ref.invalidate(farmProfileProvider(query));
      await ref.read(authControllerProvider.notifier).reload();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Farm profile updated.')));
      }
    } on AppException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}

final class _FarmDetails extends StatelessWidget {
  const _FarmDetails({required this.farm});

  final LocalFarm farm;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionCard(
        title: farm.name,
        subtitle: 'Currently selected farm workspace',
        child: Column(
          children: [
            _DetailRow(
              icon: Icons.schedule_rounded,
              label: 'Timezone',
              value: farm.timezone,
            ),
            const Divider(height: 28),
            const _DetailRow(
              icon: Icons.account_tree_outlined,
              label: 'Hierarchy',
              value: 'Farm → Sheds → Animals',
            ),
            const Divider(height: 28),
            const _DetailRow(
              icon: Icons.verified_user_outlined,
              label: 'Account model',
              value:
                  'The owner and invited family accounts can manage organization farms',
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const SectionCard(
        title: 'How farm organization works',
        child: Text(
          'An organization can contain multiple farms. Create one or more sheds inside each farm. Every active animal belongs to one current farm and shed, while approved movements preserve its location history.',
        ),
      ),
    ],
  );
}

final class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 3),
            Text(value),
          ],
        ),
      ),
    ],
  );
}

final class _FarmDialog extends StatefulWidget {
  const _FarmDialog({this.farm, this.defaultTimezone = 'Asia/Karachi'});

  final LocalFarm? farm;
  final String defaultTimezone;

  @override
  State<_FarmDialog> createState() => _FarmDialogState();
}

final class _FarmDialogState extends State<_FarmDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _timezone;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.farm?.name);
    _timezone = TextEditingController(
      text: widget.farm?.timezone ?? widget.defaultTimezone,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _timezone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.farm == null ? 'Add farm' : 'Edit farm profile'),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('farm_name_field'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Farm name *'),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Farm name is required.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('farm_timezone_field'),
              controller: _timezone,
              decoration: const InputDecoration(
                labelText: 'Timezone *',
                helperText: 'Example: Asia/Karachi',
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Timezone is required.' : null,
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
        key: const Key('save_farm_button'),
        onPressed: () {
          if (!(_formKey.currentState?.validate() ?? false)) return;
          Navigator.pop(
            context,
            _FarmValues(
              name: _name.text.trim(),
              timezone: _timezone.text.trim(),
            ),
          );
        },
        child: Text(widget.farm == null ? 'Create farm' : 'Save'),
      ),
    ],
  );
}

final class _FarmValues {
  const _FarmValues({required this.name, required this.timezone});

  final String name;
  final String timezone;
}

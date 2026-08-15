import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/formatting/pkr.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/commerce/application/commercial_party_providers.dart';
import 'package:dairycare_mobile/features/commerce/domain/commercial_party_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final class CommercialPartiesScreen extends ConsumerStatefulWidget {
  const CommercialPartiesScreen({super.key, required this.kind});
  final String kind;
  @override
  ConsumerState<CommercialPartiesScreen> createState() =>
      _CommercialPartiesScreenState();
}

final class _CommercialPartiesScreenState
    extends ConsumerState<CommercialPartiesScreen> {
  String search = '';
  bool get supplier => widget.kind == 'suppliers';
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final data = ref.watch(commercialPartiesProvider(widget.kind));
    final canManage = session?.can('${widget.kind}.manage') ?? false;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(commercialPartiesProvider(widget.kind).future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  eyebrow: 'Phase 6 • PKR accounts',
                  title: supplier ? 'Suppliers' : 'Customers',
                  subtitle: supplier
                      ? 'Suppliers aur un ka payable record. Add supplier details before making purchase orders.'
                      : 'Customers aur un ka receivable record. Doodh ki sale isi customer account se link hogi.',
                  actions: [
                    if (canManage)
                      FilledButton.icon(
                        key: Key(
                          'add_${supplier ? 'supplier' : 'customer'}_action',
                        ),
                        onPressed: () => _edit(),
                        icon: const Icon(Icons.add),
                        label: Text(supplier ? 'Add supplier' : 'Add customer'),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  key: const Key('commercial_party_search'),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: supplier
                        ? 'Search supplier name or code'
                        : 'Search customer name or code',
                  ),
                  onChanged: (value) =>
                      setState(() => search = value.trim().toLowerCase()),
                ),
                const SizedBox(height: 18),
                data.when(
                  loading: () =>
                      LoadingStateView(label: 'Loading ${widget.kind}...'),
                  error: (e, _) => ErrorStateView(
                    message: e.toString(),
                    onRetry: () =>
                        ref.invalidate(commercialPartiesProvider(widget.kind)),
                  ),
                  data: (items) {
                    final filtered = items
                        .where(
                          (p) =>
                              p.name.toLowerCase().contains(search) ||
                              p.code.toLowerCase().contains(search),
                        )
                        .toList();
                    if (filtered.isEmpty) {
                      return EmptyStateView(
                        title: supplier
                            ? 'No suppliers yet'
                            : 'No customers yet',
                        message: supplier
                            ? 'Pehla supplier add karein.'
                            : 'Pehla customer add karein.',
                        icon: supplier
                            ? Icons.local_shipping_outlined
                            : Icons.people_outline,
                      );
                    }
                    return _PartyList(
                      kind: widget.kind,
                      items: filtered,
                      canManage: canManage,
                      onEdit: _edit,
                      onArchive: _archive,
                      onLedger: _ledger,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _edit([CommercialParty? party]) async {
    final farmId = ref.read(authControllerProvider).asData?.value?.activeFarmId;
    if (farmId == null) return;
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) =>
          _PartyDialog(supplier: supplier, party: party, farmId: farmId),
    );
    if (payload == null || !mounted) return;
    try {
      final repo = ref.read(commercialPartyRepositoryProvider);
      if (party == null) {
        await repo.create(widget.kind, payload);
      } else {
        await repo.update(widget.kind, party, payload);
      }
      ref.invalidate(commercialPartiesProvider(widget.kind));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(party == null ? 'Record added.' : 'Record updated.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _archive(CommercialParty party) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Delete ${supplier ? 'supplier' : 'customer'}?'),
        content: Text(
          '${party.name} active lists se remove ho ga. Purana ledger record save rahe ga.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref
        .read(commercialPartyRepositoryProvider)
        .archive(widget.kind, party.id);
    ref.invalidate(commercialPartiesProvider(widget.kind));
  }

  void _ledger(CommercialParty party) => showDialog<void>(
    context: context,
    builder: (_) => _LedgerDialog(kind: widget.kind, party: party),
  );
}

final class _PartyList extends StatelessWidget {
  const _PartyList({
    required this.kind,
    required this.items,
    required this.canManage,
    required this.onEdit,
    required this.onArchive,
    required this.onLedger,
  });
  final String kind;
  final List<CommercialParty> items;
  final bool canManage;
  final ValueChanged<CommercialParty> onEdit, onArchive, onLedger;
  @override
  Widget build(BuildContext context) => SectionCard(
    title: '${items.length} active $kind',
    subtitle: 'Amounts are stored and displayed in Pakistani Rupees (PKR).',
    child: Column(
      children: [
        for (final p in items) ...[
          ListTile(
            key: ValueKey('party-${p.id}'),
            leading: CircleAvatar(child: Text(p.code.split('-').last)),
            title: Text(p.name),
            subtitle: Text(
              '${p.code} • ${_label(p.type)}\nBalance: ${formatPkr(p.currentBalance)}${p.phone == null ? '' : ' • ${p.phone}'}',
            ),
            isThreeLine: true,
            onTap: () => onLedger(p),
            trailing: PopupMenuButton<String>(
              onSelected: (v) => v == 'ledger'
                  ? onLedger(p)
                  : v == 'edit'
                  ? onEdit(p)
                  : onArchive(p),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'ledger',
                  child: Text('View ledger'),
                ),
                if (canManage)
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (canManage)
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
          if (p != items.last) const Divider(),
        ],
      ],
    ),
  );
  String _label(String value) => value
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

final class _LedgerDialog extends ConsumerWidget {
  const _LedgerDialog({required this.kind, required this.party});
  final String kind;
  final CommercialParty party;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(
      commercialLedgerProvider((kind: kind, id: party.id)),
    );
    return AlertDialog(
      title: Text('${party.name} ledger'),
      content: SizedBox(
        width: 600,
        height: 360,
        child: entries.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(e.toString()),
          data: (rows) => rows.isEmpty
              ? const EmptyStateView(message: 'No ledger entries yet.')
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (_, i) {
                    final row = rows[i];
                    return ListTile(
                      title: Text(row.description),
                      subtitle: Text(
                        DateFormat.yMMMd().add_jm().format(
                          row.occurredAt.toLocal(),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Balance ${formatPkr(row.balanceAfter)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Dr ${formatPkr(row.debit)} • Cr ${formatPkr(row.credit)}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

final class _PartyDialog extends StatefulWidget {
  const _PartyDialog({
    required this.supplier,
    required this.farmId,
    this.party,
  });
  final bool supplier;
  final String farmId;
  final CommercialParty? party;
  @override
  State<_PartyDialog> createState() => _PartyDialogState();
}

final class _PartyDialogState extends State<_PartyDialog> {
  final key = GlobalKey<FormState>();
  late String name,
      type,
      phone,
      email,
      address,
      delivery,
      contact,
      route,
      credit,
      opening,
      rate,
      terms,
      notes;
  bool quality = false;
  @override
  void initState() {
    super.initState();
    final p = widget.party;
    name = p?.name ?? '';
    type = p?.type ?? 'individual';
    phone = p?.phone ?? '';
    email = p?.email ?? '';
    address = p?.address ?? '';
    delivery = p?.deliveryAddress ?? '';
    contact = p?.contactPerson ?? '';
    route = p?.routeName ?? '';
    credit = p?.creditLimit ?? '0';
    opening = p?.openingBalance ?? '0';
    rate = p?.defaultMilkRate ?? '';
    terms = '${p?.paymentTermsDays ?? 0}';
    notes = p?.notes ?? '';
    quality = p?.qualityBasedPricing ?? false;
  }

  String? money(String? v) {
    final n = double.tryParse((v ?? '').trim());
    return n == null || n < 0 ? 'Enter digits only, for example 25000.' : null;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      '${widget.party == null ? 'Add' : 'Edit'} ${widget.supplier ? 'supplier' : 'customer'}',
    ),
    content: SizedBox(
      width: 620,
      child: Form(
        key: key,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('party_name_field'),
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Name is required.' : null,
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 12),
              if (!widget.supplier)
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(
                    labelText: 'Customer type *',
                  ),
                  items:
                      const [
                            'individual',
                            'shop',
                            'distributor',
                            'milk_collection_company',
                            'factory',
                            'institution',
                          ]
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text(v.replaceAll('_', ' ')),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => type = v!,
                ),
              if (widget.supplier)
                TextFormField(
                  initialValue: contact,
                  decoration: const InputDecoration(
                    labelText: 'Contact person',
                  ),
                  onChanged: (v) => contact = v,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => phone = v,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => email = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: address,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
                onChanged: (v) => address = v,
              ),
              if (!widget.supplier) ...[
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: delivery,
                  decoration: const InputDecoration(
                    labelText: 'Delivery address',
                  ),
                  maxLines: 2,
                  onChanged: (v) => delivery = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: route,
                  decoration: const InputDecoration(
                    labelText: 'Delivery route',
                  ),
                  onChanged: (v) => route = v,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: credit,
                      decoration: const InputDecoration(
                        labelText: 'Credit limit (PKR)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: money,
                      onChanged: (v) => credit = v,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: terms,
                      decoration: const InputDecoration(
                        labelText: 'Payment terms (days)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? '') == null
                          ? 'Enter days in digits.'
                          : null,
                      onChanged: (v) => terms = v,
                    ),
                  ),
                ],
              ),
              if (widget.party == null) ...[
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: opening,
                  decoration: const InputDecoration(
                    labelText: 'Opening balance (PKR)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: money,
                  onChanged: (v) => opening = v,
                ),
              ],
              if (!widget.supplier) ...[
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: rate,
                  decoration: const InputDecoration(
                    labelText: 'Default milk rate (PKR, optional)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) => (v ?? '').trim().isEmpty ? null : money(v),
                  onChanged: (v) => rate = v,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Quality-based milk pricing'),
                  subtitle: const Text(
                    'Fat/SNF quality ke hisaab se rate adjust ho ga.',
                  ),
                  value: quality,
                  onChanged: (v) => setState(() => quality = v),
                ),
              ],
              TextFormField(
                initialValue: notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
                onChanged: (v) => notes = v,
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
        key: const Key('save_party_action'),
        onPressed: () {
          if (!key.currentState!.validate()) return;
          Navigator.pop(context, {
            'farm_id': widget.farmId,
            'name': name.trim(),
            'phone': phone.trim().isEmpty ? null : phone.trim(),
            'email': email.trim().isEmpty ? null : email.trim(),
            'address': address.trim().isEmpty ? null : address.trim(),
            'credit_limit': credit.trim(),
            'payment_terms_days': int.parse(terms),
            if (widget.party == null) 'opening_balance': opening.trim(),
            'notes': notes.trim().isEmpty ? null : notes.trim(),
            if (widget.supplier)
              'contact_person': contact.trim().isEmpty ? null : contact.trim(),
            if (!widget.supplier) ...{
              'customer_type': type,
              'delivery_address': delivery.trim().isEmpty
                  ? null
                  : delivery.trim(),
              'route_name': route.trim().isEmpty ? null : route.trim(),
              'default_milk_rate': rate.trim().isEmpty ? null : rate.trim(),
              'quality_based_pricing': quality,
            },
          });
        },
        child: const Text('Save'),
      ),
    ],
  );
}

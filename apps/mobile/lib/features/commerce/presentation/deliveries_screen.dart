import 'package:dairycare_mobile/features/commerce/application/commercial_party_providers.dart';
import 'package:dairycare_mobile/features/commerce/domain/delivery_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/formatting/pkr.dart';
import 'package:dairycare_mobile/core/files/export_file_saver.dart';

final class DeliveriesScreen extends ConsumerWidget {
  const DeliveriesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Milk Deliveries')),
    body: ref
        .watch(deliveriesProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Could not load deliveries: $e'),
                FilledButton(
                  onPressed: () => ref.invalidate(deliveriesProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
          data: (data) => RefreshIndicator(
            onRefresh: () => ref.refresh(deliveriesProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _route(context, ref),
                      icon: const Icon(Icons.route),
                      label: const Text('Add Route'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _vehicle(context, ref),
                      icon: const Icon(Icons.local_shipping_outlined),
                      label: const Text('Add Vehicle'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _driver(context, ref),
                      icon: const Icon(Icons.badge_outlined),
                      label: const Text('Add Driver'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed:
                          data.routes.isEmpty ||
                              data.vehicles.isEmpty ||
                              data.drivers.isEmpty ||
                              data.sales.isEmpty
                          ? null
                          : () => _manifest(context, ref, data),
                      icon: const Icon(Icons.add_task),
                      label: const Text('Plan Delivery'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (data.manifests.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No deliveries yet. Add a route, vehicle and driver, then plan a delivery.\nAbhi koi delivery nahin hai.',
                      ),
                    ),
                  ),
                ...data.manifests.map(
                  (m) => Card(
                    child: ExpansionTile(
                      leading: IconButton(
                        onPressed: () => _deliveryNote(context, ref, m),
                        tooltip: 'Save delivery note PDF',
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                      ),
                      title: Text(
                        '${m.number} • ${m.status.replaceAll('_', ' ')}',
                      ),
                      subtitle: Text(
                        '${m.route.name} • ${m.vehicle.registration} • ${m.driver.name}\nPlanned: ${m.planned} L',
                      ),
                      trailing: m.status == 'scheduled'
                          ? FilledButton(
                              onPressed: () => _dispatch(context, ref, m),
                              child: const Text('Dispatch'),
                            )
                          : null,
                      children: m.stops
                          .map(
                            (s) => ListTile(
                              title: Text(s.customer.name),
                              subtitle: Text(
                                '${s.planned} L • ${s.status.replaceAll('_', ' ')}${s.hasProof ? ' • Proof saved' : ''}',
                              ),
                              trailing: Wrap(
                                spacing: 6,
                                children: [
                                  if (m.status == 'dispatched' &&
                                      s.status == 'dispatched')
                                    FilledButton.tonal(
                                      onPressed: () =>
                                          _complete(context, ref, m, s),
                                      child: const Text('Complete'),
                                    ),
                                  if ((ref
                                              .watch(authControllerProvider)
                                              .asData
                                              ?.value
                                              ?.can(
                                                'customer_refunds.manage',
                                              ) ??
                                          false) &&
                                      double.parse(s.refundDue) >
                                          double.parse(s.refundedAmount))
                                    OutlinedButton(
                                      onPressed: () =>
                                          _refund(context, ref, m, s),
                                      child: const Text('Refund'),
                                    ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _export(context, ref),
                  icon: const Icon(Icons.table_view_outlined),
                  label: const Text('Export history'),
                ),
              ],
            ),
          ),
        ),
  );

  Future<void> _route(BuildContext c, WidgetRef ref) async {
    final customers = await ref.read(
      commercialPartiesProvider('customers').future,
    );
    if (!c.mounted) return;
    final name = TextEditingController();
    final selected = <String>{};
    await showDialog<void>(
      context: c,
      builder: (d) => StatefulBuilder(
        builder: (d, set) => AlertDialog(
          title: const Text('Add delivery route'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Route name *'),
                ),
                const SizedBox(height: 12),
                ...customers.map(
                  (x) => CheckboxListTile(
                    value: selected.contains(x.id),
                    title: Text(x.name),
                    subtitle: const Text('Delivery stop'),
                    onChanged: (v) => set(
                      () => v! ? selected.add(x.id) : selected.remove(x.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: name.text.trim().isEmpty || selected.isEmpty
                  ? null
                  : () async {
                      await ref.read(deliveryRepositoryProvider).createRoute({
                        'name': name.text.trim(),
                        'stops': selected
                            .map((id) => {'customer_id': id})
                            .toList(),
                      });
                      ref.invalidate(deliveriesProvider);
                      if (d.mounted) Navigator.pop(d);
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _vehicle(BuildContext c, WidgetRef ref) async {
    final reg = TextEditingController(), cap = TextEditingController();
    await _simple(
      c,
      'Add vehicle',
      [
        TextField(
          controller: reg,
          decoration: const InputDecoration(labelText: 'Registration number *'),
        ),
        TextField(
          controller: cap,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Capacity (litres) *'),
        ),
      ],
      () async {
        if (reg.text.trim().isEmpty || (double.tryParse(cap.text) ?? 0) <= 0) {
          return false;
        }
        await ref.read(deliveryRepositoryProvider).createVehicle({
          'registration_number': reg.text.trim(),
          'capacity_litres': cap.text,
        });
        ref.invalidate(deliveriesProvider);
        return true;
      },
    );
  }

  Future<void> _driver(BuildContext c, WidgetRef ref) async {
    final name = TextEditingController(),
        phone = TextEditingController(),
        license = TextEditingController();
    await _simple(
      c,
      'Add driver',
      [
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Name *'),
        ),
        TextField(
          controller: phone,
          decoration: const InputDecoration(labelText: 'Phone'),
        ),
        TextField(
          controller: license,
          decoration: const InputDecoration(labelText: 'License number'),
        ),
      ],
      () async {
        if (name.text.trim().isEmpty) return false;
        await ref.read(deliveryRepositoryProvider).createDriver({
          'name': name.text.trim(),
          'phone': phone.text.trim(),
          'license_number': license.text.trim(),
        });
        ref.invalidate(deliveriesProvider);
        return true;
      },
    );
  }

  Future<void> _manifest(
    BuildContext c,
    WidgetRef ref,
    DeliveryOverview o,
  ) async {
    var route = o.routes.first.id,
        vehicle = o.vehicles.first.id,
        driver = o.drivers.first.id;
    final sales = <String>{};
    await showDialog<void>(
      context: c,
      builder: (d) => StatefulBuilder(
        builder: (d, set) => AlertDialog(
          title: const Text('Plan milk delivery'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField(
                  initialValue: route,
                  decoration: const InputDecoration(labelText: 'Route'),
                  items: o.routes
                      .map(
                        (x) =>
                            DropdownMenuItem(value: x.id, child: Text(x.name)),
                      )
                      .toList(),
                  onChanged: (v) => set(() => route = v!),
                ),
                DropdownButtonFormField(
                  initialValue: vehicle,
                  decoration: const InputDecoration(labelText: 'Vehicle'),
                  items: o.vehicles
                      .map(
                        (x) => DropdownMenuItem(
                          value: x.id,
                          child: Text('${x.registration} (${x.capacity} L)'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => set(() => vehicle = v!),
                ),
                DropdownButtonFormField(
                  initialValue: driver,
                  decoration: const InputDecoration(labelText: 'Driver'),
                  items: o.drivers
                      .map(
                        (x) =>
                            DropdownMenuItem(value: x.id, child: Text(x.name)),
                      )
                      .toList(),
                  onChanged: (v) => set(() => driver = v!),
                ),
                ...o.sales.map(
                  (x) => CheckboxListTile(
                    value: sales.contains(x.id),
                    title: Text('${x.number} • ${x.customer.name}'),
                    subtitle: Text('${x.quantity} L'),
                    onChanged: (v) =>
                        set(() => v! ? sales.add(x.id) : sales.remove(x.id)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: sales.isEmpty
                  ? null
                  : () async {
                      await ref
                          .read(deliveryRepositoryProvider)
                          .createManifest({
                            'delivery_route_id': route,
                            'delivery_vehicle_id': vehicle,
                            'delivery_driver_id': driver,
                            'delivery_date': DateTime.now()
                                .toIso8601String()
                                .split('T')
                                .first,
                            'milk_sale_ids': sales.toList(),
                          });
                      ref.invalidate(deliveriesProvider);
                      if (d.mounted) Navigator.pop(d);
                    },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dispatch(
    BuildContext c,
    WidgetRef ref,
    DeliveryManifest m,
  ) async {
    final q = TextEditingController(text: m.planned);
    await _simple(
      c,
      'Dispatch ${m.number}',
      [
        TextField(
          controller: q,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Loaded milk (litres) *',
          ),
        ),
      ],
      () async {
        final v = double.tryParse(q.text);
        if (v == null || v <= 0 || v > double.parse(m.planned)) return false;
        await ref.read(deliveryRepositoryProvider).dispatch(m.id, q.text);
        ref.invalidate(deliveriesProvider);
        return true;
      },
    );
  }

  Future<void> _complete(
    BuildContext c,
    WidgetRef ref,
    DeliveryManifest m,
    ManifestStop s,
  ) async {
    final delivered = TextEditingController(text: s.planned),
        returned = TextEditingController(text: '0'),
        rejected = TextEditingController(text: '0'),
        restocked = TextEditingController(text: '0'),
        reason = TextEditingController(),
        ack = TextEditingController(),
        latitude = TextEditingController(),
        longitude = TextEditingController();
    XFile? proof;
    await _simple(
      c,
      'Complete stop: ${s.customer.name}',
      [
        Text('Planned quantity: ${s.planned} L'),
        TextField(
          controller: delivered,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Delivered L *'),
        ),
        TextField(
          controller: returned,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Returned L *'),
        ),
        TextField(
          controller: rejected,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Rejected L *'),
        ),
        TextField(
          controller: restocked,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Reusable returned milk added back to stock L',
          ),
        ),
        TextField(
          controller: reason,
          decoration: const InputDecoration(
            labelText: 'Return/rejection reason',
          ),
        ),
        TextField(
          controller: ack,
          decoration: const InputDecoration(
            labelText: 'Received / acknowledged by',
          ),
        ),
        TextField(
          controller: latitude,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'GPS latitude (optional)',
          ),
        ),
        TextField(
          controller: longitude,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'GPS longitude (optional)',
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            proof = await openFile(
              acceptedTypeGroups: const [
                XTypeGroup(
                  label: 'Proof image',
                  extensions: ['jpg', 'jpeg', 'png', 'webp'],
                ),
              ],
            );
          },
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Select proof image (optional)'),
        ),
      ],
      () async {
        final a = double.tryParse(delivered.text) ?? -1,
            b = double.tryParse(returned.text) ?? -1,
            x = double.tryParse(rejected.text) ?? -1,
            rs = double.tryParse(restocked.text) ?? -1;
        if (a < 0 ||
            b < 0 ||
            x < 0 ||
            rs < 0 ||
            rs > b ||
            (b + x > 0 && reason.text.trim().isEmpty) ||
            ((a + b + x) - double.parse(s.planned)).abs() > .001) {
          return false;
        }
        final lat = latitude.text.trim().isEmpty
            ? null
            : double.tryParse(latitude.text);
        final lng = longitude.text.trim().isEmpty
            ? null
            : double.tryParse(longitude.text);
        if ((latitude.text.trim().isNotEmpty && lat == null) ||
            (longitude.text.trim().isNotEmpty && lng == null)) {
          return false;
        }
        final status = a == 0
            ? 'failed'
            : (a == double.parse(s.planned)
                  ? 'delivered'
                  : 'partially_delivered');
        await ref.read(deliveryRepositoryProvider).completeStop(m.id, s.id, {
          'status': status,
          'delivered_quantity': '$a',
          'returned_quantity': '$b',
          'rejected_quantity': '$x',
          'restocked_quantity': '$rs',
          'return_reason': reason.text.trim(),
          'acknowledged_by': ack.text.trim(),
          'gps_latitude': ?lat,
          'gps_longitude': ?lng,
        });
        if (proof != null) {
          await ref
              .read(deliveryRepositoryProvider)
              .uploadProof(m.id, s.id, await proof!.readAsBytes(), proof!.name);
        }
        ref.invalidate(deliveriesProvider);
        return true;
      },
    );
  }

  Future<void> _refund(
    BuildContext c,
    WidgetRef ref,
    DeliveryManifest m,
    ManifestStop s,
  ) async {
    final remaining =
        double.parse(s.refundDue) - double.parse(s.refundedAmount);
    final amount = TextEditingController(text: remaining.toStringAsFixed(2));
    String method = 'cash';
    await showDialog<void>(
      context: c,
      builder: (d) => StatefulBuilder(
        builder: (d, set) => AlertDialog(
          title: const Text('Record customer refund'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Outstanding refund: ${formatPkr(remaining)}'),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Refund amount PKR *',
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration: const InputDecoration(
                    labelText: 'Payment method *',
                  ),
                  items:
                      const [
                            'cash',
                            'bank_transfer',
                            'cheque',
                            'mobile_wallet',
                            'other',
                          ]
                          .map(
                            (x) => DropdownMenuItem(
                              value: x,
                              child: Text(x.replaceAll('_', ' ')),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => set(() => method = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final value = double.tryParse(amount.text);
                if (value == null || value <= 0 || value > remaining + .001) {
                  return;
                }
                final repo = ref.read(deliveryRepositoryProvider);
                final refundId = await repo.refund(m.id, s.id, {
                  'amount': value.toStringAsFixed(2),
                  'refund_date': DateTime.now()
                      .toIso8601String()
                      .split('T')
                      .first,
                  'payment_method': method,
                });
                final bytes = await repo.refundReceipt(refundId);
                await const ExportFileSaver().save(
                  bytes: bytes,
                  filename: 'customer-refund-$refundId.pdf',
                  mimeType: 'application/pdf',
                );
                ref.invalidate(deliveriesProvider);
                if (d.mounted) Navigator.pop(d);
              },
              child: const Text('Record & save receipt'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deliveryNote(
    BuildContext c,
    WidgetRef ref,
    DeliveryManifest m,
  ) async {
    try {
      final bytes = await ref
          .read(deliveryRepositoryProvider)
          .deliveryNote(m.id);
      await const ExportFileSaver().save(
        bytes: bytes,
        filename: '${m.number}-delivery-note.pdf',
        mimeType: 'application/pdf',
      );
    } catch (e) {
      if (c.mounted) {
        ScaffoldMessenger.of(
          c,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _export(BuildContext c, WidgetRef ref) async {
    DateTime? from, to;
    String status = 'all';
    await showDialog<void>(
      context: c,
      builder: (d) => StatefulBuilder(
        builder: (d, set) => AlertDialog(
          title: const Text('Export delivery history'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(
                    labelText: 'Delivery status',
                  ),
                  items:
                      const [
                            'all',
                            'scheduled',
                            'dispatched',
                            'delivered',
                            'partially_delivered',
                            'failed',
                            'returned',
                          ]
                          .map(
                            (x) => DropdownMenuItem(
                              value: x,
                              child: Text(x.replaceAll('_', ' ')),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => set(() => status = v!),
                ),
                ListTile(
                  title: Text(
                    from == null
                        ? 'From beginning'
                        : 'From ${from!.toIso8601String().split('T').first}',
                  ),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final x = await showDatePicker(
                      context: d,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDate: from ?? DateTime.now(),
                    );
                    if (x != null) set(() => from = x);
                  },
                ),
                ListTile(
                  title: Text(
                    to == null
                        ? 'To today'
                        : 'To ${to!.toIso8601String().split('T').first}',
                  ),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final x = await showDatePicker(
                      context: d,
                      firstDate: from ?? DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDate: to ?? DateTime.now(),
                    );
                    if (x != null) set(() => to = x);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () async {
                if (from != null && to != null && to!.isBefore(from!)) return;
                final bytes = await ref
                    .read(deliveryRepositoryProvider)
                    .export(from: from, to: to, status: status);
                await const ExportFileSaver().save(
                  bytes: bytes,
                  filename: 'dairycare-delivery-history.xlsx',
                  mimeType:
                      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                );
                if (d.mounted) Navigator.pop(d);
              },
              icon: const Icon(Icons.download),
              label: const Text('Save Excel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simple(
    BuildContext c,
    String title,
    List<Widget> fields,
    Future<bool> Function() save,
  ) => showDialog<void>(
    context: c,
    builder: (d) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: fields
              .map(
                (x) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: x,
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (await save() && d.mounted) Navigator.pop(d);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

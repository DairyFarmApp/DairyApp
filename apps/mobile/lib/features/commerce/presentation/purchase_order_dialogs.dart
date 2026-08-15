import 'package:dairycare_mobile/features/commerce/domain/commercial_party_models.dart';
import 'package:dairycare_mobile/features/commerce/domain/purchase_models.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final class PurchaseOrderDialog extends StatefulWidget {
  const PurchaseOrderDialog({
    super.key,
    required this.suppliers,
    required this.items,
    required this.farmId,
  });
  final List<CommercialParty> suppliers;
  final List<InventoryItem> items;
  final String farmId;
  @override
  State<PurchaseOrderDialog> createState() => _PurchaseOrderDialogState();
}

final class _Line {
  String? itemId;
  String quantity = '', rate = '';
}

final class _PurchaseOrderDialogState extends State<PurchaseOrderDialog> {
  final form = GlobalKey<FormState>();
  final lines = [_Line()];
  String? supplier;
  String discount = '0', tax = '0', transport = '0', other = '0';
  String? money(String? v) {
    final n = double.tryParse(v ?? '');
    return n == null || n < 0 ? 'Enter digits only.' : null;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('New purchase order'),
    content: SizedBox(
      width: 760,
      height: 540,
      child: Form(
        key: form,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              key: const Key('purchase_supplier_field'),
              decoration: const InputDecoration(labelText: 'Supplier *'),
              items: widget.suppliers
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text('${s.code} - ${s.name}'),
                    ),
                  )
                  .toList(),
              validator: (v) => v == null ? 'Choose supplier.' : null,
              onChanged: (v) => supplier = v,
            ),
            ...lines.indexed.map(
              (e) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Inventory item *',
                        ),
                        items: widget.items
                            .map(
                              (i) => DropdownMenuItem(
                                value: i.id,
                                child: Text('${i.name} (${i.unit})'),
                              ),
                            )
                            .toList(),
                        validator: (v) => v == null ? 'Choose item.' : null,
                        onChanged: (v) => e.$2.itemId = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                            ? 'Required'
                            : null,
                        onChanged: (v) => e.$2.quantity = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Rate PKR *',
                        ),
                        keyboardType: TextInputType.number,
                        validator: money,
                        onChanged: (v) => e.$2.rate = v,
                      ),
                    ),
                    if (lines.length > 1)
                      IconButton(
                        onPressed: () => setState(() => lines.removeAt(e.$1)),
                        icon: const Icon(Icons.delete_outline),
                      ),
                  ],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => lines.add(_Line())),
              icon: const Icon(Icons.add),
              label: const Text('Add another item'),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final x in [
                  ('Discount PKR', (String v) => discount = v),
                  ('Tax PKR', (String v) => tax = v),
                  ('Transport PKR', (String v) => transport = v),
                  ('Other cost PKR', (String v) => other = v),
                ])
                  SizedBox(
                    width: 155,
                    child: TextFormField(
                      initialValue: '0',
                      decoration: InputDecoration(labelText: x.$1),
                      keyboardType: TextInputType.number,
                      validator: money,
                      onChanged: x.$2,
                    ),
                  ),
              ],
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
        key: const Key('save_purchase_order_action'),
        onPressed: () {
          if (!form.currentState!.validate()) return;
          Navigator.pop(context, {
            'farm_id': widget.farmId,
            'supplier_id': supplier,
            'purchase_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
            'discount': discount,
            'tax': tax,
            'transport_cost': transport,
            'other_cost': other,
            'items': lines
                .map(
                  (l) => {
                    'inventory_item_id': l.itemId,
                    'quantity': l.quantity,
                    'unit_rate': l.rate,
                  },
                )
                .toList(),
          });
        },
        child: const Text('Create draft'),
      ),
    ],
  );
}

final class GoodsReceiptDialog extends StatefulWidget {
  const GoodsReceiptDialog({super.key, required this.order});
  final PurchaseOrder order;
  @override
  State<GoodsReceiptDialog> createState() => _GoodsReceiptDialogState();
}

final class _ReceiptLine {
  _ReceiptLine(this.line) : quantity = line.remaining.toStringAsFixed(3);
  final PurchaseOrderLine line;
  String quantity, batch = '', expiry = '';
}

final class _GoodsReceiptDialogState extends State<GoodsReceiptDialog> {
  final form = GlobalKey<FormState>();
  late final List<_ReceiptLine> lines;
  String quality = 'accepted';
  @override
  void initState() {
    super.initState();
    lines = widget.order.lines
        .where((l) => l.remaining > 0)
        .map(_ReceiptLine.new)
        .toList();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Receive ${widget.order.number}'),
    content: SizedBox(
      width: 720,
      height: 500,
      child: Form(
        key: form,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              initialValue: quality,
              decoration: const InputDecoration(
                labelText: 'Quality inspection',
              ),
              items: const [
                DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                DropdownMenuItem(
                  value: 'conditionally_accepted',
                  child: Text('Conditionally accepted'),
                ),
              ],
              onChanged: (v) => quality = v!,
            ),
            const Text('Rejected maal inventory mein add nahi hota.'),
            ...lines.map(
              (r) => Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${r.line.itemName} - ${r.line.remaining.toStringAsFixed(3)} ${r.line.unit} remaining',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: r.quantity,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                            ),
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              return n == null || n <= 0 || n > r.line.remaining
                                  ? 'Invalid quantity'
                                  : null;
                            },
                            onChanged: (v) => r.quantity = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Batch number',
                            ),
                            validator: (v) =>
                                (v ?? '').trim().isEmpty ? 'Required' : null,
                            onChanged: (v) => r.batch = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Expiry YYYY-MM-DD',
                            ),
                            validator: (v) =>
                                (v ?? '').isNotEmpty &&
                                    DateTime.tryParse(v!) == null
                                ? 'Use YYYY-MM-DD'
                                : null,
                            onChanged: (v) => r.expiry = v,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
        key: const Key('confirm_goods_receipt_action'),
        onPressed: () {
          if (!form.currentState!.validate()) return;
          Navigator.pop(context, {
            'quality_status': quality,
            'items': lines
                .map(
                  (r) => {
                    'purchase_order_item_id': r.line.id,
                    'batch_number': r.batch.trim(),
                    'expiry_date': r.expiry.trim().isEmpty
                        ? null
                        : r.expiry.trim(),
                    'quantity': r.quantity,
                  },
                )
                .toList(),
          });
        },
        child: const Text('Receive into inventory'),
      ),
    ],
  );
}

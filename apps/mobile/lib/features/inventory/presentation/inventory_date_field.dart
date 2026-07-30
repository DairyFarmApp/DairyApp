import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final class InventoryDateField extends StatefulWidget {
  const InventoryDateField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<InventoryDateField> createState() => _InventoryDateFieldState();
}

class _InventoryDateFieldState extends State<InventoryDateField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant InventoryDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    readOnly: true,
    validator: widget.validator,
    onTap: () => _pick(context),
    decoration: InputDecoration(
      labelText: widget.label,
      hintText: 'Select date',
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear date',
              onPressed: () {
                widget.controller.clear();
                widget.onChanged?.call('');
              },
              icon: const Icon(Icons.close_rounded),
            ),
          IconButton(
            tooltip: 'Open calendar',
            onPressed: () => _pick(context),
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
    ),
  );

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final parsed = DateTime.tryParse(widget.controller.text);
    final first = widget.firstDate ?? DateTime(2000);
    final last = widget.lastDate ?? DateTime(now.year + 20, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: _clamp(parsed ?? now, first, last),
      firstDate: first,
      lastDate: last,
      helpText: widget.label,
    );
    if (selected == null) return;
    final value = DateFormat('yyyy-MM-dd').format(selected);
    widget.controller.text = value;
    widget.onChanged?.call(value);
  }
}

DateTime _clamp(DateTime value, DateTime first, DateTime last) {
  if (value.isBefore(first)) return first;
  if (value.isAfter(last)) return last;
  return value;
}

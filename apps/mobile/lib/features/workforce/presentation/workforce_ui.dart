import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _pkr = NumberFormat.currency(
  locale: 'en_PK',
  symbol: 'PKR ',
  decimalDigits: 2,
);

String pkr(String value) => _pkr.format(double.tryParse(value) ?? 0);

String shortDate(DateTime value) => DateFormat('dd MMM yyyy').format(value);

Widget metricGrid(List<Widget> cards) => LayoutBuilder(
  builder: (context, constraints) {
    final columns = constraints.maxWidth >= 1050
        ? 4
        : constraints.maxWidth >= 620
        ? 2
        : 1;
    final width = (constraints.maxWidth - ((columns - 1) * 14)) / columns;
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        for (final card in cards)
          SizedBox(width: width, height: 250, child: card),
      ],
    );
  },
);

Widget emptyPanel(String title, String message, IconData icon) => GlassSurface(
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 38),
    child: Column(
      children: [
        Icon(icon, size: 46),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 7),
        Text(message, textAlign: TextAlign.center),
      ],
    ),
  ),
);

InputDecoration fieldDecoration(String label, {IconData? icon}) =>
    InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
    );

Future<DateTime?> pickDate(BuildContext context, DateTime initial) =>
    showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

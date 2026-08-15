import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final NumberFormat _pkr = NumberFormat.currency(
  locale: 'en_PK',
  name: 'PKR',
  symbol: 'PKR ',
  decimalDigits: 2,
);

String formatPkr(Object? value) {
  final amount = value is num ? value : num.tryParse(value?.toString() ?? '');
  return _pkr.format(amount ?? 0);
}

final List<TextInputFormatter> pkrInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,12}(?:\.\d{0,2})?')),
];

String? validatePkrAmount(
  String? value, {
  bool allowZero = true,
  bool required = false,
}) {
  final input = value?.trim() ?? '';
  if (input.isEmpty && !required) return null;
  if (!RegExp(r'^\d{1,12}(?:\.\d{1,2})?$').hasMatch(input)) {
    return 'Enter a valid PKR amount using digits only.';
  }
  final amount = num.parse(input);
  if (amount < 0 || (!allowZero && amount == 0)) {
    return allowZero
        ? 'Amount cannot be negative.'
        : 'Amount must be above zero.';
  }
  return null;
}

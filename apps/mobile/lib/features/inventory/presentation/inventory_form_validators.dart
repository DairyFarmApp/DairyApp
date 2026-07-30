String? validateInventoryDecimal(
  String? value, {
  required bool required,
  required int decimalPlaces,
  bool positive = false,
}) {
  final input = value?.trim() ?? '';
  if (input.isEmpty) return required ? 'Required' : null;
  final decimal = RegExp('^\\d{1,14}(?:\\.\\d{1,$decimalPlaces})?\$');
  if (!decimal.hasMatch(input)) {
    return 'Enter a valid number with up to $decimalPlaces decimals';
  }
  if (positive && double.parse(input) <= 0) {
    return 'Must be greater than zero';
  }
  return null;
}

String? validateInventoryDate(String? value) {
  final input = value?.trim() ?? '';
  if (input.isEmpty) return null;
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input)) {
    return 'Use YYYY-MM-DD';
  }
  final date = DateTime.tryParse(input);
  if (date == null || date.toIso8601String().split('T').first != input) {
    return 'Enter a valid date';
  }
  return null;
}

String? validateInventoryExpiry(String? value, String purchaseValue) {
  final ownError = validateInventoryDate(value);
  if (ownError != null) return ownError;
  final expiry = _parseInventoryDate(value);
  final purchase = _parseInventoryDate(purchaseValue);
  if (expiry != null && purchase != null && expiry.isBefore(purchase)) {
    return 'Must be on or after purchase date';
  }
  return null;
}

String? validateMaximumStock(String? value, String minimumValue) {
  final ownError = validateInventoryDecimal(
    value,
    required: false,
    decimalPlaces: 3,
  );
  if (ownError != null) return ownError;
  final maximum = double.tryParse(value?.trim() ?? '');
  final minimum = double.tryParse(minimumValue.trim());
  if (maximum != null && minimum != null && maximum < minimum) {
    return 'Must be at least minimum stock';
  }
  return null;
}

DateTime? _parseInventoryDate(String? value) {
  if (validateInventoryDate(value) != null) return null;
  final input = value?.trim() ?? '';
  return input.isEmpty ? null : DateTime.parse(input);
}

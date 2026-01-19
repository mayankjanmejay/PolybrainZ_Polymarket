// JSON parsing helpers for handling API inconsistencies.
// The Polymarket Gamma API sometimes returns numeric values as strings.
// These helpers handle flexible type parsing.

/// Parse a value that could be String, int, or num to int (non-nullable).
/// Returns 0 if parsing fails or value is null.
int parseId(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

/// Parse a value that could be String, int, or num to int?.
/// Returns null if parsing fails or value is null.
int? parseIdNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is num) return value.toInt();
  return null;
}

/// Parse a value that could be String, int, double, or num to double?.
/// Returns null if parsing fails or value is null.
double? parseDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  if (value is num) return value.toDouble();
  return null;
}

/// Parse a value that could be String, int, double, or num to double.
/// Returns 0.0 if parsing fails or value is null.
double parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  if (value is num) return value.toDouble();
  return 0.0;
}

/// Filter type for trade/position queries.
enum FilterType {
  /// Filter by cash value (USD)
  cash('CASH'),

  /// Filter by token quantity
  tokens('TOKENS');

  const FilterType(this.value);
  final String value;

  String toJson() => value;

  static FilterType fromJson(String json) {
    return FilterType.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Invalid FilterType: $json'),
    );
  }
}

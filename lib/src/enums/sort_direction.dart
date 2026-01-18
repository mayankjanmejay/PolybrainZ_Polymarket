import 'package:json_annotation/json_annotation.dart';

/// Sort direction for list queries.
///
/// ```dart
/// final trades = await client.data.trades.getUserTrades(
///   sortDirection: SortDirection.desc,
/// );
/// ```
@JsonEnum(valueField: 'value')
enum SortDirection {
  /// Ascending order (lowest to highest)
  asc('ASC'),

  /// Descending order (highest to lowest)
  desc('DESC');

  const SortDirection(this.value);
  final String value;

  /// Get the opposite direction
  SortDirection get opposite => this == asc ? desc : asc;

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static SortDirection fromJson(String json) {
    return SortDirection.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown SortDirection: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static SortDirection? tryFromJson(String? json) {
    if (json == null) return null;
    return SortDirection.values.cast<SortDirection?>().firstWhere(
          (e) => e?.value.toUpperCase() == json.toUpperCase(),
          orElse: () => null,
        );
  }
}

import 'package:json_annotation/json_annotation.dart';

/// Enum for sorting search results.
@JsonEnum(alwaysCreate: true)
enum SearchSort {
  /// Sort by relevance (default)
  @JsonValue('relevance')
  relevance('relevance'),

  /// Sort by volume
  @JsonValue('volume')
  volume('volume'),

  /// Sort by liquidity
  @JsonValue('liquidity')
  liquidity('liquidity'),

  /// Sort by start date
  @JsonValue('startDate')
  startDate('startDate'),

  /// Sort by end date
  @JsonValue('endDate')
  endDate('endDate'),

  /// Sort by creation date
  @JsonValue('createdAt')
  createdAt('createdAt');

  final String value;
  const SearchSort(this.value);

  /// Convert to JSON string value
  String toJson() => value;

  /// Parse from JSON string
  static SearchSort fromJson(String json) {
    return SearchSort.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown SearchSort: $json'),
    );
  }

  /// Try to parse from JSON string, returns null if invalid
  static SearchSort? tryFromJson(String? json) {
    if (json == null) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

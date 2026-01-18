import 'package:json_annotation/json_annotation.dart';

/// Enum for ordering markets in list queries.
@JsonEnum(alwaysCreate: true)
enum MarketOrderBy {
  /// Order by total volume
  @JsonValue('volume')
  volume('volume'),

  /// Order by 24-hour volume
  @JsonValue('volume24hr')
  volume24hr('volume24hr'),

  /// Order by liquidity
  @JsonValue('liquidity')
  liquidity('liquidity'),

  /// Order by end date
  @JsonValue('endDate')
  endDate('endDate'),

  /// Order by start date
  @JsonValue('startDate')
  startDate('startDate'),

  /// Order by creation date
  @JsonValue('createdAt')
  createdAt('createdAt');

  final String value;
  const MarketOrderBy(this.value);

  /// Convert to JSON string value
  String toJson() => value;

  /// Parse from JSON string
  static MarketOrderBy fromJson(String json) {
    return MarketOrderBy.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown MarketOrderBy: $json'),
    );
  }

  /// Try to parse from JSON string, returns null if invalid
  static MarketOrderBy? tryFromJson(String? json) {
    if (json == null) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

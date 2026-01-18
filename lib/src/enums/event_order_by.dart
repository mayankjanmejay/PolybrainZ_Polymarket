import 'package:json_annotation/json_annotation.dart';

/// Enum for ordering events in list queries.
@JsonEnum(alwaysCreate: true)
enum EventOrderBy {
  /// Order by total volume (aggregated across markets)
  @JsonValue('volume')
  volume('volume'),

  /// Order by start date
  @JsonValue('startDate')
  startDate('startDate'),

  /// Order by end date
  @JsonValue('endDate')
  endDate('endDate'),

  /// Order by creation date
  @JsonValue('createdAt')
  createdAt('createdAt'),

  /// Order by liquidity
  @JsonValue('liquidity')
  liquidity('liquidity');

  final String value;
  const EventOrderBy(this.value);

  /// Convert to JSON string value
  String toJson() => value;

  /// Parse from JSON string
  static EventOrderBy fromJson(String json) {
    return EventOrderBy.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown EventOrderBy: $json'),
    );
  }

  /// Try to parse from JSON string, returns null if invalid
  static EventOrderBy? tryFromJson(String? json) {
    if (json == null) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

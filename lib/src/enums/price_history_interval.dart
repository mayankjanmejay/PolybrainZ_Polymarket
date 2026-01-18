import 'package:json_annotation/json_annotation.dart';

/// Enum for price history time intervals.
@JsonEnum(alwaysCreate: true)
enum PriceHistoryInterval {
  /// 1 minute interval
  @JsonValue('1m')
  minute1('1m'),

  /// 5 minute interval
  @JsonValue('5m')
  minute5('5m'),

  /// 15 minute interval
  @JsonValue('15m')
  minute15('15m'),

  /// 30 minute interval
  @JsonValue('30m')
  minute30('30m'),

  /// 1 hour interval
  @JsonValue('1h')
  hour1('1h'),

  /// 4 hour interval
  @JsonValue('4h')
  hour4('4h'),

  /// 6 hour interval
  @JsonValue('6h')
  hour6('6h'),

  /// 12 hour interval
  @JsonValue('12h')
  hour12('12h'),

  /// 1 day interval
  @JsonValue('1d')
  day1('1d'),

  /// 1 week interval
  @JsonValue('1w')
  week1('1w'),

  /// Maximum/all available data
  @JsonValue('max')
  max('max');

  final String value;
  const PriceHistoryInterval(this.value);

  /// Convert to JSON string value
  String toJson() => value;

  /// Parse from JSON string
  static PriceHistoryInterval fromJson(String json) {
    return PriceHistoryInterval.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown PriceHistoryInterval: $json'),
    );
  }

  /// Try to parse from JSON string, returns null if invalid
  static PriceHistoryInterval? tryFromJson(String? json) {
    if (json == null) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

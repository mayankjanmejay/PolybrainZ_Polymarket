import 'package:json_annotation/json_annotation.dart';

/// Enum for filtering events by status in search.
@JsonEnum(alwaysCreate: true)
enum EventsStatus {
  /// Active/open events
  @JsonValue('active')
  active('active'),

  /// Closed/resolved events
  @JsonValue('closed')
  closed('closed'),

  /// All events (no filter)
  @JsonValue('all')
  all('all');

  final String value;
  const EventsStatus(this.value);

  /// Convert to JSON string value
  String toJson() => value;

  /// Parse from JSON string
  static EventsStatus fromJson(String json) {
    return EventsStatus.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown EventsStatus: $json'),
    );
  }

  /// Try to parse from JSON string, returns null if invalid
  static EventsStatus? tryFromJson(String? json) {
    if (json == null) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

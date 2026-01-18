import 'package:json_annotation/json_annotation.dart';

/// Type-safe enum for event/series recurrence types.
///
/// Use with endpoints that support recurrence filtering.
///
/// ```dart
/// final events = await client.gamma.events.listEvents(
///   recurrence: RecurrenceType.daily,
/// );
/// ```
@JsonEnum(valueField: 'value')
enum RecurrenceType {
  /// Daily recurring events
  daily('daily'),

  /// Weekly recurring events
  weekly('weekly'),

  /// Monthly recurring events
  monthly('monthly'),

  /// Yearly recurring events
  yearly('yearly'),

  /// Non-recurring (one-time) events
  none('none');

  final String value;
  const RecurrenceType(this.value);

  /// Whether this is a recurring type (not none)
  bool get isRecurring => this != none;

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static RecurrenceType fromJson(String json) {
    return RecurrenceType.values.firstWhere(
      (e) => e.value.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown RecurrenceType: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static RecurrenceType? tryFromJson(String? json) {
    if (json == null) return null;
    return RecurrenceType.values.cast<RecurrenceType?>().firstWhere(
          (e) => e?.value.toLowerCase() == json.toLowerCase(),
          orElse: () => null,
        );
  }
}

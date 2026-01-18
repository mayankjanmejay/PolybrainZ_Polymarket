import 'package:json_annotation/json_annotation.dart';

/// Type-safe enum for ordering tags in list queries.
///
/// Use with [TagsEndpoint.listTags()] to specify sort order.
///
/// ```dart
/// final tags = await client.gamma.tags.listTags(
///   order: TagOrderBy.volume,
///   ascending: false,
/// );
/// ```
@JsonEnum(valueField: 'value')
enum TagOrderBy {
  /// Order by total volume traded
  volume('volume'),

  /// Order by number of events
  eventsCount('events_count'),

  /// Order by creation date
  createdAt('createdAt'),

  /// Order by tag label alphabetically
  label('label');

  final String value;
  const TagOrderBy(this.value);

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static TagOrderBy fromJson(String json) {
    return TagOrderBy.values.firstWhere(
      (e) => e.value.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown TagOrderBy: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static TagOrderBy? tryFromJson(String? json) {
    if (json == null) return null;
    return TagOrderBy.values.cast<TagOrderBy?>().firstWhere(
          (e) => e?.value.toLowerCase() == json.toLowerCase(),
          orElse: () => null,
        );
  }
}

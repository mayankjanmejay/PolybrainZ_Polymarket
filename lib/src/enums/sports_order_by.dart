import 'package:json_annotation/json_annotation.dart';

/// Type-safe enum for ordering sports teams in list queries.
///
/// Use with [SportsEndpoint.listTeams()] to specify sort order.
///
/// ```dart
/// final teams = await client.gamma.sports.listTeams(
///   order: SportsOrderBy.name,
///   ascending: true,
/// );
/// ```
@JsonEnum(valueField: 'value')
enum SportsOrderBy {
  /// Order by team name alphabetically
  name('name'),

  /// Order by league
  league('league'),

  /// Order by abbreviation
  abbreviation('abbreviation'),

  /// Order by creation date
  createdAt('createdAt');

  final String value;
  const SportsOrderBy(this.value);

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static SportsOrderBy fromJson(String json) {
    return SportsOrderBy.values.firstWhere(
      (e) => e.value.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown SportsOrderBy: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static SportsOrderBy? tryFromJson(String? json) {
    if (json == null) return null;
    return SportsOrderBy.values.cast<SportsOrderBy?>().firstWhere(
          (e) => e?.value.toLowerCase() == json.toLowerCase(),
          orElse: () => null,
        );
  }
}

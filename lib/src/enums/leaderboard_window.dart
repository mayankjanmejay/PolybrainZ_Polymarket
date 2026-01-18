import 'package:json_annotation/json_annotation.dart';

/// Time window for leaderboard queries.
///
/// Use with [LeaderboardEndpoint] to specify the time period.
///
/// ```dart
/// final leaders = await client.data.leaderboard.getLeaderboard(
///   window: LeaderboardWindow.day7,
/// );
/// ```
@JsonEnum(valueField: 'value')
enum LeaderboardWindow {
  /// Past 24 hours
  day1('1d'),

  /// Past 7 days
  day7('7d'),

  /// Past 30 days
  day30('30d'),

  /// All time
  all('all');

  const LeaderboardWindow(this.value);
  final String value;

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static LeaderboardWindow fromJson(String json) {
    return LeaderboardWindow.values.firstWhere(
      (e) => e.value.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown LeaderboardWindow: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static LeaderboardWindow? tryFromJson(String? json) {
    if (json == null) return null;
    return LeaderboardWindow.values.cast<LeaderboardWindow?>().firstWhere(
          (e) => e?.value.toLowerCase() == json.toLowerCase(),
          orElse: () => null,
        );
  }
}

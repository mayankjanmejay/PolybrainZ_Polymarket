import 'package:json_annotation/json_annotation.dart';

/// Type of leaderboard ranking.
///
/// Use with [LeaderboardEndpoint] to specify the ranking type.
///
/// ```dart
/// final profitLeaders = await client.data.leaderboard.getLeaderboard(
///   type: LeaderboardType.profit,
/// );
/// ```
@JsonEnum(valueField: 'value')
enum LeaderboardType {
  /// Rank by profit
  profit('PROFIT'),

  /// Rank by trading volume
  volume('VOLUME');

  const LeaderboardType(this.value);
  final String value;

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static LeaderboardType fromJson(String json) {
    return LeaderboardType.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown LeaderboardType: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static LeaderboardType? tryFromJson(String? json) {
    if (json == null) return null;
    return LeaderboardType.values.cast<LeaderboardType?>().firstWhere(
          (e) => e?.value.toUpperCase() == json.toUpperCase(),
          orElse: () => null,
        );
  }
}

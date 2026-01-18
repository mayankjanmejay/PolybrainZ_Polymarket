import 'package:json_annotation/json_annotation.dart';

/// Enum for ordering Gamma leaderboard results.
@JsonEnum(alwaysCreate: true)
enum GammaLeaderboardOrderBy {
  /// Order by profit
  @JsonValue('profit')
  profit('profit'),

  /// Order by trading volume
  @JsonValue('volume')
  volume('volume'),

  /// Order by number of markets traded
  @JsonValue('markets_traded')
  marketsTraded('markets_traded');

  final String value;
  const GammaLeaderboardOrderBy(this.value);

  /// Convert to JSON string value
  String toJson() => value;

  /// Parse from JSON string
  static GammaLeaderboardOrderBy fromJson(String json) {
    return GammaLeaderboardOrderBy.values.firstWhere(
      (e) => e.value == json,
      orElse: () =>
          throw ArgumentError('Unknown GammaLeaderboardOrderBy: $json'),
    );
  }

  /// Try to parse from JSON string, returns null if invalid
  static GammaLeaderboardOrderBy? tryFromJson(String? json) {
    if (json == null) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

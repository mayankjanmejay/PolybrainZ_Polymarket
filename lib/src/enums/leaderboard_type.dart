/// Type of leaderboard ranking.
enum LeaderboardType {
  profit('PROFIT'),
  volume('VOLUME');

  const LeaderboardType(this.value);
  final String value;

  String toJson() => value;

  static LeaderboardType fromJson(String json) {
    return LeaderboardType.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => profit,
    );
  }
}

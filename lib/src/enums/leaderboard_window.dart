/// Time window for leaderboard.
enum LeaderboardWindow {
  day1('1d'),
  day7('7d'),
  day30('30d'),
  all('all');

  const LeaderboardWindow(this.value);
  final String value;

  String toJson() => value;

  static LeaderboardWindow fromJson(String json) {
    return LeaderboardWindow.values.firstWhere(
      (e) => e.value.toLowerCase() == json.toLowerCase(),
      orElse: () => all,
    );
  }
}

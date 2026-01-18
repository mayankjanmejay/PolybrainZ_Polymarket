/// Status of a sports game/event.
enum GameStatus {
  /// Game has not started yet
  scheduled('scheduled'),

  /// Game is currently in progress
  inProgress('in_progress'),

  /// Game is in a break/halftime
  halftime('halftime'),

  /// Game has ended
  ended('ended'),

  /// Game was postponed
  postponed('postponed'),

  /// Game was cancelled
  cancelled('cancelled'),

  /// Game is suspended
  suspended('suspended');

  const GameStatus(this.value);
  final String value;

  String toJson() => value;

  static GameStatus fromJson(String json) {
    final normalized = json.toLowerCase().trim().replaceAll(' ', '_');
    return GameStatus.values.firstWhere(
      (e) => e.value == normalized || e.name.toLowerCase() == normalized,
      orElse: () => throw ArgumentError('Invalid GameStatus: $json'),
    );
  }

  /// Try to parse, returns null if invalid
  static GameStatus? tryFromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Whether the game is live/active
  bool get isLive => this == inProgress || this == halftime;

  /// Whether the game has concluded
  bool get isFinished => this == ended;

  /// Whether the game is upcoming
  bool get isUpcoming => this == scheduled;

  /// Whether the game was interrupted
  bool get isInterrupted => this == postponed || this == cancelled || this == suspended;
}

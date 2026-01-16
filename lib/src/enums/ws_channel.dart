/// WebSocket channel types.
enum WsChannel {
  /// Public market data channel
  market('market'),

  /// Authenticated user channel
  user('user');

  const WsChannel(this.value);
  final String value;

  String toJson() => value;

  static WsChannel fromJson(String json) {
    return WsChannel.values.firstWhere(
      (e) => e.value == json,
      orElse: () => market,
    );
  }
}

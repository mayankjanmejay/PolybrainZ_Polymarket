/// Status of a trade.
enum TradeStatus {
  /// Trade has been mined on-chain
  mined('MINED'),

  /// Trade has been confirmed
  confirmed('CONFIRMED'),

  /// Trade is being retried
  retrying('RETRYING'),

  /// Trade failed
  failed('FAILED');

  const TradeStatus(this.value);
  final String value;

  String toJson() => value;

  static TradeStatus fromJson(String json) {
    return TradeStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Invalid TradeStatus: $json'),
    );
  }

  bool get isTerminal => this == confirmed || this == failed;
  bool get isPending => this == mined || this == retrying;
}

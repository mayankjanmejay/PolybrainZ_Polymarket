/// RTDS WebSocket topics.
enum RtdsTopic {
  /// Binance crypto prices
  cryptoPrices('crypto_prices'),

  /// Chainlink crypto prices
  cryptoPricesChainlink('crypto_prices_chainlink'),

  /// Comment updates
  comments('comments');

  const RtdsTopic(this.value);
  final String value;

  String toJson() => value;

  static RtdsTopic fromJson(String json) {
    return RtdsTopic.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Invalid RtdsTopic: $json'),
    );
  }
}

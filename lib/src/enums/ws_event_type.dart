/// WebSocket event types.
enum WsEventType {
  book('book'),
  priceChange('price_change'),
  lastTradePrice('last_trade_price'),
  tickSizeChange('tick_size_change'),
  bestBidAsk('best_bid_ask'),
  newMarket('new_market'),
  marketResolved('market_resolved'),
  trade('trade'),
  order('order');

  const WsEventType(this.value);
  final String value;

  String toJson() => value;

  static WsEventType fromJson(String json) {
    return WsEventType.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Invalid WsEventType: $json'),
    );
  }
}

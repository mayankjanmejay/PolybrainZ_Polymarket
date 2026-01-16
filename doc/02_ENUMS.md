# Enums Reference

All enums for the Polymarket API wrapper. Copy each file exactly.

---

## Standard Enum Pattern

Every enum MUST follow this exact pattern:

```dart
enum EnumName {
  value1('API_VALUE_1'),
  value2('API_VALUE_2');

  const EnumName(this.value);
  final String value;

  factory EnumName.fromJson(String json) {
    return EnumName.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown EnumName: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## src/enums/order_side.dart

```dart
/// The side of an order - buying or selling outcome tokens.
enum OrderSide {
  /// Buy order - acquiring outcome tokens
  buy('BUY'),
  
  /// Sell order - disposing of outcome tokens
  sell('SELL');

  const OrderSide(this.value);
  
  /// The API string value
  final String value;

  /// Parse from JSON string (case-insensitive)
  factory OrderSide.fromJson(String json) {
    return OrderSide.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown OrderSide: $json'),
    );
  }

  /// Convert to JSON string
  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## src/enums/order_type.dart

```dart
/// Order execution type determining how orders are filled.
enum OrderType {
  /// Good Till Cancelled - rests on book until filled or cancelled
  gtc('GTC'),
  
  /// Good Till Date - expires at specified timestamp
  gtd('GTD'),
  
  /// Fill or Kill - must fill completely immediately or cancel entire order
  fok('FOK'),
  
  /// Fill and Kill (Immediate or Cancel) - fill what you can, cancel rest
  fak('FAK');

  const OrderType(this.value);
  final String value;

  factory OrderType.fromJson(String json) {
    return OrderType.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown OrderType: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
  
  /// Whether this order type supports expiration
  bool get supportsExpiration => this == OrderType.gtd;
  
  /// Whether this is a market order type (immediate execution)
  bool get isImmediate => this == OrderType.fok || this == OrderType.fak;
}
```

---

## src/enums/trade_status.dart

```dart
/// Status of a trade on the blockchain.
enum TradeStatus {
  /// Transaction has been mined but not yet confirmed
  mined('MINED'),
  
  /// Transaction is fully confirmed
  confirmed('CONFIRMED'),
  
  /// Transaction failed and is being retried
  retrying('RETRYING'),
  
  /// Transaction permanently failed
  failed('FAILED');

  const TradeStatus(this.value);
  final String value;

  factory TradeStatus.fromJson(String json) {
    return TradeStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown TradeStatus: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
  
  /// Whether the trade is in a final state
  bool get isFinal => this == TradeStatus.confirmed || this == TradeStatus.failed;
  
  /// Whether the trade is still pending
  bool get isPending => this == TradeStatus.mined || this == TradeStatus.retrying;
}
```

---

## src/enums/activity_type.dart

```dart
/// Type of on-chain activity for a user.
enum ActivityType {
  /// Buy or sell trade executed
  trade('TRADE'),
  
  /// USDC split into Yes + No tokens
  split('SPLIT'),
  
  /// Yes + No tokens merged back to USDC
  merge('MERGE'),
  
  /// Winning tokens redeemed after market resolution
  redeem('REDEEM'),
  
  /// Liquidity reward received
  reward('REWARD'),
  
  /// Negative risk token conversion
  conversion('CONVERSION');

  const ActivityType(this.value);
  final String value;

  factory ActivityType.fromJson(String json) {
    return ActivityType.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown ActivityType: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## src/enums/sort_by.dart

```dart
/// Sort criteria for positions and data queries.
enum SortBy {
  /// Sort by current value
  current('CURRENT'),
  
  /// Sort by initial value
  initial('INITIAL'),
  
  /// Sort by token amount (size)
  tokens('TOKENS'),
  
  /// Sort by cash profit/loss
  cashPnl('CASHPNL'),
  
  /// Sort by percent profit/loss
  percentPnl('PERCENTPNL'),
  
  /// Sort alphabetically by title
  title('TITLE'),
  
  /// Sort by resolution date
  resolving('RESOLVING'),
  
  /// Sort by current price
  price('PRICE'),
  
  /// Sort by average entry price
  avgPrice('AVGPRICE'),
  
  /// Sort by timestamp
  timestamp('TIMESTAMP'),
  
  /// Sort by cash amount
  cash('CASH');

  const SortBy(this.value);
  final String value;

  factory SortBy.fromJson(String json) {
    return SortBy.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown SortBy: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## src/enums/sort_direction.dart

```dart
/// Sort direction for queries.
enum SortDirection {
  /// Ascending order (smallest first)
  asc('ASC'),
  
  /// Descending order (largest first)
  desc('DESC');

  const SortDirection(this.value);
  final String value;

  factory SortDirection.fromJson(String json) {
    return SortDirection.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown SortDirection: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## src/enums/filter_type.dart

```dart
/// Filter type for trade and activity queries.
enum FilterType {
  /// Filter by cash/USDC amount
  cash('CASH'),
  
  /// Filter by token amount
  tokens('TOKENS');

  const FilterType(this.value);
  final String value;

  factory FilterType.fromJson(String json) {
    return FilterType.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown FilterType: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## src/enums/signature_type.dart

```dart
/// Wallet signature type for authentication.
/// 
/// Determines how signatures are verified by the CLOB.
enum SignatureType {
  /// Standard EOA (Externally Owned Account) - MetaMask, hardware wallets
  eoa(0),
  
  /// Email/Magic wallet signatures
  emailMagic(1),
  
  /// Browser wallet with proxy (Coinbase Wallet, etc.)
  browserWallet(2);

  const SignatureType(this.value);
  
  /// The numeric value used in API calls
  final int value;

  factory SignatureType.fromJson(int json) {
    return SignatureType.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown SignatureType: $json'),
    );
  }

  int toJson() => value;
  
  @override
  String toString() => value.toString();
}
```

---

## src/enums/tick_size.dart

```dart
/// Minimum price increment (tick size) for a market.
enum TickSize {
  /// 0.1 (10 cents)
  point1('0.1'),
  
  /// 0.01 (1 cent) - most common
  point01('0.01'),
  
  /// 0.001 (0.1 cents)
  point001('0.001'),
  
  /// 0.0001 (0.01 cents)
  point0001('0.0001');

  const TickSize(this.value);
  final String value;

  factory TickSize.fromJson(String json) {
    return TickSize.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown TickSize: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
  
  /// Get the numeric value
  double get numericValue => double.parse(value);
}
```

---

## src/enums/leaderboard_window.dart

```dart
/// Time window for leaderboard queries.
enum LeaderboardWindow {
  /// Last 24 hours
  oneDay('1d'),
  
  /// Last 7 days
  sevenDays('7d'),
  
  /// Last 30 days
  thirtyDays('30d'),
  
  /// All time
  all('all');

  const LeaderboardWindow(this.value);
  final String value;

  factory LeaderboardWindow.fromJson(String json) {
    return LeaderboardWindow.values.firstWhere(
      (e) => e.value.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown LeaderboardWindow: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## src/enums/leaderboard_type.dart

```dart
/// Type of leaderboard ranking.
enum LeaderboardType {
  /// Ranked by profit
  profit('PROFIT'),
  
  /// Ranked by trading volume
  volume('VOLUME');

  const LeaderboardType(this.value);
  final String value;

  factory LeaderboardType.fromJson(String json) {
    return LeaderboardType.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown LeaderboardType: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## src/enums/ws_event_type.dart

```dart
/// WebSocket message event types.
enum WsEventType {
  /// Order book snapshot/update
  book('book'),
  
  /// Price change notification
  priceChange('price_change'),
  
  /// Last trade price update
  lastTradePrice('last_trade_price'),
  
  /// Tick size change for market
  tickSizeChange('tick_size_change'),
  
  /// Best bid/ask update
  bestBidAsk('best_bid_ask'),
  
  /// New market created
  newMarket('new_market'),
  
  /// Market resolved
  marketResolved('market_resolved'),
  
  /// Trade executed (user channel)
  trade('trade'),
  
  /// Order status update (user channel)
  order('order');

  const WsEventType(this.value);
  final String value;

  factory WsEventType.fromJson(String json) {
    return WsEventType.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown WsEventType: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## src/enums/ws_channel.dart

```dart
/// WebSocket subscription channel type.
enum WsChannel {
  /// Market channel - public orderbook and price data
  market('market'),
  
  /// User channel - authenticated order and trade updates
  user('user');

  const WsChannel(this.value);
  final String value;

  factory WsChannel.fromJson(String json) {
    return WsChannel.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown WsChannel: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## src/enums/rtds_topic.dart

```dart
/// RTDS (Real-Time Data Stream) subscription topics.
enum RtdsTopic {
  /// Crypto price feed from standard source
  cryptoPrices('crypto_prices'),
  
  /// Crypto price feed from Chainlink oracles
  cryptoPricesChainlink('crypto_prices_chainlink'),
  
  /// Comment stream for markets
  comments('comments');

  const RtdsTopic(this.value);
  final String value;

  factory RtdsTopic.fromJson(String json) {
    return RtdsTopic.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown RtdsTopic: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## src/enums/parent_entity_type.dart

```dart
/// Parent entity type for comments and related items.
enum ParentEntityType {
  /// Comment on an event
  event('Event'),
  
  /// Comment on a series
  series('Series'),
  
  /// Comment on a market
  market('market');

  const ParentEntityType(this.value);
  final String value;

  factory ParentEntityType.fromJson(String json) {
    return ParentEntityType.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown ParentEntityType: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## src/enums/game_status.dart

```dart
/// Status of a sports game/event.
enum GameStatus {
  /// Game is currently in progress
  inProgress('InProgress'),
  
  /// Game has finished
  finished('finished'),
  
  /// Game is scheduled but not started
  scheduled('scheduled'),
  
  /// Game was cancelled
  cancelled('cancelled'),
  
  /// Game was postponed
  postponed('postponed');

  const GameStatus(this.value);
  final String value;

  factory GameStatus.fromJson(String json) {
    return GameStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown GameStatus: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
  
  /// Whether the game is still live
  bool get isLive => this == GameStatus.inProgress;
  
  /// Whether the game has concluded
  bool get isEnded => this == GameStatus.finished || 
                      this == GameStatus.cancelled || 
                      this == GameStatus.postponed;
}
```

---

## src/enums/order_action_type.dart

```dart
/// Type of order action in WebSocket messages.
enum OrderActionType {
  /// New order placed
  placement('PLACEMENT'),
  
  /// Existing order updated
  update('UPDATE'),
  
  /// Order cancelled
  cancellation('CANCELLATION');

  const OrderActionType(this.value);
  final String value;

  factory OrderActionType.fromJson(String json) {
    return OrderActionType.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown OrderActionType: $json'),
    );
  }

  String toJson() => value;
  
  @override
  String toString() => value;
}
```

---

## Barrel Export

Create `src/enums/enums.dart` to export all enums:

```dart
// src/enums/enums.dart

export 'order_side.dart';
export 'order_type.dart';
export 'trade_status.dart';
export 'activity_type.dart';
export 'sort_by.dart';
export 'sort_direction.dart';
export 'filter_type.dart';
export 'signature_type.dart';
export 'tick_size.dart';
export 'leaderboard_window.dart';
export 'leaderboard_type.dart';
export 'ws_event_type.dart';
export 'ws_channel.dart';
export 'rtds_topic.dart';
export 'parent_entity_type.dart';
export 'game_status.dart';
export 'order_action_type.dart';
```

---

## Usage in Models

When using enums in JSON-serializable models:

```dart
import 'package:json_annotation/json_annotation.dart';
import '../enums/order_side.dart';

@JsonSerializable()
class Trade {
  @JsonKey(fromJson: _orderSideFromJson, toJson: _orderSideToJson)
  final OrderSide side;
  
  // ...
}

OrderSide _orderSideFromJson(String json) => OrderSide.fromJson(json);
String _orderSideToJson(OrderSide side) => side.toJson();
```

Or use a custom JsonConverter:

```dart
class OrderSideConverter implements JsonConverter<OrderSide, String> {
  const OrderSideConverter();
  
  @override
  OrderSide fromJson(String json) => OrderSide.fromJson(json);
  
  @override
  String toJson(OrderSide object) => object.toJson();
}

// Usage
@JsonSerializable()
class Trade {
  @OrderSideConverter()
  final OrderSide side;
}
```

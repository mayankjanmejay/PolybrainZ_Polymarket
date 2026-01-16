# Polymarket API Wrapper - Complete Implementation Plan

## Overview

This plan outlines a complete Dart API wrapper for Polymarket covering:
- **Gamma API** (Market data, Events, Tags, Sports, Series, Comments, Profiles, Search)
- **CLOB API** (Order book, Pricing, Orders, Trades)
- **Data API** (Positions, Trades, Activity, Holdings)
- **WebSocket APIs** (CLOB WebSocket, RTDS, Sports WebSocket)

## Project Structure

```
lib/
├── polybrainz_polymarket.dart              # Main library export
└── src/
    ├── core/
    │   ├── api_client.dart                 # Base HTTP client
    │   ├── websocket_client.dart           # Base WebSocket client
    │   ├── exceptions.dart                 # Custom exceptions
    │   ├── result.dart                     # Result type for error handling
    │   └── constants.dart                  # API base URLs, constants
    │
    ├── auth/
    │   ├── auth_service.dart               # Authentication orchestrator
    │   ├── l1_auth.dart                    # L1 (Private key) authentication
    │   ├── l2_auth.dart                    # L2 (API key) authentication
    │   └── models/
    │       └── api_credentials.dart        # API key, secret, passphrase model
    │
    ├── gamma/
    │   ├── gamma_client.dart               # Gamma API client
    │   ├── endpoints/
    │   │   ├── events_endpoint.dart
    │   │   ├── markets_endpoint.dart
    │   │   ├── tags_endpoint.dart
    │   │   ├── sports_endpoint.dart
    │   │   ├── series_endpoint.dart
    │   │   ├── comments_endpoint.dart
    │   │   ├── profiles_endpoint.dart
    │   │   └── search_endpoint.dart
    │   └── models/
    │       ├── event.dart
    │       ├── market.dart
    │       ├── tag.dart
    │       ├── team.dart
    │       ├── sport_metadata.dart
    │       ├── series.dart
    │       ├── comment.dart
    │       ├── profile.dart
    │       ├── search_result.dart
    │       ├── category.dart
    │       └── pagination.dart
    │
    ├── clob/
    │   ├── clob_client.dart                # CLOB API client
    │   ├── endpoints/
    │   │   ├── orderbook_endpoint.dart
    │   │   ├── pricing_endpoint.dart
    │   │   ├── orders_endpoint.dart
    │   │   └── spreads_endpoint.dart
    │   └── models/
    │       ├── order_book.dart
    │       ├── order_summary.dart
    │       ├── price.dart
    │       ├── midpoint.dart
    │       ├── spread.dart
    │       ├── order.dart
    │       └── trade.dart
    │
    ├── data/
    │   ├── data_client.dart                # Data API client
    │   ├── endpoints/
    │   │   ├── positions_endpoint.dart
    │   │   ├── trades_endpoint.dart
    │   │   ├── activity_endpoint.dart
    │   │   ├── holders_endpoint.dart
    │   │   └── leaderboard_endpoint.dart
    │   └── models/
    │       ├── position.dart
    │       ├── trade_record.dart
    │       ├── activity.dart
    │       ├── holder.dart
    │       └── leaderboard_entry.dart
    │
    ├── websocket/
    │   ├── clob_websocket.dart             # CLOB WebSocket client
    │   ├── rtds_websocket.dart             # RTDS WebSocket client
    │   ├── sports_websocket.dart           # Sports WebSocket client
    │   ├── channels/
    │   │   ├── market_channel.dart
    │   │   └── user_channel.dart
    │   └── models/
    │       ├── ws_message.dart
    │       ├── book_message.dart
    │       ├── price_change_message.dart
    │       ├── last_trade_price_message.dart
    │       ├── tick_size_change_message.dart
    │       ├── best_bid_ask_message.dart
    │       ├── new_market_message.dart
    │       ├── market_resolved_message.dart
    │       ├── trade_message.dart
    │       ├── order_message.dart
    │       ├── crypto_price_message.dart
    │       ├── comment_message.dart
    │       └── sport_result_message.dart
    │
    └── enums/
        ├── order_side.dart                 # BUY, SELL
        ├── order_type.dart                 # PLACEMENT, UPDATE, CANCELLATION
        ├── trade_status.dart               # MINED, CONFIRMED, RETRYING, FAILED
        ├── sort_by.dart                    # CURRENT, INITIAL, TOKENS, etc.
        ├── sort_direction.dart             # ASC, DESC
        ├── filter_type.dart                # CASH, TOKENS
        ├── parent_entity_type.dart         # Event, Series, market
        ├── game_status.dart                # InProgress, finished, etc.
        └── ws_event_type.dart              # book, price_change, trade, etc.
```

---

## Phase 1: Core Infrastructure

### 1.1 Dependencies (pubspec.yaml)
```yaml
dependencies:
  http: ^1.2.0              # HTTP requests
  web_socket_channel: ^3.0.0 # WebSocket connections
  crypto: ^3.0.3            # HMAC-SHA256 for L2 auth
  convert: ^3.1.1           # Base64 encoding
  equatable: ^2.0.5         # Value equality for models
  json_annotation: ^4.9.0   # JSON serialization annotations

dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.8.0
  lints: ^6.0.0
  test: ^1.25.6
  mockito: ^5.4.0
  http_mock_adapter: ^0.6.0
```

### 1.2 Constants (`constants.dart`)
```dart
class PolymarketConstants {
  static const String gammaBaseUrl = 'https://gamma-api.polymarket.com';
  static const String clobBaseUrl = 'https://clob.polymarket.com';
  static const String dataBaseUrl = 'https://data-api.polymarket.com';

  static const String clobWssUrl = 'wss://ws-subscriptions-clob.polymarket.com/ws/';
  static const String rtdsWssUrl = 'wss://ws-live-data.polymarket.com';
  static const String sportsWssUrl = 'wss://sports-api.polymarket.com/ws';
}
```

### 1.3 Exceptions (`exceptions.dart`)
```dart
abstract class PolymarketException implements Exception { ... }
class ApiException extends PolymarketException { ... }
class AuthenticationException extends PolymarketException { ... }
class RateLimitException extends PolymarketException { ... }
class NetworkException extends PolymarketException { ... }
class WebSocketException extends PolymarketException { ... }
```

### 1.4 Base API Client (`api_client.dart`)
- Generic HTTP client with retry logic
- Request/response interceptors
- Error handling and exception mapping
- Rate limiting awareness

### 1.5 Base WebSocket Client (`websocket_client.dart`)
- Connection management with auto-reconnect
- Heartbeat/ping-pong handling
- Subscription management
- Message parsing and routing

---

## Phase 2: Enums

### 2.1 Order Side (`order_side.dart`)
```dart
enum OrderSide {
  buy('BUY'),
  sell('SELL');

  const OrderSide(this.value);
  final String value;

  factory OrderSide.fromJson(String json) => ...
  String toJson() => value;
}
```

### 2.2 Order Type (`order_type.dart`)
```dart
enum OrderType {
  placement('PLACEMENT'),
  update('UPDATE'),
  cancellation('CANCELLATION');
}
```

### 2.3 Trade Status (`trade_status.dart`)
```dart
enum TradeStatus {
  mined('MINED'),
  confirmed('CONFIRMED'),
  retrying('RETRYING'),
  failed('FAILED');
}
```

### 2.4 Sort By (`sort_by.dart`)
```dart
enum SortBy {
  current('CURRENT'),
  initial('INITIAL'),
  tokens('TOKENS'),
  cashPnl('CASHPNL'),
  percentPnl('PERCENTPNL'),
  title('TITLE'),
  resolving('RESOLVING'),
  price('PRICE'),
  avgPrice('AVGPRICE');
}
```

### 2.5 Additional Enums
- `SortDirection` (ASC, DESC)
- `FilterType` (CASH, TOKENS)
- `ParentEntityType` (Event, Series, market)
- `GameStatus` (InProgress, finished)
- `WsEventType` (book, price_change, trade, order, etc.)

---

## Phase 3: Gamma API Models

### 3.1 Event Model (`event.dart`)
```dart
@JsonSerializable()
class Event extends Equatable {
  final String id;
  final String? ticker;
  final String? slug;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? resolutionSource;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? creationDate;
  final String? image;
  final String? icon;
  final String? featuredImage;
  final bool? active;
  final bool? closed;
  final bool? archived;
  final bool? isNew;
  final bool? featured;
  final bool? restricted;
  final bool? cyom;
  final double? liquidity;
  final double? liquidityAmm;
  final double? liquidityClob;
  final double? volume;
  final double? volume24hr;
  final double? volume1wk;
  final double? volume1mo;
  final double? volume1yr;
  final double? openInterest;
  final double? competitive;
  final String? category;
  final String? subcategory;
  final String? sortBy;
  final List<Category>? categories;
  final List<Tag>? tags;
  final bool? negRisk;
  final String? negRiskMarketID;
  final int? negRiskFeeBips;
  final List<Market>? markets;
  final List<Series>? series;
  final int? commentCount;
  final bool? commentsEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? enableOrderBook;
  final bool? live;
  final bool? ended;
  final String? gameStatus;

  factory Event.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 3.2 Market Model (`market.dart`)
```dart
@JsonSerializable()
class Market extends Equatable {
  final String id;
  final String? question;
  final String conditionId;
  final String? slug;
  final DateTime? endDate;
  final String? liquidity;
  final String? volume;
  final bool? active;
  final bool? closed;
  final bool? acceptingOrders;
  final bool? enableOrderBook;
  final double? volumeNum;
  final double? liquidityNum;
  final String? outcomes;           // JSON string of outcomes array
  final String? outcomePrices;      // JSON string of prices array
  final String marketMakerAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Event>? events;
  final List<Category>? categories;
  final List<Tag>? tags;
  final String? clobTokenIds;       // JSON string of token IDs

  factory Market.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...

  // Helper methods
  List<String> get outcomesList => ...
  List<double> get outcomePricesList => ...
  List<String> get tokenIdsList => ...
}
```

### 3.3 Tag Model (`tag.dart`)
```dart
@JsonSerializable()
class Tag extends Equatable {
  final int id;
  final String? label;
  final String? slug;
  final bool? forceShow;
  final bool? display;
  final int? eventCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Tag.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 3.4 Team Model (`team.dart`)
```dart
@JsonSerializable()
class Team extends Equatable {
  final int id;
  final String? name;
  final String? league;
  final String? record;
  final String? logo;
  final String? abbreviation;
  final String? alias;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Team.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 3.5 Series Model (`series.dart`)
```dart
@JsonSerializable()
class Series extends Equatable {
  final int? id;
  final String? ticker;
  final String? slug;
  final String? title;
  final String? subtitle;
  final String? seriesType;
  final String? recurrence;
  final String? description;
  final String? image;
  final String? icon;
  final String? layout;
  final bool? active;
  final bool? closed;
  final bool? archived;
  final bool? isNew;
  final bool? featured;
  final bool? restricted;
  final double? volume24hr;
  final double? volume;
  final double? liquidity;
  final double? score;
  final int? commentCount;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? startDate;
  final List<Event>? events;
  final List<Category>? categories;
  final List<Tag>? tags;

  factory Series.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 3.6 Comment Model (`comment.dart`)
```dart
@JsonSerializable()
class Comment extends Equatable {
  final String id;
  final String? body;
  final String? parentEntityType;
  final int? parentEntityID;
  final String? parentCommentID;
  final String? userAddress;
  final String? replyAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Profile? profile;
  final List<Reaction>? reactions;
  final int? reportCount;
  final int? reactionCount;

  factory Comment.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 3.7 Profile Model (`profile.dart`)
```dart
@JsonSerializable()
class Profile extends Equatable {
  final DateTime? createdAt;
  final String? proxyWallet;
  final String? profileImage;
  final bool? displayUsernamePublic;
  final String? bio;
  final String? pseudonym;
  final String? name;
  final String? xUsername;
  final bool? verifiedBadge;
  final String? baseAddress;

  factory Profile.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 3.8 Search Result Model (`search_result.dart`)
```dart
@JsonSerializable()
class SearchResult extends Equatable {
  final List<Event>? events;
  final List<Tag>? tags;
  final List<Profile>? profiles;
  final Pagination? pagination;

  factory SearchResult.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 3.9 Category Model (`category.dart`)
```dart
@JsonSerializable()
class Category extends Equatable {
  final int? id;
  final String? label;
  final String? slug;

  factory Category.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

---

## Phase 4: CLOB API Models

### 4.1 Order Book Model (`order_book.dart`)
```dart
@JsonSerializable()
class OrderBook extends Equatable {
  final String market;
  final String assetId;
  final DateTime timestamp;
  final String hash;
  final List<OrderSummary> bids;
  final List<OrderSummary> asks;
  final String minOrderSize;
  final String tickSize;
  final bool negRisk;

  factory OrderBook.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 4.2 Order Summary Model (`order_summary.dart`)
```dart
@JsonSerializable()
class OrderSummary extends Equatable {
  final String price;
  final String size;

  factory OrderSummary.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 4.3 Price Model (`price.dart`)
```dart
@JsonSerializable()
class Price extends Equatable {
  final String price;

  factory Price.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 4.4 Midpoint Model (`midpoint.dart`)
```dart
@JsonSerializable()
class Midpoint extends Equatable {
  final String mid;

  factory Midpoint.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

---

## Phase 5: Data API Models

### 5.1 Position Model (`position.dart`)
```dart
@JsonSerializable()
class Position extends Equatable {
  final String proxyWallet;
  final String asset;
  final String conditionId;
  final double size;
  final double avgPrice;
  final double initialValue;
  final double currentValue;
  final double cashPnl;
  final double percentPnl;
  final double totalBought;
  final double realizedPnl;
  final double percentRealizedPnl;
  final double curPrice;
  final bool redeemable;
  final bool mergeable;
  final String title;
  final String slug;
  final String icon;
  final String eventSlug;
  final String outcome;
  final int outcomeIndex;
  final String oppositeOutcome;
  final String oppositeAsset;
  final String endDate;
  final bool negativeRisk;

  factory Position.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 5.2 Trade Record Model (`trade_record.dart`)
```dart
@JsonSerializable()
class TradeRecord extends Equatable {
  final String proxyWallet;
  final OrderSide side;
  final String asset;
  final String conditionId;
  final double size;
  final double price;
  final int timestamp;
  final String title;
  final String slug;
  final String icon;
  final String eventSlug;
  final String outcome;
  final int outcomeIndex;
  final String? name;
  final String? pseudonym;
  final String? bio;
  final String? profileImage;
  final String? transactionHash;

  factory TradeRecord.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

---

## Phase 6: WebSocket Models

### 6.1 Book Message (`book_message.dart`)
```dart
@JsonSerializable()
class BookMessage extends Equatable {
  final String eventType;  // "book"
  final String assetId;
  final String market;
  final String timestamp;
  final String hash;
  final List<OrderSummary> bids;
  final List<OrderSummary> asks;

  factory BookMessage.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 6.2 Price Change Message (`price_change_message.dart`)
```dart
@JsonSerializable()
class PriceChangeMessage extends Equatable {
  final String eventType;  // "price_change"
  final String market;
  final List<PriceChangeItem> priceChanges;
  final String timestamp;

  factory PriceChangeMessage.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}

@JsonSerializable()
class PriceChangeItem extends Equatable {
  final String assetId;
  final String price;
  final String size;
  final String side;
  final String hash;
  final String bestBid;
  final String bestAsk;

  factory PriceChangeItem.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 6.3 Last Trade Price Message (`last_trade_price_message.dart`)
```dart
@JsonSerializable()
class LastTradePriceMessage extends Equatable {
  final String assetId;
  final String eventType;  // "last_trade_price"
  final String feeRateBps;
  final String market;
  final String price;
  final String side;
  final String size;
  final String timestamp;

  factory LastTradePriceMessage.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 6.4 Trade Message (User Channel) (`trade_message.dart`)
```dart
@JsonSerializable()
class WsTradeMessage extends Equatable {
  final String assetId;
  final String eventType;  // "trade"
  final String id;
  final String lastUpdate;
  final List<MakerOrder> makerOrders;
  final String market;
  final String matchtime;
  final String outcome;
  final String owner;
  final String price;
  final String side;
  final String size;
  final String status;
  final String takerOrderId;
  final String timestamp;
  final String tradeOwner;
  final String type;

  factory WsTradeMessage.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}

@JsonSerializable()
class MakerOrder extends Equatable {
  final String assetId;
  final String matchedAmount;
  final String orderId;
  final String outcome;
  final String owner;
  final String price;

  factory MakerOrder.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 6.5 Order Message (User Channel) (`order_message.dart`)
```dart
@JsonSerializable()
class WsOrderMessage extends Equatable {
  final String assetId;
  final List<String>? associateTrades;
  final String eventType;  // "order"
  final String id;
  final String market;
  final String orderOwner;
  final String originalSize;
  final String outcome;
  final String owner;
  final String price;
  final String side;
  final String sizeMatched;
  final String timestamp;
  final String type;  // PLACEMENT, UPDATE, CANCELLATION

  factory WsOrderMessage.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 6.6 Crypto Price Message (`crypto_price_message.dart`)
```dart
@JsonSerializable()
class CryptoPriceMessage extends Equatable {
  final String topic;     // "crypto_prices" or "crypto_prices_chainlink"
  final String type;      // "update"
  final int timestamp;
  final CryptoPricePayload payload;

  factory CryptoPriceMessage.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}

@JsonSerializable()
class CryptoPricePayload extends Equatable {
  final String symbol;
  final int timestamp;
  final double value;

  factory CryptoPricePayload.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 6.7 Comment Message (`comment_message.dart`)
```dart
@JsonSerializable()
class CommentMessage extends Equatable {
  final String topic;     // "comments"
  final String type;      // comment_created, comment_removed, reaction_created, reaction_removed
  final int timestamp;
  final CommentPayload payload;

  factory CommentMessage.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}

@JsonSerializable()
class CommentPayload extends Equatable {
  final String body;
  final String createdAt;
  final String id;
  final String? parentCommentID;
  final int parentEntityID;
  final String parentEntityType;
  final Profile profile;
  final int reactionCount;
  final String? replyAddress;
  final int reportCount;
  final String userAddress;

  factory CommentPayload.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 6.8 Sport Result Message (`sport_result_message.dart`)
```dart
@JsonSerializable()
class SportResultMessage extends Equatable {
  final int gameId;
  final String leagueAbbreviation;
  final String homeTeam;
  final String awayTeam;
  final String status;
  final bool live;
  final bool ended;
  final String score;
  final String period;
  final String? elapsed;
  final String? finishedTimestamp;
  final String? turn;  // NFL/CFB possession

  factory SportResultMessage.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

---

## Phase 7: Authentication

### 7.1 API Credentials Model (`api_credentials.dart`)
```dart
class ApiCredentials extends Equatable {
  final String apiKey;
  final String secret;
  final String passphrase;

  const ApiCredentials({
    required this.apiKey,
    required this.secret,
    required this.passphrase,
  });
}
```

### 7.2 L1 Authentication (`l1_auth.dart`)
- EIP-712 message signing
- Required headers: `POLY_ADDRESS`, `POLY_SIGNATURE`, `POLY_TIMESTAMP`, `POLY_NONCE`
- Used for creating/deriving API credentials

### 7.3 L2 Authentication (`l2_auth.dart`)
- HMAC-SHA256 signing using API secret
- Required headers: `POLY_ADDRESS`, `POLY_SIGNATURE`, `POLY_TIMESTAMP`, `POLY_API_KEY`, `POLY_PASSPHRASE`
- Used for authenticated CLOB operations

---

## Phase 8: Gamma API Client

### 8.1 Events Endpoint (`events_endpoint.dart`)
```dart
class EventsEndpoint {
  Future<List<Event>> listEvents({
    required int limit,
    required int offset,
    String? order,
    bool? ascending,
    List<int>? ids,
    List<String>? slugs,
    int? tagId,
    List<int>? excludeTagIds,
    bool? relatedTags,
    bool? featured,
    bool? cyom,
    bool? includeChat,
    bool? includeTemplate,
    String? recurrence,
    bool? closed,
    DateTime? startDateMin,
    DateTime? startDateMax,
    DateTime? endDateMin,
    DateTime? endDateMax,
  });

  Future<Event> getEventById(int id);
  Future<Event> getEventBySlug(String slug);
  Future<List<Tag>> getEventTags(int eventId);
}
```

### 8.2 Markets Endpoint (`markets_endpoint.dart`)
```dart
class MarketsEndpoint {
  Future<List<Market>> listMarkets({
    required int limit,
    required int offset,
    String? order,
    bool? ascending,
    List<int>? ids,
    List<String>? slugs,
    List<String>? clobTokenIds,
    List<String>? conditionIds,
    List<String>? marketMakerAddresses,
    double? liquidityNumMin,
    double? liquidityNumMax,
    double? volumeNumMin,
    double? volumeNumMax,
    DateTime? startDateMin,
    DateTime? startDateMax,
    DateTime? endDateMin,
    DateTime? endDateMax,
    int? tagId,
    bool? relatedTags,
    bool? cyom,
    String? umaResolutionStatus,
    String? gameId,
    List<String>? sportsMarketTypes,
    double? rewardsMinSize,
    List<String>? questionIds,
    bool? includeTag,
    bool? closed,
  });

  Future<Market> getMarketById(int id);
  Future<Market> getMarketBySlug(String slug);
  Future<List<Tag>> getMarketTags(int marketId);
}
```

### 8.3 Tags Endpoint (`tags_endpoint.dart`)
```dart
class TagsEndpoint {
  Future<List<Tag>> listTags({
    required int limit,
    required int offset,
    String? order,
    bool? ascending,
  });

  Future<Tag> getTagById(int id);
  Future<Tag> getTagBySlug(String slug);
  Future<List<Tag>> getRelatedTags(int tagId);
}
```

### 8.4 Sports Endpoint (`sports_endpoint.dart`)
```dart
class SportsEndpoint {
  Future<List<Team>> listTeams({
    required int limit,
    required int offset,
    String? order,
    bool? ascending,
    List<String>? leagues,
    List<String>? names,
    List<String>? abbreviations,
  });

  Future<SportMetadata> getSportsMetadata();
  Future<List<String>> getValidSportsMarketTypes();
}
```

### 8.5 Series Endpoint (`series_endpoint.dart`)
```dart
class SeriesEndpoint {
  Future<List<Series>> listSeries({
    required int limit,
    required int offset,
    String? order,
    bool? ascending,
    List<String>? slugs,
    List<int>? categoriesIds,
    List<String>? categoriesLabels,
    bool? closed,
    bool? includeChat,
    String? recurrence,
  });

  Future<Series> getSeriesById(int id);
}
```

### 8.6 Comments Endpoint (`comments_endpoint.dart`)
```dart
class CommentsEndpoint {
  Future<List<Comment>> listComments({
    required int limit,
    required int offset,
    String? order,
    bool? ascending,
    ParentEntityType? parentEntityType,
    int? parentEntityId,
    bool? getPositions,
    bool? holdersOnly,
  });

  Future<Comment> getCommentById(String id);
  Future<List<Comment>> getCommentsByUserAddress(String address);
}
```

### 8.7 Profiles Endpoint (`profiles_endpoint.dart`)
```dart
class ProfilesEndpoint {
  Future<Profile> getPublicProfile(String walletAddress);
}
```

### 8.8 Search Endpoint (`search_endpoint.dart`)
```dart
class SearchEndpoint {
  Future<SearchResult> search({
    required String query,
    bool? cache,
    String? eventsStatus,
    int? limitPerType,
    int? page,
    List<String>? eventsTags,
    int? keepClosedMarkets,
    String? sort,
    bool? ascending,
    bool? searchTags,
    bool? searchProfiles,
    String? recurrence,
    List<int>? excludeTagIds,
    bool? optimized,
  });
}
```

---

## Phase 9: CLOB API Client

### 9.1 Orderbook Endpoint (`orderbook_endpoint.dart`)
```dart
class OrderbookEndpoint {
  Future<OrderBook> getOrderBook(String tokenId);
  Future<List<OrderBook>> getOrderBooks(List<String> tokenIds);
}
```

### 9.2 Pricing Endpoint (`pricing_endpoint.dart`)
```dart
class PricingEndpoint {
  Future<Price> getPrice(String tokenId, OrderSide side);
  Future<Map<String, Price>> getPrices(List<String> tokenIds, OrderSide side);
  Future<Midpoint> getMidpoint(String tokenId);
  Future<List<PriceHistory>> getPriceHistory(String tokenId);
}
```

### 9.3 Spreads Endpoint (`spreads_endpoint.dart`)
```dart
class SpreadsEndpoint {
  Future<Map<String, Spread>> getSpreads(List<String> tokenIds);
}
```

### 9.4 Orders Endpoint (`orders_endpoint.dart`)
```dart
class OrdersEndpoint {
  // Requires L2 authentication
  Future<Order> placeOrder(OrderRequest request);
  Future<List<Order>> placeOrders(List<OrderRequest> requests);
  Future<void> cancelOrder(String orderId);
  Future<void> cancelOrders(List<String> orderIds);
  Future<void> cancelAllOrders();
  Future<void> cancelMarketOrders(String marketId);
  Future<List<Order>> getOpenOrders();
}
```

---

## Phase 10: Data API Client

### 10.1 Positions Endpoint (`positions_endpoint.dart`)
```dart
class PositionsEndpoint {
  Future<List<Position>> getPositions({
    required String userAddress,
    List<String>? markets,
    List<int>? eventIds,
    double? sizeThreshold,
    bool? redeemable,
    bool? mergeable,
    int? limit,
    int? offset,
    SortBy? sortBy,
    SortDirection? sortDirection,
    String? title,
  });
}
```

### 10.2 Trades Endpoint (`trades_endpoint.dart`)
```dart
class TradesEndpoint {
  Future<List<TradeRecord>> getTrades({
    String? user,
    List<String>? markets,
    List<int>? eventIds,
    int? limit,
    int? offset,
    bool? takerOnly,
    FilterType? filterType,
    double? filterAmount,
    OrderSide? side,
  });
}
```

### 10.3 Additional Endpoints
- `ActivityEndpoint` - User activity
- `HoldersEndpoint` - Top holders for markets
- `LeaderboardEndpoint` - Trader rankings

---

## Phase 11: WebSocket Clients

### 11.1 CLOB WebSocket (`clob_websocket.dart`)
```dart
class ClobWebSocket {
  final String url = 'wss://ws-subscriptions-clob.polymarket.com/ws/';

  // Market Channel (public)
  Stream<BookMessage> subscribeToBooks(List<String> assetIds);
  Stream<PriceChangeMessage> subscribeToPriceChanges(List<String> assetIds);
  Stream<LastTradePriceMessage> subscribeToLastTradePrices(List<String> assetIds);
  Stream<TickSizeChangeMessage> subscribeToTickSizeChanges(List<String> assetIds);
  Stream<BestBidAskMessage> subscribeToBestBidAsk(List<String> assetIds);

  // User Channel (authenticated)
  Stream<WsTradeMessage> subscribeToUserTrades(List<String> conditionIds, ApiCredentials credentials);
  Stream<WsOrderMessage> subscribeToUserOrders(List<String> conditionIds, ApiCredentials credentials);

  // Subscription management
  void subscribe(List<String> assetIds);
  void unsubscribe(List<String> assetIds);
  void disconnect();
}
```

### 11.2 RTDS WebSocket (`rtds_websocket.dart`)
```dart
class RtdsWebSocket {
  final String url = 'wss://ws-live-data.polymarket.com';

  // Crypto Prices (no auth)
  Stream<CryptoPriceMessage> subscribeToCryptoPrices({bool chainlink = false});

  // Comments (optional gamma auth)
  Stream<CommentMessage> subscribeToComments({String? walletAddress});

  // Subscription management
  void subscribe(RtdsSubscription subscription);
  void unsubscribe(RtdsSubscription subscription);
  void disconnect();
}
```

### 11.3 Sports WebSocket (`sports_websocket.dart`)
```dart
class SportsWebSocket {
  final String url = 'wss://sports-api.polymarket.com/ws';

  // Auto-broadcasts all sports events (no subscription needed)
  Stream<SportResultMessage> connect();
  void disconnect();
}
```

---

## Phase 12: Main Client

### 12.1 Polymarket Client (`polybrainz_polymarket.dart`)
```dart
class PolymarketClient {
  final GammaClient gamma;
  final ClobClient clob;
  final DataClient data;
  final ClobWebSocket clobWebSocket;
  final RtdsWebSocket rtdsWebSocket;
  final SportsWebSocket sportsWebSocket;

  PolymarketClient({
    ApiCredentials? credentials,
    String? privateKey,
  });

  // Factory for unauthenticated usage (Gamma + public CLOB only)
  factory PolymarketClient.public();

  // Factory for authenticated usage
  factory PolymarketClient.authenticated({
    required ApiCredentials credentials,
  });
}
```

---

## Phase 13: Testing

### 13.1 Unit Tests
- Model serialization/deserialization
- Enum conversions
- Helper methods

### 13.2 Integration Tests
- API endpoint tests with mocked HTTP
- WebSocket tests with mocked connections
- Authentication flow tests

### 13.3 Example Usage
```dart
// Public usage
final client = PolymarketClient.public();

// Get active events
final events = await client.gamma.events.listEvents(
  limit: 100,
  offset: 0,
  closed: false,
);

// Get order book
final orderBook = await client.clob.orderbook.getOrderBook(tokenId);

// Stream price changes
client.clobWebSocket.subscribeToPriceChanges([tokenId]).listen((change) {
  print('Price changed: ${change.priceChanges}');
});

// Authenticated usage
final authClient = PolymarketClient.authenticated(
  credentials: ApiCredentials(
    apiKey: 'your-api-key',
    secret: 'your-secret',
    passphrase: 'your-passphrase',
  ),
);

// Get positions
final positions = await authClient.data.positions.getPositions(
  userAddress: '0x...',
);
```

---

## Implementation Order

1. **Phase 1**: Core infrastructure (constants, exceptions, base clients)
2. **Phase 2**: Enums
3. **Phase 3**: Gamma models
4. **Phase 4**: CLOB models
5. **Phase 5**: Data API models
6. **Phase 6**: WebSocket models
7. **Phase 7**: Authentication
8. **Phase 8**: Gamma API endpoints
9. **Phase 9**: CLOB API endpoints
10. **Phase 10**: Data API endpoints
11. **Phase 11**: WebSocket clients
12. **Phase 12**: Main client integration
13. **Phase 13**: Testing and examples

---

## Dependencies Summary

| Package | Version | Purpose |
|---------|---------|---------|
| http | ^1.2.0 | HTTP requests |
| web_socket_channel | ^3.0.0 | WebSocket connections |
| crypto | ^3.0.3 | HMAC-SHA256 for L2 auth |
| convert | ^3.1.1 | Base64 encoding |
| equatable | ^2.0.5 | Value equality for models |
| json_annotation | ^4.9.0 | JSON serialization annotations |
| build_runner | ^2.4.0 | Code generation (dev) |
| json_serializable | ^6.8.0 | JSON code generation (dev) |
| test | ^1.25.6 | Testing (dev) |
| mockito | ^5.4.0 | Mocking (dev) |

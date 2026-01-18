# polybrainz_polymarket

A comprehensive Dart SDK for the [Polymarket](https://polymarket.com) prediction market APIs.

## Features

- **Gamma API** - Market discovery, events, tags, comments, profiles, search, leaderboard
- **CLOB API** - Order book, pricing, order management, trade history
- **Data API** - Positions, trades, activity, holders, leaderboard
- **WebSocket** - Real-time order book updates, price changes, user notifications
- **Authentication** - L1 (EIP-712) and L2 (HMAC-SHA256) authentication support
- **Type-safe** - Full Dart type safety with JSON serialization
- **Category Enums** - Strongly-typed enums for all market categories and subcategories
- **Category Detection** - Automatic category detection from events, markets, and tags
- **Type-Safe Enums** - Enum getters on all models for `side`, `status`, `outcome`, `type` fields
- **Legacy Maps** - `toLegacyMap()` on all models for simplified Map output
- **Error handling** - Comprehensive exception hierarchy and Result types

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  polybrainz_polymarket: ^1.3.0
```

Then run:

```bash
dart pub get
```

## Quick Start

### Public Client (No Authentication)

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  // Create a public client
  final client = PolymarketClient.public();

  // Get active events
  final events = await client.gamma.events.listEvents(
    limit: 10,
    closed: false,
  );

  for (final event in events) {
    print('${event.title} - ${event.markets.length} markets');
  }

  // Get order book for a token
  final book = await client.clob.orderbook.getOrderBook('your-token-id');
  print('Best bid: ${book.bestBid}, Best ask: ${book.bestAsk}');

  // Clean up
  client.close();
}
```

### Authenticated Client (For Trading)

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  // Create an authenticated client
  final client = PolymarketClient.authenticated(
    credentials: ApiCredentials(
      apiKey: 'your-api-key',
      secret: 'your-secret',
      passphrase: 'your-passphrase',
    ),
    funder: '0xYourWalletAddress',
  );

  // Get your open orders
  final orders = await client.clob.orders.getOpenOrders();
  print('You have ${orders.length} open orders');

  // Get your positions
  final positions = await client.data.positions.getPositions(
    userAddress: '0xYourWalletAddress',
  );

  for (final pos in positions) {
    print('${pos.title}: ${pos.size} shares @ ${pos.avgPrice}');
  }

  client.close();
}
```

### Real-Time Data with WebSocket

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  final client = PolymarketClient.public();

  // Connect to WebSocket
  await client.clobWebSocket.connect();

  // Subscribe to price changes
  client.clobWebSocket.subscribeToPriceChanges(['token-id-1', 'token-id-2'])
    .listen((msg) {
      for (final change in msg.priceChanges) {
        print('${change.assetId}: ${change.price}');
      }
    });

  // Subscribe to order book updates
  client.clobWebSocket.subscribeToOrderBook('token-id')
    .listen((book) {
      print('Best bid: ${book.bestBid}, Best ask: ${book.bestAsk}');
    });

  // For crypto prices
  await client.rtdsWebSocket.connect(topics: [RtdsTopic.cryptoPrices]);
  client.rtdsWebSocket.cryptoPrices.listen((msg) {
    print('BTC: ${msg.getPrice('BTC')}, ETH: ${msg.getPrice('ETH')}');
  });
}
```

## API Reference

### PolymarketClient

The main entry point for all API access.

| Factory | Description |
|---------|-------------|
| `PolymarketClient.public()` | Public client, no authentication |
| `PolymarketClient.authenticated()` | Authenticated client with API credentials |
| `PolymarketClient.withPrivateKey()` | Client with private key for deriving credentials |

### Gamma API (Market Discovery)

```dart
// Events
final events = await client.gamma.events.listEvents(limit: 100, closed: false);
final event = await client.gamma.events.getById(123);
final event = await client.gamma.events.getBySlug('event-slug');

// Markets
final markets = await client.gamma.markets.listMarkets(active: true);
final market = await client.gamma.markets.getByConditionId('condition-id');

// Tags
final tags = await client.gamma.tags.listTags();
final related = await client.gamma.tags.getRelatedTags(tagId);

// Search
final results = await client.gamma.search.search(query: 'bitcoin');

// Profiles
final profile = await client.gamma.profiles.getByAddress('0x...');

// Comments
final comments = await client.gamma.comments.listComments(
  parentEntityType: ParentEntityType.market,
  parentEntityId: 123,
);

// Leaderboard
final leaders = await client.gamma.leaderboard.getTopByProfit(limit: 10);

// Convenience methods
final hotEvents = await client.gamma.events.getHotEvents();
final featuredEvents = await client.gamma.events.getFeaturedEvents();
final politicsEvents = await client.gamma.events.getByTagSlug('politics');
final endingSoon = await client.gamma.events.getEndingSoon(within: Duration(days: 3));
```

### CLOB API (Order Book & Trading)

```dart
// Order Book
final book = await client.clob.orderbook.getOrderBook('token-id');
final books = await client.clob.orderbook.getOrderBooks(['token-1', 'token-2']);

// Pricing
final price = await client.clob.pricing.getPrice('token-id', OrderSide.buy);
final midpoint = await client.clob.pricing.getMidpoint('token-id');
final spread = await client.clob.pricing.getSpread('token-id');
final history = await client.clob.pricing.getPriceHistory('token-id');

// Orders (requires authentication)
final response = await client.clob.orders.postOrder(signedOrder);
final orders = await client.clob.orders.getOpenOrders();
await client.clob.orders.cancelOrder('order-id');
await client.clob.orders.cancelAllOrders();

// Trades
final trades = await client.clob.trades.getTrades(market: 'condition-id');
```

### Data API (Analytics)

```dart
// Positions
final positions = await client.data.positions.getPositions(
  userAddress: '0x...',
  sortBy: SortBy.value,
  sortDirection: SortDirection.desc,
);
final closed = await client.data.positions.getClosedPositions(userAddress: '0x...');

// Trades
final trades = await client.data.trades.getUserTrades(userAddress: '0x...');
final marketTrades = await client.data.trades.getMarketTrades(conditionId: 'cond-id');

// Activity
final activity = await client.data.activity.getUserActivity(
  userAddress: '0x...',
  types: [ActivityType.trade, ActivityType.redeem],
);

// Holders
final holders = await client.data.holders.getTokenHolders(tokenId: 'token-id');

// Portfolio Value
final value = await client.data.value.getValue('0x...');
print('Total: ${value.totalValue}, PnL: ${value.totalPnl}');

// Leaderboard
final leaders = await client.data.leaderboard.getLeaderboard(
  window: LeaderboardWindow.day7,
  type: LeaderboardType.profit,
);
```

### WebSocket Streams

```dart
// CLOB WebSocket
await client.clobWebSocket.connect();

// Market data (public)
client.clobWebSocket.subscribeToMarket(['token-id']);
client.clobWebSocket.bookUpdates.listen((book) => print(book));
client.clobWebSocket.priceChanges.listen((price) => print(price));
client.clobWebSocket.lastTradePrices.listen((trade) => print(trade));

// User data (requires auth)
client.clobWebSocket.subscribeToUser(['token-id']);
client.clobWebSocket.userOrders.listen((order) => print(order));
client.clobWebSocket.userTrades.listen((trade) => print(trade));

// RTDS WebSocket
await client.rtdsWebSocket.connect(topics: [RtdsTopic.cryptoPrices, RtdsTopic.comments]);
client.rtdsWebSocket.cryptoPrices.listen((msg) => print(msg));
client.rtdsWebSocket.comments.listen((comment) => print(comment));
```

## Authentication

### Using Existing API Credentials

If you already have API credentials:

```dart
final client = PolymarketClient.authenticated(
  credentials: ApiCredentials(
    apiKey: 'your-api-key',
    secret: 'your-secret',
    passphrase: 'your-passphrase',
  ),
  funder: '0xYourWalletAddress',
);
```

### Deriving API Credentials (Requires web3dart)

To create or derive API credentials from a private key, you'll need to implement EIP-712 signing using a library like `web3dart`:

```dart
final client = PolymarketClient.withPrivateKey(
  privateKey: '0xYourPrivateKey',
  walletAddress: '0xYourWalletAddress',
);

// This requires proper EIP-712 implementation
// await client.clob.auth.createOrDeriveApiKey();
```

> **Note**: L1 authentication (EIP-712 signing) is implemented as a placeholder. For production use, integrate with `web3dart` or a similar Ethereum signing library.

## Error Handling

The SDK provides typed exceptions for different error scenarios:

```dart
try {
  final orders = await client.clob.orders.getOpenOrders();
} on AuthenticationException catch (e) {
  print('Auth error: ${e.message}');
} on RateLimitException catch (e) {
  print('Rate limited, retry after: ${e.retryAfter}');
} on ApiException catch (e) {
  print('API error ${e.statusCode}: ${e.message}');
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on PolymarketException catch (e) {
  print('Error: ${e.message}');
}
```

## Category Detection

The SDK includes comprehensive category enums and automatic detection utilities.

### Available Categories

| Category | Subcategory Enum |
|----------|------------------|
| `MarketCategory.politics` | `PoliticsSubcategory` |
| `MarketCategory.sports` | `SportsSubcategory` |
| `MarketCategory.crypto` | `CryptoSubcategory` |
| `MarketCategory.popCulture` | `PopCultureSubcategory` |
| `MarketCategory.business` | `BusinessSubcategory` |
| `MarketCategory.science` | `ScienceSubcategory` |

### Detecting Categories

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

// Detect from a single event
final result = CategoryDetector.detectFromEvent(event);
print(result.category);       // MarketCategory.politics
print(result.subcategories);  // [PoliticsSubcategory.usPresidential]
print(result.tagSlugs);       // ['politics', 'us-presidential', 'trump']

// Detect from markets list
final markets = await client.gamma.markets.listMarkets(limit: 100);
final categories = markets.detectCategories();  // Extension method

// Group by category
final grouped = markets.groupByCategory();
for (final entry in grouped.entries) {
  print('${entry.key.label}: ${entry.value.length} markets');
}

// Get unique categories
final unique = markets.uniqueCategories;  // Set<MarketCategory>

// Filter by category using tag slugs
final cryptoMarkets = await client.gamma.markets.getByTagSlug('crypto');
final politicsEvents = await client.gamma.events.getByTagSlug('politics');
```

### Using Category Enums

```dart
// Get all available categories
final categories = CategoryDetector.getAllCategories();

// Get subcategories for a category
final sportsSubcats = CategoryDetector.getSubcategoriesFor(MarketCategory.sports);
// Returns: [SportsSubcategory.nfl, SportsSubcategory.nba, ...]

// Use category slug for filtering
final events = await client.gamma.events.listEvents(
  tagSlug: MarketCategory.crypto.slug,  // 'crypto'
);

// Use subcategory slug
final nflEvents = await client.gamma.events.listEvents(
  tagSlug: SportsSubcategory.nfl.slug,  // 'nfl'
);
```

## Type-Safe Enums

All models with string fields representing fixed values now have type-safe enum getters.

### Using Enum Getters

```dart
// Order side and status
final order = await client.clob.orders.getOrder('order-id');
if (order.sideEnum == OrderSide.buy) {
  print('This is a buy order');
}
if (order.statusEnum?.isActive ?? false) {
  print('Order is still active');
}

// Trade status with helper methods
final trade = trades.first;
if (trade.statusEnum.isTerminal) {
  print('Trade is complete');
}

// Outcome type
final position = positions.first;
if (position.outcomeEnum == OutcomeType.yes) {
  print('Holding YES tokens');
  print('Opposite: ${position.oppositeOutcomeEnum}'); // OutcomeType.no
}

// Game status for sports events
final event = await client.gamma.events.getById(123);
if (event.gameStatusEnum?.isLive ?? false) {
  print('Game is currently in progress!');
}

// Market prices
final market = markets.first;
print('YES: ${market.yesPrice}, NO: ${market.noPrice}');

// Type-safe ordering
final topMarkets = await client.gamma.markets.listMarkets(
  order: MarketOrderBy.volume24hr,  // Type-safe!
  ascending: false,
  limit: 20,
);

final recentEvents = await client.gamma.events.listEvents(
  order: EventOrderBy.createdAt,
  ascending: false,
  limit: 10,
);
```

### Available Enums

| Enum | Values | Helper Methods |
|------|--------|----------------|
| `OutcomeType` | `yes`, `no` | `opposite`, `isYes`, `isNo` |
| `OrderSide` | `buy`, `sell` | `opposite` |
| `OrderType` | `gtc`, `gtd`, `fok`, `fak` | - |
| `OrderStatus` | `live`, `matched`, `filled`, `cancelled`, `pending`, `delayed` | `isActive`, `isTerminal`, `isCancellable` |
| `TradeStatus` | `mined`, `confirmed`, `retrying`, `failed` | `isTerminal`, `isPending` |
| `GameStatus` | `scheduled`, `inProgress`, `halftime`, `ended`, `postponed`, `cancelled`, `suspended` | `isLive`, `isFinished`, `isUpcoming`, `isInterrupted` |
| `ActivityType` | `trade`, `split`, `merge`, `redeem`, `deposit`, `withdraw` | - |
| `MarketOrderBy` | `volume`, `volume24hr`, `liquidity`, `endDate`, `startDate`, `createdAt` | - |
| `EventOrderBy` | `volume`, `startDate`, `endDate`, `createdAt`, `liquidity` | - |

### toLegacyMap()

All models have a `toLegacyMap()` method that returns a simplified `Map<String, dynamic>`:

```dart
final market = markets.first;
final map = market.toLegacyMap();
// Returns a Map with parsed numeric values and simplified structure
print(map['yesPrice']);  // double instead of String
print(map['volume']);    // double instead of String
```

## Key Concepts

### Token IDs vs Condition IDs

- **Condition ID**: Identifies a market (e.g., "Will X happen?")
- **Token ID**: Identifies a specific outcome token (Yes or No)
- A market has ONE condition ID but TWO token IDs

### Order Types

| Type | Description |
|------|-------------|
| GTC | Good Till Cancelled - rests on book until filled or cancelled |
| GTD | Good Till Date - expires at specified timestamp |
| FOK | Fill or Kill - must fill completely immediately or cancel |
| FAK | Fill and Kill (IOC) - fill what you can, cancel rest |

### Negative Risk

Some markets support "negative risk" where Yes + No tokens can be merged/split for capital efficiency. Check the `negRisk` field on markets.

## Examples

See the [example](example/) directory for complete examples:

- [Basic Usage](example/polybrainz_polymarket_example.dart) - Simple API calls
- [WebSocket Streaming](example/websocket_example.dart) - Real-time data
- [Trading](example/trading_example.dart) - Order management

## API Documentation

- [Polymarket Gamma API](https://docs.polymarket.com/developers/gamma-markets-api/overview)
- [Polymarket CLOB API](https://docs.polymarket.com/developers/clob-api/overview)
- [Polymarket Data API](https://docs.polymarket.com/developers/data-api/overview)

## License

MIT License - see [LICENSE](LICENSE) for details.

<div align="center">

# PolyBrainZ Polymarket

### A Comprehensive Dart SDK for Polymarket Prediction Markets

[![Dart SDK](https://img.shields.io/badge/Dart-%5E3.9.2-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Version](https://img.shields.io/badge/version-3.0.0-blue)](https://github.com/mayankjanmejay/PolyBrainZ_Polymarket/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Full-featured** | **Type-safe** | **Live Trading** | **Real-time WebSocket**

[Installation](#installation) | [Quick Start](#quick-start) | [API Reference](#api-reference) | [Examples](#examples)

</div>

---

## Features

| Feature | Description |
|---------|-------------|
| **Live Trading** | Order signing, submission, wallet management, blockchain operations |
| **Gamma API** | Market discovery, events, tags, comments, profiles, search, leaderboard |
| **CLOB API** | Order book, pricing, order management, trade history |
| **Data API** | Positions, trades, activity, holders, portfolio analytics |
| **WebSocket** | Real-time order book, prices, user notifications |
| **HD Wallet** | BIP-39/BIP-32/BIP-44 wallet generation and derivation |
| **EIP-712 Signing** | Full order and auth message signing |
| **Polygon Client** | USDC/MATIC balance, transfers, approvals |
| **40+ Type-safe Enums** | Every string parameter with known values is a compile-time enum |
| **Category Detection** | Auto-detect categories from events, markets, and tags |

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  polybrainz_polymarket: ^3.0.0
```

```bash
dart pub get
```

---

## Quick Start

<details open>
<summary><strong>Public Client (No Auth Required)</strong></summary>

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  final client = PolymarketClient.public();

  // Get active events
  final events = await client.gamma.events.listEvents(
    limit: 10,
    closed: false,
  );

  for (final event in events) {
    print('${event.title} - ${event.markets.length} markets');
  }

  // Get order book
  final book = await client.clob.orderbook.getOrderBook('token-id');
  print('Best bid: ${book.bestBid}, Best ask: ${book.bestAsk}');

  client.close();
}
```

</details>

<details>
<summary><strong>Authenticated Client (For Trading)</strong></summary>

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
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

</details>

<details>
<summary><strong>Real-Time WebSocket Streams</strong></summary>

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  final client = PolymarketClient.public();

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

  // Crypto prices via RTDS
  await client.rtdsWebSocket.connect(topics: [RtdsTopic.cryptoPrices]);
  client.rtdsWebSocket.cryptoPrices.listen((msg) {
    print('BTC: ${msg.getPrice('BTC')}, ETH: ${msg.getPrice('ETH')}');
  });
}
```

</details>

---

## API Reference

### Client Factories

| Factory | Description |
|---------|-------------|
| `PolymarketClient.public()` | Public client, no authentication |
| `PolymarketClient.authenticated()` | Authenticated client with API credentials |
| `PolymarketClient.withPrivateKey()` | Client with private key for deriving credentials |
| `PolymarketClient.withTrading()` | **Full trading client** with order signing & blockchain ops |

---

### Trading (v2.0+)

<details open>
<summary><strong>Place Orders with Full Signing</strong></summary>

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  // Create trading-enabled client
  final client = PolymarketClient.withTrading(
    credentials: ApiCredentials(
      apiKey: 'your-api-key',
      secret: 'your-secret',
      passphrase: 'your-passphrase',
    ),
    walletAddress: '0xYourWalletAddress',
    privateKey: '0xYourPrivateKey',
  );

  // Place an order (builds, signs, submits in one call)
  final response = await client.placeOrder(
    tokenId: 'token-id',
    side: OrderSide.buy,
    size: 10.0,   // 10 shares
    price: 0.55,  // 55 cents
  );
  print('Order ID: ${response.orderId}');

  // Or build and sign manually for more control
  final signedOrder = client.buildSignedOrder(
    tokenId: 'token-id',
    side: OrderSide.sell,
    size: 5.0,
    price: 0.60,
    negRisk: false,  // Set true for negative risk markets
  );
  final result = await client.clob.orders.postOrder(
    signedOrder.toJson(),
    orderType: OrderType.gtc,
  );

  client.close();
}
```

</details>

<details>
<summary><strong>Wallet Generation & Management</strong></summary>

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() {
  // Generate a new HD wallet
  final mnemonic = HdWallet.generateMnemonic(); // 12 words
  final mnemonic24 = HdWallet.generateMnemonic(wordCount: 24);
  print('Mnemonic: $mnemonic');

  // Validate a mnemonic
  final isValid = HdWallet.validateMnemonic(mnemonic);
  print('Valid: $isValid');

  // Derive wallet from mnemonic
  final wallet = HdWallet.deriveWallet(mnemonic);
  print('Address: ${wallet.address}');
  print('Private Key: ${wallet.privateKey}');

  // Derive multiple wallets (different indices)
  final wallet0 = HdWallet.deriveWallet(mnemonic, index: 0);
  final wallet1 = HdWallet.deriveWallet(mnemonic, index: 1);
  final wallet2 = HdWallet.deriveWallet(mnemonic, index: 2);
}
```

</details>

<details>
<summary><strong>Polygon Blockchain Operations</strong></summary>

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  final client = PolymarketClient.withTrading(
    credentials: credentials,
    walletAddress: '0x...',
    privateKey: '0x...',
  );

  // Check balances
  final maticBalance = await client.polygon.getMaticBalance('0x...');
  final usdcBalance = await client.polygon.getUsdcBalance('0x...');
  print('MATIC: $maticBalance, USDC: $usdcBalance');

  // Check USDC allowance for trading
  final allowance = await client.polygon.getUsdcAllowance(
    owner: '0xYourAddress',
    spender: PolymarketConstants.exchangeAddress,
  );
  print('Allowance: $allowance');

  // Approve USDC for trading (if needed)
  final txHash = await client.polygon.approveUsdc(
    credentials: EthPrivateKey.fromHex('0x...'),
    spender: PolymarketConstants.exchangeAddress,
    amount: BigInt.from(1000000000), // 1000 USDC (6 decimals)
  );
  print('Approval TX: $txHash');

  // Wait for transaction confirmation
  final receipt = await client.polygon.waitForTransaction(txHash);
  print('Confirmed in block: ${receipt?.blockNumber}');

  client.close();
}
```

</details>

---

### Gamma API (Market Discovery)

<details open>
<summary><strong>Events & Markets</strong></summary>

```dart
// Events
final events = await client.gamma.events.listEvents(limit: 100, closed: false);
final event = await client.gamma.events.getById(123);
final event = await client.gamma.events.getBySlug('event-slug');

// Convenience methods
final hotEvents = await client.gamma.events.getHotEvents();
final featuredEvents = await client.gamma.events.getFeaturedEvents();
final endingSoon = await client.gamma.events.getEndingSoon(within: Duration(days: 3));
final politicsEvents = await client.gamma.events.getByTagSlug(TagSlug.politics);

// Markets
final markets = await client.gamma.markets.listMarkets(active: true);
final market = await client.gamma.markets.getByConditionId('condition-id');
final topVolume = await client.gamma.markets.getTopByVolume(limit: 20);
final topLiquidity = await client.gamma.markets.getTopByLiquidity();
```

</details>

<details>
<summary><strong>Search (Type-Safe Queries)</strong></summary>

```dart
// Preset queries (60+ available)
final results = await client.gamma.search.search(query: SearchQuery.bitcoin);
final election = await client.gamma.search.search(query: SearchQuery.election);
final nfl = await client.gamma.search.search(query: SearchQuery.nfl);

// Custom queries
final custom = await client.gamma.search.search(
  query: SearchQuery.custom('my search'),
);

// Convenience methods
final btcResults = await client.gamma.search.searchBitcoin();
final electionResults = await client.gamma.search.searchElection();
final aiResults = await client.gamma.search.searchAI();

// Browse all presets by category
SearchQuery.cryptoPresets;    // [bitcoin, ethereum, solana, ...]
SearchQuery.politicsPresets;  // [election, trump, biden, ...]
SearchQuery.sportsPresets;    // [nfl, nba, mlb, ...]
```

</details>

<details>
<summary><strong>Tags, Comments, Profiles</strong></summary>

```dart
// Tags
final tags = await client.gamma.tags.listTags(order: TagOrderBy.volume);
final related = await client.gamma.tags.getRelatedTags(tagId);

// Comments
final comments = await client.gamma.comments.listComments(
  parentEntityType: ParentEntityType.market,
  parentEntityId: 123,
  order: CommentOrderBy.createdAt,
);

// Profiles
final profile = await client.gamma.profiles.getByAddress('0x...');

// Leaderboard
final leaders = await client.gamma.leaderboard.getTopByProfit(limit: 10);
```

</details>

---

### CLOB API (Order Book & Trading)

<details>
<summary><strong>Order Book & Pricing</strong></summary>

```dart
// Order Book
final book = await client.clob.orderbook.getOrderBook('token-id');
final books = await client.clob.orderbook.getOrderBooks(['token-1', 'token-2']);

// Pricing
final price = await client.clob.pricing.getPrice('token-id', OrderSide.buy);
final midpoint = await client.clob.pricing.getMidpoint('token-id');
final spread = await client.clob.pricing.getSpread('token-id');
final history = await client.clob.pricing.getPriceHistory(
  'token-id',
  interval: PriceHistoryInterval.hour1,
);
```

</details>

<details>
<summary><strong>Orders & Trades (Requires Auth)</strong></summary>

```dart
// Orders
final response = await client.clob.orders.postOrder(signedOrder);
final orders = await client.clob.orders.getOpenOrders();
await client.clob.orders.cancelOrder('order-id');
await client.clob.orders.cancelAllOrders();

// Trades
final trades = await client.clob.trades.getTrades(market: 'condition-id');
```

</details>

---

### Data API (Analytics)

<details>
<summary><strong>Positions & Trades</strong></summary>

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
```

</details>

<details>
<summary><strong>Activity, Holders, Portfolio</strong></summary>

```dart
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

</details>

---

### WebSocket Streams

<details>
<summary><strong>Real-Time Data</strong></summary>

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

// RTDS WebSocket (crypto prices, comments)
await client.rtdsWebSocket.connect(topics: [RtdsTopic.cryptoPrices, RtdsTopic.comments]);
client.rtdsWebSocket.cryptoPrices.listen((msg) => print(msg));
client.rtdsWebSocket.comments.listen((comment) => print(comment));
```

</details>

---

## Type-Safe Enums

Every parameter with known values is a compile-time enum. No more typos or invalid strings!

<details open>
<summary><strong>Order By Enums</strong></summary>

| Enum | Values |
|------|--------|
| `MarketOrderBy` | `volume`, `volume24hr`, `liquidity`, `endDate`, `startDate`, `createdAt` |
| `EventOrderBy` | `volume`, `startDate`, `endDate`, `createdAt`, `liquidity` |
| `TagOrderBy` | `volume`, `eventsCount`, `createdAt`, `label` |
| `CommentOrderBy` | `createdAt`, `likes`, `replies`, `updatedAt` |
| `SeriesOrderBy` | `volume`, `startDate`, `endDate`, `createdAt`, `liquidity` |
| `SportsOrderBy` | `name`, `league`, `abbreviation`, `createdAt` |
| `SearchSort` | `relevance`, `volume`, `liquidity`, `startDate`, `endDate`, `createdAt` |
| `GammaLeaderboardOrderBy` | `profit`, `volume`, `marketsTraded` |

</details>

<details>
<summary><strong>Status & Type Enums</strong></summary>

| Enum | Values | Helper Methods |
|------|--------|----------------|
| `OutcomeType` | `yes`, `no` | `opposite`, `isYes`, `isNo` |
| `OrderSide` | `buy`, `sell` | `opposite` |
| `OrderType` | `gtc`, `gtd`, `fok`, `fak` | - |
| `TickSize` | `cent`, `tenthCent`, `hundredthCent` | `value` (double) |
| `NegRiskFlag` | `standard`, `negRisk` | `value` (bool) |
| `TimeInForce` | `gtc`, `gtd`, `fok`, `ioc` | - |
| `OrderStatus` | `live`, `matched`, `filled`, `cancelled`, `pending`, `delayed` | `isActive`, `isTerminal`, `isCancellable` |
| `TradeStatus` | `mined`, `confirmed`, `retrying`, `failed` | `isTerminal`, `isPending` |
| `GameStatus` | `scheduled`, `inProgress`, `halftime`, `ended`, `postponed`, `cancelled`, `suspended` | `isLive`, `isFinished`, `isUpcoming`, `isInterrupted` |
| `EventsStatus` | `active`, `closed`, `all` | - |
| `RecurrenceType` | `daily`, `weekly`, `monthly`, `yearly`, `none` | `isRecurring` |
| `UmaResolutionStatus` | `pending`, `proposed`, `disputed`, `resolved` | `isTerminal`, `isInProgress`, `hasStarted` |
| `SortDirection` | `asc`, `desc` | `opposite` |
| `PriceHistoryInterval` | `minute1`, `minute5`, ... `hour1`, `hour4`, ... `day1`, `week1`, `max` | - |

</details>

<details>
<summary><strong>Category Enums</strong></summary>

| Category | Subcategory Enum |
|----------|------------------|
| `MarketCategory.politics` | `PoliticsSubcategory` |
| `MarketCategory.sports` | `SportsSubcategory` |
| `MarketCategory.crypto` | `CryptoSubcategory` |
| `MarketCategory.popCulture` | `PopCultureSubcategory` |
| `MarketCategory.business` | `BusinessSubcategory` |
| `MarketCategory.science` | `ScienceSubcategory` |

</details>

<details>
<summary><strong>SearchQuery Sealed Class (60+ Presets)</strong></summary>

| Category | Presets |
|----------|---------|
| **Crypto** | `bitcoin`, `ethereum`, `solana`, `crypto`, `defi`, `nft`, `memecoin`, `altcoin` |
| **Politics** | `election`, `trump`, `biden`, `president`, `congress`, `senate`, `supremeCourt`, `policy` |
| **Sports** | `nfl`, `nba`, `mlb`, `nhl`, `soccer`, `ufc`, `boxing`, `tennis`, `golf`, `olympics`, `superBowl`, `worldCup` |
| **Entertainment** | `oscars`, `grammys`, `emmys`, `movies`, `tv`, `music`, `celebrity`, `taylorSwift`, `streaming` |
| **Business** | `stocks`, `fed`, `interestRates`, `inflation`, `recession`, `ipo`, `tesla`, `apple`, `google`, `amazon`, `microsoft`, `elonMusk` |
| **Science/Tech** | `ai`, `openai`, `chatgpt`, `spacex`, `nasa`, `climate`, `space`, `mars` |
| **World** | `war`, `ukraine`, `russia`, `china`, `israel`, `middleEast` |

</details>

<details>
<summary><strong>TagSlug Sealed Class (130+ Presets)</strong></summary>

| Category | Presets |
|----------|---------|
| **Politics** | `politics`, `usElections`, `usPresidential`, `usSenate`, `usHouse`, `usGovernors`, `trump`, `biden`, `harris`, `congress`, `supremeCourt` |
| **Sports** | `sports`, `nfl`, `nba`, `mlb`, `nhl`, `mls`, `wnba`, `collegeSports`, `soccer`, `golf`, `tennis`, `mma`, `boxing`, `f1`, `nascar` |
| **Crypto** | `crypto`, `bitcoin`, `ethereum`, `solana`, `xrp`, `cardano`, `dogecoin`, `defi`, `nft`, `stablecoins`, `layer2` |
| **Business** | `business`, `stocks`, `stockMarket`, `fed`, `interestRates`, `inflation`, `recession`, `ipo`, `mergers`, `earnings` |
| **Entertainment** | `popCulture`, `oscars`, `grammys`, `emmys`, `movies`, `tv`, `music`, `celebrity`, `streaming`, `gaming`, `esports` |
| **Science/Tech** | `science`, `technology`, `ai`, `openai`, `anthropic`, `google`, `apple`, `microsoft`, `spacex`, `nasa`, `climate` |
| **World** | `globalElections`, `geopolitics`, `ukraine`, `russia`, `china`, `middleEast`, `nato`, `unitedNations` |

```dart
// Using presets (compile-time safe)
final events = await client.gamma.events.getByTagSlug(TagSlug.crypto);
final markets = await client.gamma.markets.listMarkets(tagSlug: TagSlug.nfl);

// Custom tags (for user-created tags)
final custom = await client.gamma.tags.getBySlug(TagSlug.custom('my-custom-tag'));

// Get TagSlug from Tag model
final tag = await client.gamma.tags.getById(123);
final slug = tag.slugEnum;  // TagSlug (preset or custom)
final preset = tag.slugPreset;  // TagSlug? (only if matches a preset)
```

</details>

---

## Category Detection

<details>
<summary><strong>Automatic Category Detection</strong></summary>

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

// Detect from a single event
final result = CategoryDetector.detectFromEvent(event);
print(result.category);       // MarketCategory.politics
print(result.subcategories);  // [PoliticsSubcategory.usPresidential]
print(result.tagSlugs);       // ['politics', 'us-presidential', 'trump']

// Extension methods on lists
final markets = await client.gamma.markets.listMarkets(limit: 100);
final categories = markets.detectCategories();
final unique = markets.uniqueCategories;  // Set<MarketCategory>

// Group by category
final grouped = markets.groupByCategory();
for (final entry in grouped.entries) {
  print('${entry.key.label}: ${entry.value.length} markets');
}

// Filter by category using TagSlug (130+ presets)
final cryptoMarkets = await client.gamma.markets.getByTagSlug(TagSlug.crypto);
final nflEvents = await client.gamma.events.listEvents(
  tagSlug: TagSlug.nfl,
);
```

</details>

---

## Authentication

<details>
<summary><strong>Using Existing API Credentials</strong></summary>

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

</details>

<details>
<summary><strong>Deriving API Credentials</strong></summary>

```dart
final client = PolymarketClient.withPrivateKey(
  privateKey: '0xYourPrivateKey',
  walletAddress: '0xYourWalletAddress',
);

// Create or derive API key using EIP-712 L1 auth
await client.clob.auth?.createOrDeriveApiKey();

// Now the client has credentials and can trade
final orders = await client.clob.orders.getOpenOrders();
```

</details>

---

## Error Handling

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

---

## Key Concepts

<details>
<summary><strong>Token IDs vs Condition IDs</strong></summary>

| Concept | Description |
|---------|-------------|
| **Condition ID** | Identifies a market (e.g., "Will X happen?") |
| **Token ID** | Identifies a specific outcome token (Yes or No) |

A market has **ONE** condition ID but **TWO** token IDs.

</details>

<details>
<summary><strong>Order Types</strong></summary>

| Type | Description |
|------|-------------|
| `GTC` | Good Till Cancelled - rests on book until filled or cancelled |
| `GTD` | Good Till Date - expires at specified timestamp |
| `FOK` | Fill or Kill - must fill completely immediately or cancel |
| `FAK` | Fill and Kill (IOC) - fill what you can, cancel rest |

</details>

<details>
<summary><strong>Negative Risk</strong></summary>

Some markets support "negative risk" where Yes + No tokens can be merged/split for capital efficiency. Check the `negRisk` field on markets.

</details>

---

## Examples

See the [example/](example/) directory:

| Example | Description |
|---------|-------------|
| [Basic Usage](example/polybrainz_polymarket_example.dart) | Simple API calls |
| [WebSocket Streaming](example/websocket_example.dart) | Real-time data |
| [Trading](example/trading_example.dart) | Order management |
| [Market Discovery](example/market_discovery_example.dart) | Search & category detection |

---

## Resources

| Resource | Link |
|----------|------|
| Polymarket Gamma API | [docs.polymarket.com/.../gamma-markets-api](https://docs.polymarket.com/developers/gamma-markets-api/overview) |
| Polymarket CLOB API | [docs.polymarket.com/.../clob-api](https://docs.polymarket.com/developers/clob-api/overview) |
| Polymarket Data API | [docs.polymarket.com/.../data-api](https://docs.polymarket.com/developers/data-api/overview) |

---

<div align="center">

**MIT License** - see [LICENSE](LICENSE) for details

Made with Dart

</div>

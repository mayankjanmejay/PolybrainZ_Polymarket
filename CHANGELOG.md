# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [2.0.2] - 2026-01-23

### Fixed

- Fixed `ClobRewards.rates` type to accept both `List` and `Map` from API response
- Added comprehensive test suite for trading extension (93 tests total)
  - HD wallet generation and derivation tests
  - Order builder tests
  - EIP-712 signing tests
  - Live API integration tests

## [2.0.1] - 2026-01-23

- Updated Dependencies

### Changed

- Updated repository URL to `https://github.com/mayankjanmejay/PolybrainZ_Polymarket/` 

## [2.0.0] - 2026-01-23

### Added

#### Live Trading Extension - Full Trading Capabilities!

**New Factory Constructor:**
- `PolymarketClient.withTrading()` - Create a trading-enabled client with order signing and blockchain operations

**New Convenience Methods on PolymarketClient:**
- `buildSignedOrder()` - Build and sign an order ready for submission
- `placeOrder()` - Build, sign, and submit an order in one call
- `polygon` getter - Access Polygon blockchain operations
- `hasTradingCapabilities` - Check if trading is enabled

**New Wallet Module (`lib/src/wallet/`):**
- `HdWallet` - HD wallet generation and derivation
  - `generateMnemonic()` - Generate BIP-39 mnemonic (12 or 24 words)
  - `validateMnemonic()` - Validate mnemonic phrase
  - `deriveWallet()` - Derive wallet from mnemonic using BIP-44 path
- `WalletCredentials` - Container for address, private key, derivation index
- `PolygonClient` - Polygon blockchain operations
  - `getMaticBalance()` - Get MATIC balance
  - `getUsdcBalance()` - Get USDC balance
  - `transferUsdc()` - Transfer USDC to address
  - `approveUsdc()` - Approve USDC spending for CTF Exchange
  - `getUsdcAllowance()` - Check current USDC allowance
  - `waitForTransaction()` - Wait for transaction confirmation

**New EIP-712 Signing Module (`lib/src/clob/signing/`):**
- `EIP712Signer` - Sign orders and auth messages with EIP-712
  - `signOrder()` - Sign order for CLOB submission
  - `signAuth()` - Sign authentication message for L1 auth
- `TypedDataBuilder` - Build EIP-712 typed data structures

**New Order Building Module (`lib/src/clob/orders/`):**
- `OrderStruct` - Raw order structure matching CLOB contract
  - `toJson()` - Convert to JSON for API submission
  - `toTypedDataMessage()` - Convert to EIP-712 typed data
  - `price` / `size` getters - Human-readable price and size
- `OrderBuilder` - Build limit and market orders
  - `buildLimitOrder()` - Build a limit order with price/size
  - `buildMarketOrder()` - Build a market order

**New Trading Models:**
- `SignedOrder` - Order with signature ready for submission
- `CancelAllResponse` - Response from bulk cancel operations
- `CancelFailure` - Details of failed cancellation
- `CancelResult` - Result of single order cancellation
- `OrderScoringResponse` - Check if order is scoring rewards

**New Trading Enums:**
- `TickSize` - Order book tick sizes (`cent`, `tenthCent`, `hundredthCent`)
- `NegRiskFlag` - Negative risk market flag (`standard`, `negRisk`)
- `TimeInForce` - Order time in force (`gtc`, `gtd`, `fok`, `ioc`)

**New Trading Exceptions:**
- `TradingException` - Base trading exception
- `OrderSubmissionException` - Order submission failed
- `SigningException` - EIP-712 signing failed
- `WalletException` - Wallet operation failed
- `InsufficientUsdcException` - Not enough USDC
- `InsufficientGasException` - Not enough MATIC for gas
- `InsufficientAllowanceException` - USDC not approved
- `TransactionFailedException` - Transaction reverted
- `TransactionTimeoutException` - Transaction not confirmed in time

**New Constants:**
- `PolymarketConstants.usdcAddress` - USDC token contract
- `PolymarketConstants.negRiskAdapterAddress` - Neg risk adapter contract
- `PolymarketConstants.conditionalTokensAddress` - CTF contract
- `PolymarketConstants.polygonRpcUrl` - Default Polygon RPC
- `PolymarketConstants.alternativeRpcUrls` - Fallback RPC URLs
- `PolymarketConstants.eip712DomainName` - EIP-712 domain name
- `PolymarketConstants.eip712DomainVersion` - EIP-712 domain version

### Changed

- **Breaking**: `L1Auth` now implements actual EIP-712 signing (was placeholder)
- **Breaking**: New dependencies required: `web3dart`, `bip39`, `bip32`, `pointycastle`, `encrypt`

### Migration

Before (v1.x - L1Auth was placeholder):
```dart
// L1Auth threw UnimplementedError
final l1Auth = L1Auth(privateKey: key, walletAddress: addr);
l1Auth.getHeaders(); // Would throw
```

After (v2.0 - Full trading support):
```dart
// Create trading client
final client = PolymarketClient.withTrading(
  credentials: ApiCredentials(
    apiKey: 'your-api-key',
    secret: 'your-secret',
    passphrase: 'your-passphrase',
  ),
  walletAddress: '0x...',
  privateKey: '0x...',
);

// Check USDC balance
final balance = await client.polygon.getUsdcBalance('0x...');

// Place an order
final response = await client.placeOrder(
  tokenId: 'token-id',
  side: OrderSide.buy,
  size: 10.0,
  price: 0.55,
);

// Or build and sign manually
final signedOrder = client.buildSignedOrder(
  tokenId: 'token-id',
  side: OrderSide.buy,
  size: 10.0,
  price: 0.55,
  negRisk: false,
);
final response = await client.clob.orders.postOrder(signedOrder.toJson());

// Generate a new wallet
final mnemonic = HdWallet.generateMnemonic();
final wallet = HdWallet.deriveWallet(mnemonic);
print('Address: ${wallet.address}');
```

---

## [1.8.1] - 2026-01-19

### Fixed

#### JSON Parsing Bugs - Type Cast Exceptions

Fixed multiple type cast exceptions when parsing API responses:

**1. Null String Fields:**
Fixed `type 'Null' is not a subtype of type 'String' in type cast` errors.
- `Market.marketMakerAddress` - Now nullable
- `Order.timestamp` - Now nullable
- `OrderBook.timestamp`, `OrderBook.hash` - Now nullable
- `Trade.matchTime`, `Trade.lastUpdate` - Now nullable

**2. Gamma API Field Naming:**
Fixed `fieldRename: FieldRename.snake` mismatch - Gamma API uses camelCase, not snake_case.
- All Gamma models now use camelCase JSON keys (matching API response format)
- Affected: `Market`, `Event`, `Tag`, `Series`, `Category`, `Profile`, `Comment`, `Team`, `SearchResult`

**3. String-to-Number Type Coercion:**
Fixed `type 'String' is not a subtype of type 'num?' in type cast` errors.
- Added `json_helpers.dart` with flexible parsing functions
- `Series.id` - API returns String `"2"`, now handled correctly
- Numeric fields that may come as strings now use `parseIdNullable` / `parseDoubleNullable`

The SDK now robustly handles API response variations without throwing type cast exceptions.

---

## [1.8.0] - 2026-01-19

### Added

#### Complete Magic String Elimination - 100% Type-Safe SDK!

**New Enums:**
- `SportsMarketType` - 20+ sports market types (winner, spread, total, prop, playerProp, futures, championship, etc.)
- `SportsLeague` - 35+ leagues (NFL, NBA, MLB, NHL, EPL, La Liga, UFC, F1, PGA, Olympics, etc.)
- `SeriesType` - Series types (recurring, championship, tournament, season, etc.)
- `SeriesLayout` - Layout types (grid, list, carousel, featured, bracket, etc.)

**New Model Getters (Parse Raw Strings to Enums):**
- `LastTradePrice.sideEnum` → `OrderSide`
- `Series.seriesTypeEnum` → `SeriesType`
- `Series.recurrenceEnum` → `RecurrenceType`
- `Series.layoutEnum` → `SeriesLayout`
- `Comment.parentEntityTypeEnum` → `ParentEntityType`
- `CommentMessage.parentEntityTypeEnum` → `ParentEntityType`
- `Event.subcategoryEnum` → Appropriate subcategory enum based on category
- `Team.leagueEnum` → `SportsLeague`
- `SimplifiedToken.outcomeEnum` → `OutcomeType`
- `ClobMarket.tagSlugs` → `List<TagSlug>`
- `OrderResponse.statusEnum` → `OrderStatus`

### Changed

- **Breaking**: `MarketsEndpoint.listMarkets()` - `sportsMarketTypes` changed from `List<String>?` to `List<SportsMarketType>?`
- **Breaking**: `SportsEndpoint.listTeams()` - `leagues` changed from `List<String>?` to `List<SportsLeague>?`
- **Breaking**: `SeriesEndpoint.listSeries()` - `categoriesLabels` changed to `categories` with type `List<MarketCategory>?`
- **Breaking**: `SearchEndpoint.search()` - `eventsTags` changed from `List<String>?` to `List<TagSlug>?`

### Migration

Before:
```dart
final markets = await client.gamma.markets.listMarkets(
  sportsMarketTypes: ['winner', 'spread'],
);
final teams = await client.gamma.sports.listTeams(leagues: ['NFL', 'NBA']);
final series = await client.gamma.series.listSeries(categoriesLabels: ['Sports']);
final results = await client.gamma.search.search(
  query: SearchQuery.nfl,
  eventsTags: ['nfl', 'football'],
);
```

After:
```dart
final markets = await client.gamma.markets.listMarkets(
  sportsMarketTypes: [SportsMarketType.winner, SportsMarketType.spread],
);
final teams = await client.gamma.sports.listTeams(leagues: [SportsLeague.nfl, SportsLeague.nba]);
final series = await client.gamma.series.listSeries(categories: [MarketCategory.sports]);
final results = await client.gamma.search.search(
  query: SearchQuery.nfl,
  eventsTags: [TagSlug.nfl, TagSlug.football],
);

// Use enum getters on models
final trade = await client.clob.pricing.getLastTradePrice(tokenId);
print(trade.sideEnum);  // OrderSide.buy or OrderSide.sell

final team = teams.first;
print(team.leagueEnum);  // SportsLeague.nfl
```

---

## [1.7.0] - 2026-01-19

### Added

#### Type-Safe Tag Slugs - NO MORE MAGIC STRINGS!

**`TagSlug` Sealed Class:**
- 130+ preset tag slugs organized by category
- `TagSlug.custom()` for user-created or unlisted tags with validation
- `TagSlug.tryFromPreset()` - Find preset matching a value (returns null if not found)
- `TagSlug.fromValue()` - Find preset or create custom slug

**Preset Categories:**
- **Main Categories**: `politics`, `sports`, `crypto`, `business`, `entertainment`, `popCulture`, `science`, `tech`, `finance`, `news`, `world`
- **Politics**: `election`, `trump`, `biden`, `harris`, `congress`, `senate`, `house`, `supremeCourt`, `governor`, `republicans`, `democrats`
- **Sports**: `nfl`, `nba`, `mlb`, `nhl`, `cfb`, `cbb`, `soccer`, `premierLeague`, `championsLeague`, `worldCup`, `mma`, `ufc`, `f1`, `olympics`, `superBowl`, `nbaFinals`, `heismanTrophy`, `tourDeFrance`, and more
- **Crypto**: `bitcoin`, `ethereum`, `solana`, `xrp`, `doge`, `cardano`, `polygon`, `defi`, `nft`, `etfs`, `cryptocurrency`
- **Business/Finance**: `economy`, `gdp`, `inflation`, `interestRates`, `fed`, `ipos`, `ceos`, `layoffs`, `tradeWar`, `bankOfJapan`, `monetaryPolicy`
- **Entertainment**: `movies`, `tv`, `music`, `album`, `oscars`, `grammys`, `emmys`, `billboardHot100`, `youtube`, `tiktok`, `streaming`, `netflix`
- **Science/Tech**: `ai`, `openai`, `chatgpt`, `spacex`, `nasa`, `space`, `climate`, `tesla`, `apple`, `google`, `microsoft`, `amazon`, `meta`
- **World/Geopolitics**: `ukraine`, `russia`, `china`, `israel`, `iran`, `middleEast`, `europe`, `uk`, `france`, `germany`, `japan`, `india`, `war`, `nato`, `un`, `eu`
- **People**: `elonMusk`, `joeRogan`, `kanyeWest`, `putin`, `netanyahu`, `popeFrancis`, `taylorSwift`

**Tag Model Enhancement:**
- `Tag.slugEnum` - Get the slug as a type-safe `TagSlug`
- `Tag.slugPreset` - Try to get a preset `TagSlug` (returns null if no preset matches)

### Changed

- **Breaking**: `TagsEndpoint.getBySlug()` - `slug` parameter changed from `String` to `TagSlug`
- **Breaking**: `EventsEndpoint.listEvents()` - `tagSlug` parameter changed from `String?` to `TagSlug?`
- **Breaking**: `EventsEndpoint.getByTagSlug()` - `tagSlug` parameter changed from `String` to `TagSlug`
- **Breaking**: `MarketsEndpoint.listMarkets()` - `tagSlug` parameter changed from `String?` to `TagSlug?`
- **Breaking**: `MarketsEndpoint.getByTagSlug()` - `tagSlug` parameter changed from `String` to `TagSlug`

### Migration

Before:
```dart
final events = await client.gamma.events.listEvents(tagSlug: 'politics');
final markets = await client.gamma.markets.getByTagSlug('crypto');
```

After:
```dart
final events = await client.gamma.events.listEvents(tagSlug: TagSlug.politics);
final markets = await client.gamma.markets.getByTagSlug(TagSlug.crypto);

// For custom/user-created tags:
final events = await client.gamma.events.listEvents(tagSlug: TagSlug.custom('my-tag'));
```

---

## [1.6.1] - 2026-01-18

### Changed

- **README UI Overhaul** - Modern design with badges, collapsible sections, and improved visual hierarchy
  - Added Dart SDK, version, and license badges
  - Reorganized API reference with collapsible `<details>` sections
  - Features displayed in clean table format
  - Type-safe enums organized into categorized collapsible tables
  - Quick navigation links and centered hero section
  - Improved code examples organization

---

## [1.6.0] - 2026-01-18

### Added

#### Complete Idiot-Proofing - All String Parameters Now Type-Safe!

**New Order Enums:**
- `TagOrderBy` - Type-safe ordering for tags (`volume`, `eventsCount`, `createdAt`, `label`)
- `CommentOrderBy` - Type-safe ordering for comments (`createdAt`, `likes`, `replies`, `updatedAt`)
- `SeriesOrderBy` - Type-safe ordering for series (`volume`, `startDate`, `endDate`, `createdAt`, `liquidity`)
- `SportsOrderBy` - Type-safe ordering for sports teams (`name`, `league`, `abbreviation`, `createdAt`)

**New Filter Enums:**
- `RecurrenceType` - Event recurrence filtering (`daily`, `weekly`, `monthly`, `yearly`, `none`)
  - Helper method: `isRecurring` getter
- `UmaResolutionStatus` - UMA oracle resolution status (`pending`, `proposed`, `disputed`, `resolved`)
  - Helper methods: `isTerminal`, `isInProgress`, `hasStarted` getters

**SearchQuery Enhancements:**
- `SearchQuery.tryFromPreset()` - Find preset matching a value (returns null if not found)
- `SearchQuery.fromValue()` - Find preset or create custom query
- `SearchQuery.custom()` now validates input and throws `ArgumentError` on empty/whitespace

**Enum Improvements:**
- `SortDirection` now has `opposite` getter
- All enums now have consistent `fromJson` (throws) and `tryFromJson` (returns null) behavior
- Added `@JsonEnum` annotations and comprehensive documentation

### Changed

- **Breaking**: `TagsEndpoint.listTags()` - `order` parameter changed from `String?` to `TagOrderBy?`
- **Breaking**: `CommentsEndpoint.listComments()` - `order` parameter changed from `String?` to `CommentOrderBy?`
- **Breaking**: `SeriesEndpoint.listSeries()` - `order` changed to `SeriesOrderBy?`, `recurrence` changed to `RecurrenceType?`
- **Breaking**: `SportsEndpoint.listTeams()` - `order` parameter changed from `String?` to `SportsOrderBy?`
- **Breaking**: `EventsEndpoint.listEvents()` - `recurrence` parameter changed from `String?` to `RecurrenceType?`
- **Breaking**: `SearchEndpoint.search()` - `recurrence` parameter changed from `String?` to `RecurrenceType?`
- **Breaking**: `MarketsEndpoint.listMarkets()` - `umaResolutionStatus` changed from `String?` to `UmaResolutionStatus?`
- **Breaking**: `SearchQuery.custom()` now throws `ArgumentError` on empty/whitespace input
- **Breaking**: `LeaderboardWindow.fromJson()` now throws on invalid input (was silent fallback to `all`)
- **Breaking**: `LeaderboardType.fromJson()` now throws on invalid input (was silent fallback to `profit`)
- **Breaking**: `SortDirection.fromJson()` now throws on invalid input (was silent fallback to `desc`)

### Documentation

- Added `doc/IDIOT_PROOFING.md` - Comprehensive progress tracker for type-safety work

---

## [1.5.0] - 2026-01-18

### Added

#### Type-Safe Search Queries
- `SearchQuery` - Sealed class for type-safe search queries with 60+ presets
  - **Crypto**: `bitcoin`, `ethereum`, `solana`, `crypto`, `defi`, `nft`, `memecoin`, `altcoin`
  - **Politics**: `election`, `trump`, `biden`, `president`, `congress`, `senate`, `supremeCourt`, `policy`
  - **Sports**: `nfl`, `nba`, `mlb`, `nhl`, `soccer`, `ufc`, `boxing`, `tennis`, `golf`, `olympics`, `superBowl`, `worldCup`
  - **Entertainment**: `oscars`, `grammys`, `emmys`, `movies`, `tv`, `music`, `celebrity`, `taylorSwift`, `streaming`
  - **Business**: `stocks`, `fed`, `interestRates`, `inflation`, `recession`, `ipo`, `tesla`, `apple`, `google`, `amazon`, `microsoft`, `elonMusk`
  - **Science/Tech**: `ai`, `openai`, `chatgpt`, `spacex`, `nasa`, `climate`, `space`, `mars`
  - **World**: `war`, `ukraine`, `russia`, `china`, `israel`, `middleEast`
  - Custom queries via `SearchQuery.custom('your search')`
  - Category-grouped presets: `SearchQuery.cryptoPresets`, `SearchQuery.politicsPresets`, etc.

#### SearchEndpoint Convenience Methods
- `searchBitcoin()`, `searchEthereum()`, `searchCrypto()` - Quick crypto searches
- `searchElection()`, `searchTrump()` - Quick politics searches
- `searchAI()` - Quick AI/tech searches
- `searchNFL()`, `searchNBA()` - Quick sports searches

### Changed

- **Breaking**: `SearchEndpoint.search()` now uses `SearchQuery` instead of `String` for the `query` parameter
  - Use `SearchQuery.bitcoin` for presets or `SearchQuery.custom('text')` for custom searches

---

## [1.4.0] - 2026-01-18

### Added

#### Additional Type-Safe Enums
- `PriceHistoryInterval` - Enum for price history time intervals
  - `minute1`, `minute5`, `minute15`, `minute30`, `hour1`, `hour4`, `hour6`, `hour12`, `day1`, `week1`, `max`
- `GammaLeaderboardOrderBy` - Enum for Gamma leaderboard ordering
  - `profit`, `volume`, `marketsTraded`
- `SearchSort` - Enum for search result sorting
  - `relevance`, `volume`, `liquidity`, `startDate`, `endDate`, `createdAt`
- `EventsStatus` - Enum for filtering events by status
  - `active`, `closed`, `all`
- `WsSubscriptionType` - Enum for WebSocket subscription types
  - `market`, `user`, `unsubscribe`

### Changed

- **Breaking**: `PricingEndpoint.getPriceHistory()` now uses `PriceHistoryInterval` enum instead of `String` for `interval`
- **Breaking**: `GammaLeaderboardEndpoint.getLeaderboard()` now uses `GammaLeaderboardOrderBy` enum instead of `String` for `order`
- **Breaking**: `SearchEndpoint.search()` now uses `SearchSort` enum instead of `String` for `sort`
- **Breaking**: `SearchEndpoint.search()` now uses `EventsStatus` enum instead of `String` for `eventsStatus`
- **Breaking**: `WebSocketClient.subscribe()` now uses `WsSubscriptionType` enum instead of `String` for `type`

---

## [1.3.0] - 2026-01-18

### Added

#### Type-Safe Order By Enums
- `MarketOrderBy` - Enum for ordering markets in list queries
  - `volume`, `volume24hr`, `liquidity`, `endDate`, `startDate`, `createdAt`
- `EventOrderBy` - Enum for ordering events in list queries
  - `volume`, `startDate`, `endDate`, `createdAt`, `liquidity`

### Changed

- **Breaking**: `MarketsEndpoint.listMarkets()` now uses `MarketOrderBy` enum instead of `String` for the `order` parameter
- **Breaking**: `EventsEndpoint.listEvents()` now uses `EventOrderBy` enum instead of `String` for the `order` parameter

---

## [1.2.1] - 2026-01-18

### Changed

- Updated repository URL to `https://github.com/mayankjanmejay/PolybrainZ_Polymarket/` 

## [1.2.0] - 2026-01-18

### Added

#### New Enums
- `OutcomeType` - Binary outcome types (`yes`, `no`) with helper methods
  - `opposite` getter to get the opposite outcome
  - `isYes`, `isNo` boolean getters
  - `tryFromJson()` for safe parsing
- `OrderStatus` - Order lifecycle states (`live`, `matched`, `filled`, `cancelled`, `pending`, `delayed`)
  - `isActive`, `isTerminal`, `isCancellable` boolean getters
- `GameStatus` - Sports game states (`scheduled`, `inProgress`, `halftime`, `ended`, `postponed`, `cancelled`, `suspended`)
  - `isLive`, `isFinished`, `isUpcoming`, `isInterrupted` boolean getters

#### Type-Safe Enum Getters on Models
Added enum parsing getters to all models with string fields that have fixed values:

**CLOB Models:**
- `Order` - `sideEnum`, `typeEnum`, `statusEnum`, `outcomeEnum`
- `Trade` - `sideEnum`, `statusEnum`, `outcomeEnum`
- `MakerOrder` - `outcomeEnum`
- `ClobToken` - `outcomeEnum`

**Data Models:**
- `TradeRecord` - `sideEnum`, `outcomeEnum`
- `Activity` - `outcomeEnum` (already had `activityType`, `sideEnum`)
- `Position` - `outcomeEnum`, `oppositeOutcomeEnum`
- `ClosedPosition` - `outcomeEnum`

**Gamma Models:**
- `Event` - `categoryEnum`, `sortByEnum`, `gameStatusEnum`

**WebSocket Models:**
- `OrderWsMessage` - `sideEnum`, `typeEnum`, `outcomeEnum`
- `TradeWsMessage` - `sideEnum`, `statusEnum`, `outcomeEnum`

#### Helper Methods on Models
- Added `toLegacyMap()` to all model classes for simplified Map output
- Added `yesPrice` and `noPrice` getters to `Market` class

---

## [1.1.0] - 2026-01-18

### Added

#### Category Enums
- `MarketCategory` - Main categories (politics, sports, crypto, popCulture, business, science, etc.)
- `PoliticsSubcategory` - US elections, international, policy, supreme court, etc.
- `SportsSubcategory` - NFL, NBA, MLB, NHL, soccer leagues, UFC, Olympics, etc.
- `CryptoSubcategory` - Bitcoin, Ethereum, DeFi, NFTs, exchanges, etc.
- `PopCultureSubcategory` - Movies, TV, music, celebrities, awards, streaming, etc.
- `BusinessSubcategory` - Tech companies, stocks, Fed, economy, M&A, etc.
- `ScienceSubcategory` - AI, space, climate, biotech, medicine, etc.

#### CategoryDetector Utility
- `CategoryDetector.detectFromEvent()` - Detect category from an Event
- `CategoryDetector.detectFromMarket()` - Detect category from a Market
- `CategoryDetector.detectFromTags()` - Detect category from Tag list
- `CategoryDetector.detectFromTagSlugs()` - Detect category from slug strings
- `CategoryDetector.groupEventsByCategory()` - Group events by detected category
- `CategoryDetector.groupMarketsByCategory()` - Group markets by detected category
- `CategoryDetector.getSubcategoriesFor()` - Get subcategory enum values for a category
- Extension methods on `List<Event>` and `List<Market>` for convenience

#### New Endpoints
- `GammaLeaderboardEndpoint` - Get trader rankings via Gamma API
  - `getTopByProfit()` - Top traders by profit
  - `getTopByVolume()` - Top traders by volume
  - `getTopByMarketsTraded()` - Top traders by markets traded
  - `getLeaderboard()` - Custom ordering

#### EventsEndpoint Enhancements
- Added `hot` parameter for trending events
- Added `tagSlug` parameter for category filtering
- `getHotEvents()` - Get trending/hot events
- `getFeaturedEvents()` - Get featured events
- `getByTagSlug()` - Get events by category slug
- `getEndingSoon()` - Get events ending within a time window

#### MarketsEndpoint Enhancements
- Added `tagSlug` parameter for category filtering
- `getTopByVolume()` - Top markets by total volume
- `getTopByVolume24hr()` - Top markets by 24-hour volume
- `getTopByLiquidity()` - Top markets by liquidity
- `getByTagSlug()` - Get markets by category slug
- `getEndingSoon()` - Get markets ending within a time window

---

## [1.0.0] - 2026-01-16

### Added

#### Core Infrastructure
- `ApiClient` - HTTP client with automatic retry, rate limiting, and error handling
- `WebSocketClient` - Base WebSocket client with auto-reconnect and heartbeat
- `PolymarketException` hierarchy for typed error handling
- `Result<T, E>` sealed class for functional error handling
- Constants for all API URLs and configuration

#### Gamma API (Market Discovery)
- `GammaClient` - Full client for Gamma API
- `EventsEndpoint` - List, get by ID/slug, filter events
- `MarketsEndpoint` - List, get by ID/slug/conditionId, filter markets
- `TagsEndpoint` - List tags, get related tags
- `SeriesEndpoint` - List and get series
- `CommentsEndpoint` - List comments, get by user
- `ProfilesEndpoint` - Get user profiles
- `SearchEndpoint` - Search events, tags, profiles
- `SportsEndpoint` - List teams, get sports metadata

#### CLOB API (Order Book & Trading)
- `ClobClient` - Full client for CLOB API
- `ClobMarketsEndpoint` - CLOB-specific market data
- `OrderbookEndpoint` - Get order books for tokens
- `PricingEndpoint` - Get prices, midpoints, spreads, price history
- `OrdersEndpoint` - Post, get, cancel orders (L2 auth)
- `ClobTradesEndpoint` - Get trade history

#### Data API (Analytics)
- `DataClient` - Full client for Data API
- `PositionsEndpoint` - Get open/closed positions
- `DataTradesEndpoint` - Get user/market trade history
- `ActivityEndpoint` - Get on-chain activity
- `HoldersEndpoint` - Get token/market holders
- `ValueEndpoint` - Get portfolio value
- `LeaderboardEndpoint` - Get leaderboard rankings

#### WebSocket Clients
- `ClobWebSocket` - Real-time order book, prices, user orders
- `RtdsWebSocket` - Real-time crypto prices, comments
- Auto-reconnect with exponential backoff
- Heartbeat/ping-pong support
- Typed message streams

#### Authentication
- `ApiCredentials` - Model for API key, secret, passphrase
- `L1Auth` - EIP-712 signing for API key creation (placeholder)
- `L2Auth` - HMAC-SHA256 signing for trading operations
- `AuthService` - Authentication orchestration

#### Models (25+ classes)
- Gamma: Event, Market, Tag, Category, Profile, Comment, Series, Team, SearchResult
- CLOB: ClobMarket, ClobToken, ClobRewards, OrderBook, OrderSummary, Order, OrderResponse, Trade, SimplifiedMarket
- Data: Position, ClosedPosition, TradeRecord, Activity, Holder, HoldingsValue, LeaderboardEntry
- WebSocket: WsMessage, BookMessage, PriceChangeMessage, LastTradePriceMessage, TradeWsMessage, OrderWsMessage, CryptoPriceMessage, CommentMessage

#### Enums (15 types)
- OrderSide, OrderType, OrderActionType, TradeStatus
- SortBy, SortDirection, FilterType
- ActivityType, ParentEntityType
- LeaderboardWindow, LeaderboardType
- WsEventType, WsChannel, RtdsTopic
- SignatureType

### Notes
- L1 authentication (EIP-712 signing) requires a proper Ethereum library like `web3dart` for production use
- All models use `json_serializable` for JSON serialization
- All models extend `Equatable` for value equality

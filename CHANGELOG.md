# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

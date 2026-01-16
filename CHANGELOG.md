# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

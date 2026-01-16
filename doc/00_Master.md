# Polymarket API Wrapper - Master Guide

## Quick Reference Index

Use this guide to find the right documentation for your task.

---

## 🎯 What Are You Doing?

### Starting the Project?
→ **[01_README.md](./01_README.md)**
- Project structure
- Dependencies (pubspec.yaml)
- Implementation order
- Quick start example

---

### Creating Enums?
→ **[02_ENUMS.md](./02_ENUMS.md)**

| Enum | Purpose |
|------|---------|
| `OrderSide` | BUY / SELL |
| `OrderType` | GTC, GTD, FOK, FAK |
| `TradeStatus` | MINED, CONFIRMED, RETRYING, FAILED |
| `ActivityType` | TRADE, SPLIT, MERGE, REDEEM, REWARD, CONVERSION |
| `SortBy` | Position/trade sorting fields |
| `SortDirection` | ASC / DESC |
| `FilterType` | CASH / TOKENS |
| `SignatureType` | EOA, Email/Magic, Browser wallet |
| `TickSize` | 0.1, 0.01, 0.001, 0.0001 |
| `LeaderboardWindow` | 1d, 7d, 30d, all |
| `LeaderboardType` | PROFIT / VOLUME |
| `WsEventType` | WebSocket event types |
| `WsChannel` | market / user |
| `RtdsTopic` | crypto_prices, comments |
| `ParentEntityType` | Event, Series, market |
| `GameStatus` | InProgress, finished, etc. |
| `OrderActionType` | PLACEMENT, UPDATE, CANCELLATION |

---

### Creating Models?
→ **[03_MODELS.md](./03_MODELS.md)**

| Model | API | Purpose |
|-------|-----|---------|
| `Event` | Gamma | Prediction market event |
| `Market` | Gamma | Market within an event |
| `Tag` | Gamma | Category tags |
| `Category` | Gamma | Event categories |
| `Profile` | Gamma | User profile |
| `Comment` | Gamma | User comments |
| `Series` | Gamma | Related event series |
| `Team` | Gamma | Sports teams |
| `SearchResult` | Gamma | Search response |
| `ClobMarket` | CLOB | Market with tokens |
| `ClobToken` | CLOB | Outcome token |
| `ClobRewards` | CLOB | Liquidity rewards config |
| `OrderBook` | CLOB | Bids/asks |
| `OrderSummary` | CLOB | Price level |
| `Order` | CLOB | User order |
| `OrderResponse` | CLOB | Post order response |
| `Trade` | CLOB | Trade record |
| `Position` | Data | Open position |
| `ClosedPosition` | Data | Resolved position |
| `Activity` | Data | On-chain activity |
| `Holder` | Data | Token holder |
| `HoldingsValue` | Data | Portfolio value |
| `LeaderboardEntry` | Data | Ranking entry |
| `TradeRecord` | Data | Trade history |

---

### Setting Up Core Infrastructure?
→ **[04_CORE.md](./04_CORE.md)**

| Class | Purpose |
|-------|---------|
| `PolymarketConstants` | Base URLs, chain config, defaults |
| `PolymarketException` | Base exception class |
| `ApiException` | HTTP errors |
| `AuthenticationException` | Auth failures |
| `RateLimitException` | 429 errors |
| `NetworkException` | Connection issues |
| `WebSocketException` | WS errors |
| `ValidationException` | Invalid params |
| `NotFoundException` | 404 errors |
| `Result<T,E>` | Success/Failure type |
| `ApiClient` | HTTP client with retry |
| `WebSocketClient` | Base WS with reconnect |

---

### Implementing Authentication?
→ **[05_AUTH.md](./05_AUTH.md)**

| Class | Purpose |
|-------|---------|
| `ApiCredentials` | API key, secret, passphrase |
| `L1Auth` | Private key EIP-712 signing |
| `L2Auth` | API key HMAC-SHA256 |
| `AuthService` | Auth orchestrator |

**Auth Flow:**
1. L1 (private key) → Create/derive API keys
2. L2 (API credentials) → All trading operations

---

### Working with Gamma API (Market Discovery)?
→ **[06_GAMMA_API.md](./06_GAMMA_API.md)**

| Endpoint | Methods |
|----------|---------|
| `events` | listEvents, getById, getBySlug, getTags |
| `markets` | listMarkets, getById, getBySlug, getByConditionId |
| `tags` | listTags, getById, getBySlug, getRelatedTags |
| `series` | listSeries, getById |
| `comments` | listComments, getById, getByUserAddress |
| `profiles` | getByAddress |
| `search` | search |
| `sports` | listTeams, getMetadata, getValidMarketTypes |

**Base URL:** `https://gamma-api.polymarket.com`
**Auth Required:** No

---

### Working with CLOB API (Trading)?
→ **[07_CLOB_API.md](./07_CLOB_API.md)**

| Endpoint | Methods | Auth |
|----------|---------|------|
| `markets` | listMarkets, getMarket, getSamplingMarkets, getTickSize, getNegRisk | No |
| `orderbook` | getOrderBook, getOrderBooks | No |
| `pricing` | getPrice, getPrices, getMidpoint, getSpread, getLastTradePrice | No |
| `orders` | postOrder, postOrders, getOrder, getOpenOrders, cancelOrder, cancelAll | **Yes (L2)** |
| `trades` | getTrades | Optional |

**Base URL:** `https://clob.polymarket.com`

---

### Working with Data API (Positions/Activity)?
→ **[08_DATA_API.md](./08_DATA_API.md)**

| Endpoint | Methods |
|----------|---------|
| `positions` | getPositions, getClosedPositions, getMarketPositions |
| `trades` | getUserTrades, getMarketTrades |
| `activity` | getUserActivity, getMarketActivity |
| `holders` | getTokenHolders, getMarketHolders |
| `value` | getValue |
| `leaderboard` | getLeaderboard, getUserRank |

**Base URL:** `https://data-api.polymarket.com`
**Auth Required:** No

---

### Implementing WebSockets?
→ **[09_WEBSOCKET.md](./09_WEBSOCKET.md)**

| Client | URL | Purpose |
|--------|-----|---------|
| `ClobWebSocket` | `wss://ws-subscriptions-clob.polymarket.com/ws/` | Order books, prices, user orders |
| `RtdsWebSocket` | `wss://ws-live-data.polymarket.com` | Crypto prices, comments |

| Message Type | Model |
|--------------|-------|
| `book` | `BookMessage` |
| `price_change` | `PriceChangeMessage` |
| `last_trade_price` | `LastTradePriceMessage` |
| `trade` | `TradeWsMessage` |
| `order` | `OrderWsMessage` |
| Crypto prices | `CryptoPriceMessage` |
| Comments | `CommentMessage` |

---

### Writing Tests?
→ **[10_TESTING.md](./10_TESTING.md)**

| Section | Content |
|---------|---------|
| Test Structure | Directory layout |
| Enum Tests | 100% coverage pattern |
| Model Tests | fromJson, toJson, equality |
| API Client Tests | Mock HTTP pattern |
| WebSocket Tests | Message parsing |
| Fixtures | JSON test data |
| Coverage Requirements | Minimums per component |

---

## 📁 File-to-Task Matrix

| Task | Primary Doc | Supporting Docs |
|------|-------------|-----------------|
| Project setup | 01_README | 04_CORE |
| Add new enum | 02_ENUMS | — |
| Add Gamma model | 03_MODELS | 06_GAMMA_API |
| Add CLOB model | 03_MODELS | 07_CLOB_API |
| Add Data model | 03_MODELS | 08_DATA_API |
| HTTP client changes | 04_CORE | — |
| Exception handling | 04_CORE | — |
| Auth implementation | 05_AUTH | 04_CORE |
| Gamma endpoint | 06_GAMMA_API | 03_MODELS |
| CLOB endpoint | 07_CLOB_API | 03_MODELS, 05_AUTH |
| Data endpoint | 08_DATA_API | 03_MODELS |
| WebSocket feature | 09_WEBSOCKET | 04_CORE |
| Write tests | 10_TESTING | All relevant |

---

## 🔄 Implementation Order

```
Phase 1: Foundation
├── 04_CORE.md → constants.dart, exceptions.dart, result.dart
└── 02_ENUMS.md → all enum files

Phase 2: Models
├── 03_MODELS.md → auth models
├── 03_MODELS.md → gamma models
├── 03_MODELS.md → clob models
└── 03_MODELS.md → data models

Phase 3: Core Infrastructure
├── 04_CORE.md → api_client.dart, websocket_client.dart
└── 05_AUTH.md → l1_auth.dart, l2_auth.dart, auth_service.dart

Phase 4: API Clients
├── 06_GAMMA_API.md → all endpoints + gamma_client.dart
├── 07_CLOB_API.md → all endpoints + clob_client.dart
└── 08_DATA_API.md → all endpoints + data_client.dart

Phase 5: WebSocket
└── 09_WEBSOCKET.md → clob_websocket.dart, rtds_websocket.dart

Phase 6: Testing
└── 10_TESTING.md → all test files
```

---

## 🔍 Quick Lookup by Class Name

| Class | Documentation |
|-------|---------------|
| `Activity` | 03_MODELS, 08_DATA_API |
| `ActivityEndpoint` | 08_DATA_API |
| `ActivityType` | 02_ENUMS |
| `ApiClient` | 04_CORE |
| `ApiCredentials` | 05_AUTH |
| `ApiException` | 04_CORE |
| `AuthService` | 05_AUTH |
| `BookMessage` | 09_WEBSOCKET |
| `Category` | 03_MODELS |
| `ClobClient` | 07_CLOB_API |
| `ClobMarket` | 03_MODELS, 07_CLOB_API |
| `ClobMarketsEndpoint` | 07_CLOB_API |
| `ClobRewards` | 03_MODELS |
| `ClobToken` | 03_MODELS |
| `ClobWebSocket` | 09_WEBSOCKET |
| `ClosedPosition` | 03_MODELS, 08_DATA_API |
| `Comment` | 03_MODELS |
| `CommentMessage` | 09_WEBSOCKET |
| `CommentsEndpoint` | 06_GAMMA_API |
| `CryptoPriceMessage` | 09_WEBSOCKET |
| `DataClient` | 08_DATA_API |
| `DataTradesEndpoint` | 08_DATA_API |
| `Event` | 03_MODELS |
| `EventsEndpoint` | 06_GAMMA_API |
| `FilterType` | 02_ENUMS |
| `GameStatus` | 02_ENUMS |
| `GammaClient` | 06_GAMMA_API |
| `Holder` | 03_MODELS, 08_DATA_API |
| `HoldersEndpoint` | 08_DATA_API |
| `HoldingsValue` | 03_MODELS, 08_DATA_API |
| `L1Auth` | 05_AUTH |
| `L2Auth` | 05_AUTH |
| `LastTradePriceMessage` | 09_WEBSOCKET |
| `LeaderboardEndpoint` | 08_DATA_API |
| `LeaderboardEntry` | 03_MODELS, 08_DATA_API |
| `LeaderboardType` | 02_ENUMS |
| `LeaderboardWindow` | 02_ENUMS |
| `Market` | 03_MODELS |
| `MarketsEndpoint` | 06_GAMMA_API |
| `NetworkException` | 04_CORE |
| `NotFoundException` | 04_CORE |
| `Order` | 03_MODELS, 07_CLOB_API |
| `OrderActionType` | 02_ENUMS |
| `OrderBook` | 03_MODELS, 07_CLOB_API |
| `OrderResponse` | 03_MODELS, 07_CLOB_API |
| `OrderSide` | 02_ENUMS |
| `OrderSummary` | 03_MODELS |
| `OrderType` | 02_ENUMS |
| `OrderWsMessage` | 09_WEBSOCKET |
| `OrderbookEndpoint` | 07_CLOB_API |
| `OrdersEndpoint` | 07_CLOB_API |
| `ParentEntityType` | 02_ENUMS |
| `PolymarketConstants` | 04_CORE |
| `PolymarketException` | 04_CORE |
| `Position` | 03_MODELS, 08_DATA_API |
| `PositionsEndpoint` | 08_DATA_API |
| `PriceChangeMessage` | 09_WEBSOCKET |
| `PricingEndpoint` | 07_CLOB_API |
| `Profile` | 03_MODELS |
| `ProfilesEndpoint` | 06_GAMMA_API |
| `RateLimitException` | 04_CORE |
| `Result` | 04_CORE |
| `RtdsTopic` | 02_ENUMS |
| `RtdsWebSocket` | 09_WEBSOCKET |
| `SearchEndpoint` | 06_GAMMA_API |
| `SearchResult` | 03_MODELS |
| `Series` | 03_MODELS |
| `SeriesEndpoint` | 06_GAMMA_API |
| `SignatureType` | 02_ENUMS |
| `SimplifiedMarket` | 07_CLOB_API |
| `SortBy` | 02_ENUMS |
| `SortDirection` | 02_ENUMS |
| `SportsEndpoint` | 06_GAMMA_API |
| `Tag` | 03_MODELS |
| `TagsEndpoint` | 06_GAMMA_API |
| `Team` | 03_MODELS |
| `TickSize` | 02_ENUMS |
| `TimeoutException` | 04_CORE |
| `Trade` | 03_MODELS, 07_CLOB_API |
| `TradeRecord` | 03_MODELS, 08_DATA_API |
| `TradeStatus` | 02_ENUMS |
| `TradeWsMessage` | 09_WEBSOCKET |
| `ValidationException` | 04_CORE |
| `ValueEndpoint` | 08_DATA_API |
| `WebSocketClient` | 04_CORE |
| `WebSocketException` | 04_CORE |
| `WsChannel` | 02_ENUMS |
| `WsEventType` | 02_ENUMS |
| `WsMessage` | 09_WEBSOCKET |

---

## 📋 Checklist for New Features

### Adding a New Enum
- [ ] Read 02_ENUMS.md for pattern
- [ ] Create enum file in `src/enums/`
- [ ] Add to barrel export `src/enums/enums.dart`
- [ ] Write tests per 10_TESTING.md

### Adding a New Model
- [ ] Read 03_MODELS.md for pattern
- [ ] Create model file in appropriate `models/` folder
- [ ] Add to barrel export
- [ ] Create test fixture in `test/fixtures/`
- [ ] Write tests per 10_TESTING.md

### Adding a New Endpoint
- [ ] Read API doc (06, 07, or 08)
- [ ] Create endpoint file in `endpoints/` folder
- [ ] Add to client class
- [ ] Write mock HTTP tests per 10_TESTING.md

### Adding WebSocket Feature
- [ ] Read 09_WEBSOCKET.md
- [ ] Create message model if needed
- [ ] Add stream/method to WebSocket client
- [ ] Write parsing tests
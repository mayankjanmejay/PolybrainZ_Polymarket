# Polymarket API Wrapper - Implementation Guide

## polybrainz_polymarket

A comprehensive Dart SDK for the Polymarket prediction market APIs.

---

## Quick Links

| Document | Description |
|----------|-------------|
| [02_ENUMS.md](./02_ENUMS.md) | All enum definitions with complete code |
| [03_MODELS.md](./03_MODELS.md) | All model classes with JSON serialization |
| [04_CORE.md](./04_CORE.md) | Core infrastructure (HTTP client, exceptions, constants) |
| [05_AUTH.md](./05_AUTH.md) | L1/L2 authentication implementation |
| [06_GAMMA_API.md](./06_GAMMA_API.md) | Gamma API client and endpoints |
| [07_CLOB_API.md](./07_CLOB_API.md) | CLOB API client and endpoints |
| [08_DATA_API.md](./08_DATA_API.md) | Data API client and endpoints |
| [09_WEBSOCKET.md](./09_WEBSOCKET.md) | WebSocket clients implementation |
| [10_TESTING.md](./10_TESTING.md) | Testing patterns and requirements |

---

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
    │   │   ├── markets_endpoint.dart       # CLOB markets (different from Gamma)
    │   │   ├── orderbook_endpoint.dart
    │   │   ├── pricing_endpoint.dart
    │   │   ├── orders_endpoint.dart
    │   │   ├── trades_endpoint.dart
    │   │   └── spreads_endpoint.dart
    │   └── models/
    │       ├── clob_market.dart
    │       ├── clob_token.dart
    │       ├── clob_rewards.dart
    │       ├── simplified_market.dart
    │       ├── order_book.dart
    │       ├── order_summary.dart
    │       ├── price.dart
    │       ├── midpoint.dart
    │       ├── spread.dart
    │       ├── order.dart
    │       ├── order_response.dart
    │       ├── signed_order.dart
    │       └── trade.dart
    │
    ├── data/
    │   ├── data_client.dart                # Data API client
    │   ├── endpoints/
    │   │   ├── positions_endpoint.dart
    │   │   ├── trades_endpoint.dart
    │   │   ├── activity_endpoint.dart
    │   │   ├── holders_endpoint.dart
    │   │   ├── value_endpoint.dart
    │   │   └── leaderboard_endpoint.dart
    │   └── models/
    │       ├── position.dart
    │       ├── closed_position.dart
    │       ├── trade_record.dart
    │       ├── activity.dart
    │       ├── holder.dart
    │       ├── holdings_value.dart
    │       └── leaderboard_entry.dart
    │
    ├── websocket/
    │   ├── clob_websocket.dart             # CLOB WebSocket client
    │   ├── rtds_websocket.dart             # RTDS WebSocket client
    │   ├── sports_websocket.dart           # Sports WebSocket client
    │   └── models/
    │       ├── ws_message.dart
    │       ├── book_message.dart
    │       ├── price_change_message.dart
    │       ├── last_trade_price_message.dart
    │       ├── tick_size_change_message.dart
    │       ├── best_bid_ask_message.dart
    │       ├── trade_message.dart
    │       ├── order_message.dart
    │       ├── crypto_price_message.dart
    │       ├── comment_message.dart
    │       └── sport_result_message.dart
    │
    └── enums/
        ├── order_side.dart
        ├── order_type.dart
        ├── trade_status.dart
        ├── activity_type.dart
        ├── sort_by.dart
        ├── sort_direction.dart
        ├── filter_type.dart
        ├── signature_type.dart
        ├── tick_size.dart
        ├── leaderboard_window.dart
        ├── leaderboard_type.dart
        ├── ws_event_type.dart
        ├── ws_channel.dart
        ├── rtds_topic.dart
        ├── parent_entity_type.dart
        └── game_status.dart
```

---

## Dependencies

### pubspec.yaml

```yaml
name: polybrainz_polymarket
description: Dart SDK for Polymarket APIs (Gamma, CLOB, Data, WebSocket)
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  http: ^1.2.0
  web_socket_channel: ^3.0.0
  crypto: ^3.0.3
  convert: ^3.1.1
  equatable: ^2.0.5
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.8.0
  lints: ^6.0.0
  test: ^1.25.6
  mockito: ^5.4.0
  build_verify: ^3.0.0
```

---

## Implementation Order

Follow this order for a clean build:

### Phase 1: Foundation
1. `src/core/constants.dart`
2. `src/core/exceptions.dart`
3. `src/core/result.dart`
4. All files in `src/enums/`

### Phase 2: Models
5. `src/auth/models/api_credentials.dart`
6. All files in `src/gamma/models/`
7. All files in `src/clob/models/`
8. All files in `src/data/models/`
9. All files in `src/websocket/models/`

### Phase 3: Core Infrastructure
10. `src/core/api_client.dart`
11. `src/core/websocket_client.dart`
12. `src/auth/l1_auth.dart`
13. `src/auth/l2_auth.dart`
14. `src/auth/auth_service.dart`

### Phase 4: API Clients
15. All files in `src/gamma/endpoints/`
16. `src/gamma/gamma_client.dart`
17. All files in `src/clob/endpoints/`
18. `src/clob/clob_client.dart`
19. All files in `src/data/endpoints/`
20. `src/data/data_client.dart`

### Phase 5: WebSocket
21. `src/websocket/clob_websocket.dart`
22. `src/websocket/rtds_websocket.dart`
23. `src/websocket/sports_websocket.dart`

### Phase 6: Main Export
24. `lib/polybrainz_polymarket.dart`

---

## Quick Start Example

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  // Public client (no auth required)
  final client = PolymarketClient.public();
  
  // Get active events
  final events = await client.gamma.events.listEvents(
    limit: 10,
    offset: 0,
    closed: false,
  );
  
  // Get order book for a token
  final book = await client.clob.orderbook.getOrderBook(
    '71321045679252212594626385532706912750332728571942532289631379312455583992563',
  );
  
  print('Best bid: ${book.bids.first.price}');
  print('Best ask: ${book.asks.first.price}');
  
  // Authenticated client (for trading)
  final authClient = PolymarketClient.authenticated(
    credentials: ApiCredentials(
      apiKey: 'your-api-key',
      secret: 'your-secret',
      passphrase: 'your-passphrase',
    ),
    funder: '0x...', // Your funded wallet address
  );
  
  // Get your positions
  final positions = await authClient.data.positions.getPositions(
    userAddress: '0x...',
  );
  
  // Stream real-time price updates
  authClient.clobWebSocket.subscribeToPriceChanges(['token-id']).listen((msg) {
    print('Price update: ${msg.priceChanges}');
  });
}
```

---

## Code Generation

After creating/modifying models, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## API Base URLs

| API | URL | Auth Required |
|-----|-----|---------------|
| Gamma | `https://gamma-api.polymarket.com` | No |
| CLOB | `https://clob.polymarket.com` | Partial (trading) |
| Data | `https://data-api.polymarket.com` | No |
| CLOB WSS | `wss://ws-subscriptions-clob.polymarket.com/ws/` | Partial (user channel) |
| RTDS WSS | `wss://ws-live-data.polymarket.com` | No |
| Sports WSS | `wss://sports-api.polymarket.com/ws` | No |

---

## Key Concepts

### Token IDs vs Condition IDs

- **Condition ID**: Identifies a market (e.g., "Will X happen?")
- **Token ID**: Identifies a specific outcome token (Yes or No)
- A market has ONE condition ID but TWO token IDs (Yes and No tokens)

### Negative Risk

Some markets support "negative risk" where Yes + No tokens can be merged/split for capital efficiency. Check `negRisk` field on markets.

### Order Types

| Type | Behavior |
|------|----------|
| GTC | Good Till Cancelled - rests on book until filled or cancelled |
| GTD | Good Till Date - expires at specified timestamp |
| FOK | Fill or Kill - must fill completely immediately or cancel |
| FAK | Fill and Kill (IOC) - fill what you can, cancel rest |

### Authentication Levels

- **L1**: Private key signing (EIP-712) - used to create API keys
- **L2**: API key + HMAC-SHA256 - used for all trading operations

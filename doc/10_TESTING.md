# Testing Guide

Testing patterns, requirements, and examples for the Polymarket API wrapper.

---

## Test Structure

```
test/
├── unit/
│   ├── enums/
│   │   ├── order_side_test.dart
│   │   ├── order_type_test.dart
│   │   └── ...
│   ├── models/
│   │   ├── gamma/
│   │   │   ├── event_test.dart
│   │   │   └── ...
│   │   ├── clob/
│   │   │   ├── order_book_test.dart
│   │   │   └── ...
│   │   └── data/
│   │       ├── position_test.dart
│   │       └── ...
│   └── core/
│       ├── result_test.dart
│       └── exceptions_test.dart
├── integration/
│   ├── gamma_client_test.dart
│   ├── clob_client_test.dart
│   ├── data_client_test.dart
│   └── websocket_test.dart
└── fixtures/
    ├── gamma/
    │   ├── event.json
    │   ├── market.json
    │   └── ...
    ├── clob/
    │   ├── order_book.json
    │   └── ...
    └── data/
        ├── position.json
        └── ...
```

---

## Test Requirements

### Enums - 100% Coverage

Every enum must have tests for:
1. `fromJson()` - all values
2. `toJson()` - all values
3. Case insensitivity (where applicable)
4. Invalid value handling

### Models - Full Coverage

Every model must have tests for:
1. `fromJson()` - complete JSON
2. `fromJson()` - minimal JSON (only required fields)
3. `toJson()` - round-trip equality
4. Equatable props
5. Computed properties (if any)

### API Clients - Mock HTTP

Every endpoint must have tests for:
1. Successful response
2. Error responses (400, 401, 404, 429, 500)
3. Network failures
4. Parameter validation

---

## Enum Test Pattern

### test/unit/enums/order_side_test.dart

```dart
import 'package:test/test.dart';
import 'package:polybrainz_polymarket/src/enums/order_side.dart';

void main() {
  group('OrderSide', () {
    group('fromJson', () {
      test('parses BUY correctly', () {
        expect(OrderSide.fromJson('BUY'), equals(OrderSide.buy));
      });

      test('parses SELL correctly', () {
        expect(OrderSide.fromJson('SELL'), equals(OrderSide.sell));
      });

      test('handles lowercase', () {
        expect(OrderSide.fromJson('buy'), equals(OrderSide.buy));
        expect(OrderSide.fromJson('sell'), equals(OrderSide.sell));
      });

      test('handles mixed case', () {
        expect(OrderSide.fromJson('Buy'), equals(OrderSide.buy));
        expect(OrderSide.fromJson('Sell'), equals(OrderSide.sell));
      });

      test('throws on invalid value', () {
        expect(
          () => OrderSide.fromJson('INVALID'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws on empty string', () {
        expect(
          () => OrderSide.fromJson(''),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('toJson', () {
      test('returns correct value for buy', () {
        expect(OrderSide.buy.toJson(), equals('BUY'));
      });

      test('returns correct value for sell', () {
        expect(OrderSide.sell.toJson(), equals('SELL'));
      });
    });

    group('toString', () {
      test('returns API value', () {
        expect(OrderSide.buy.toString(), equals('BUY'));
        expect(OrderSide.sell.toString(), equals('SELL'));
      });
    });

    test('all values are covered', () {
      // Ensure we test all enum values
      expect(OrderSide.values.length, equals(2));
      
      for (final side in OrderSide.values) {
        // Every value should round-trip correctly
        expect(
          OrderSide.fromJson(side.toJson()),
          equals(side),
        );
      }
    });
  });
}
```

---

## Model Test Pattern

### test/unit/models/clob/order_book_test.dart

```dart
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:polybrainz_polymarket/src/clob/models/order_book.dart';

void main() {
  group('OrderBook', () {
    late Map<String, dynamic> fullJson;
    late Map<String, dynamic> minimalJson;

    setUpAll(() {
      // Load from fixture
      fullJson = jsonDecode(
        File('test/fixtures/clob/order_book.json').readAsStringSync(),
      );
      
      // Minimal required fields
      minimalJson = {
        'market': '0x123',
        'asset_id': '456',
        'timestamp': '1234567890',
        'hash': 'abc123',
        'bids': [],
        'asks': [],
      };
    });

    group('fromJson', () {
      test('parses complete JSON', () {
        final book = OrderBook.fromJson(fullJson);
        
        expect(book.market, equals(fullJson['market']));
        expect(book.assetId, equals(fullJson['asset_id']));
        expect(book.hash, equals(fullJson['hash']));
        expect(book.bids, isNotEmpty);
        expect(book.asks, isNotEmpty);
      });

      test('parses minimal JSON', () {
        final book = OrderBook.fromJson(minimalJson);
        
        expect(book.market, equals('0x123'));
        expect(book.assetId, equals('456'));
        expect(book.bids, isEmpty);
        expect(book.asks, isEmpty);
      });

      test('handles missing optional fields', () {
        final json = Map<String, dynamic>.from(minimalJson);
        // Don't include optional fields
        
        final book = OrderBook.fromJson(json);
        expect(book.minTickSize, isNull);
        expect(book.negRisk, isFalse); // default value
      });

      test('parses bids correctly', () {
        final json = {
          ...minimalJson,
          'bids': [
            {'price': '0.55', 'size': '100'},
            {'price': '0.54', 'size': '200'},
          ],
        };
        
        final book = OrderBook.fromJson(json);
        
        expect(book.bids.length, equals(2));
        expect(book.bids[0].priceNum, equals(0.55));
        expect(book.bids[0].sizeNum, equals(100));
      });

      test('parses asks correctly', () {
        final json = {
          ...minimalJson,
          'asks': [
            {'price': '0.56', 'size': '150'},
            {'price': '0.57', 'size': '250'},
          ],
        };
        
        final book = OrderBook.fromJson(json);
        
        expect(book.asks.length, equals(2));
        expect(book.asks[0].priceNum, equals(0.56));
      });
    });

    group('toJson', () {
      test('round-trips correctly', () {
        final original = OrderBook.fromJson(fullJson);
        final json = original.toJson();
        final restored = OrderBook.fromJson(json);
        
        expect(restored, equals(original));
      });
    });

    group('computed properties', () {
      test('bestBid returns highest bid', () {
        final book = OrderBook.fromJson({
          ...minimalJson,
          'bids': [
            {'price': '0.55', 'size': '100'},
            {'price': '0.54', 'size': '200'},
          ],
        });
        
        expect(book.bestBid, equals(0.55));
      });

      test('bestBid returns null for empty bids', () {
        final book = OrderBook.fromJson(minimalJson);
        expect(book.bestBid, isNull);
      });

      test('bestAsk returns lowest ask', () {
        final book = OrderBook.fromJson({
          ...minimalJson,
          'asks': [
            {'price': '0.56', 'size': '150'},
            {'price': '0.57', 'size': '250'},
          ],
        });
        
        expect(book.bestAsk, equals(0.56));
      });

      test('spread calculates correctly', () {
        final book = OrderBook.fromJson({
          ...minimalJson,
          'bids': [{'price': '0.55', 'size': '100'}],
          'asks': [{'price': '0.57', 'size': '100'}],
        });
        
        expect(book.spread, closeTo(0.02, 0.001));
      });

      test('midpoint calculates correctly', () {
        final book = OrderBook.fromJson({
          ...minimalJson,
          'bids': [{'price': '0.55', 'size': '100'}],
          'asks': [{'price': '0.57', 'size': '100'}],
        });
        
        expect(book.midpoint, closeTo(0.56, 0.001));
      });
    });

    group('Equatable', () {
      test('equal objects have same hashCode', () {
        final book1 = OrderBook.fromJson(minimalJson);
        final book2 = OrderBook.fromJson(minimalJson);
        
        expect(book1.hashCode, equals(book2.hashCode));
      });

      test('different objects are not equal', () {
        final book1 = OrderBook.fromJson(minimalJson);
        final book2 = OrderBook.fromJson({
          ...minimalJson,
          'hash': 'different',
        });
        
        expect(book1, isNot(equals(book2)));
      });
    });
  });
}
```

---

## API Client Test Pattern

### test/integration/gamma_client_test.dart

```dart
import 'dart:convert';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:polybrainz_polymarket/src/gamma/gamma_client.dart';
import 'package:polybrainz_polymarket/src/core/api_client.dart';
import 'package:polybrainz_polymarket/src/core/exceptions.dart';

void main() {
  group('GammaClient', () {
    late MockClient mockHttpClient;
    late GammaClient client;

    setUp(() {
      mockHttpClient = MockClient((request) async {
        // Default: return empty response
        return http.Response('[]', 200);
      });
      
      client = GammaClient(
        client: ApiClient(
          baseUrl: 'https://gamma-api.polymarket.com',
          httpClient: mockHttpClient,
        ),
      );
    });

    tearDown(() {
      client.close();
    });

    group('events.listEvents', () {
      test('returns list of events', () async {
        mockHttpClient = MockClient((request) async {
          expect(request.url.path, equals('/events'));
          
          return http.Response(
            jsonEncode([
              {
                'id': '1',
                'title': 'Test Event',
                'slug': 'test-event',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        
        client = GammaClient(
          client: ApiClient(
            baseUrl: 'https://gamma-api.polymarket.com',
            httpClient: mockHttpClient,
          ),
        );

        final events = await client.events.listEvents(limit: 10);
        
        expect(events.length, equals(1));
        expect(events[0].id, equals('1'));
        expect(events[0].title, equals('Test Event'));
      });

      test('handles empty response', () async {
        mockHttpClient = MockClient((request) async {
          return http.Response('[]', 200);
        });
        
        client = GammaClient(
          client: ApiClient(
            baseUrl: 'https://gamma-api.polymarket.com',
            httpClient: mockHttpClient,
          ),
        );

        final events = await client.events.listEvents();
        
        expect(events, isEmpty);
      });

      test('passes query parameters correctly', () async {
        mockHttpClient = MockClient((request) async {
          expect(request.url.queryParameters['limit'], equals('10'));
          expect(request.url.queryParameters['offset'], equals('20'));
          expect(request.url.queryParameters['closed'], equals('false'));
          
          return http.Response('[]', 200);
        });
        
        client = GammaClient(
          client: ApiClient(
            baseUrl: 'https://gamma-api.polymarket.com',
            httpClient: mockHttpClient,
          ),
        );

        await client.events.listEvents(
          limit: 10,
          offset: 20,
          closed: false,
        );
      });
    });

    group('error handling', () {
      test('throws NotFoundException on 404', () async {
        mockHttpClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'Event not found'}),
            404,
          );
        });
        
        client = GammaClient(
          client: ApiClient(
            baseUrl: 'https://gamma-api.polymarket.com',
            httpClient: mockHttpClient,
          ),
        );

        expect(
          () => client.events.getById(999),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('throws RateLimitException on 429', () async {
        mockHttpClient = MockClient((request) async {
          return http.Response(
            'Rate limited',
            429,
            headers: {'retry-after': '60'},
          );
        });
        
        client = GammaClient(
          client: ApiClient(
            baseUrl: 'https://gamma-api.polymarket.com',
            httpClient: mockHttpClient,
            maxRetries: 1, // Don't retry in tests
          ),
        );

        expect(
          () => client.events.listEvents(),
          throwsA(isA<RateLimitException>()),
        );
      });

      test('throws ServerException on 500', () async {
        mockHttpClient = MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });
        
        client = GammaClient(
          client: ApiClient(
            baseUrl: 'https://gamma-api.polymarket.com',
            httpClient: mockHttpClient,
            maxRetries: 1,
          ),
        );

        expect(
          () => client.events.listEvents(),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });
}
```

---

## WebSocket Test Pattern

### test/integration/websocket_test.dart

```dart
import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:polybrainz_polymarket/src/websocket/clob_websocket.dart';

void main() {
  group('ClobWebSocket', () {
    // Note: These are integration tests that require a mock WebSocket server
    // For unit tests, mock the WebSocketChannel

    group('message parsing', () {
      test('parses book message correctly', () {
        final json = {
          'event_type': 'book',
          'asset_id': 'token-123',
          'market': '0xabc',
          'timestamp': 1234567890,
          'hash': 'hash123',
          'bids': [
            {'price': '0.55', 'size': '100'},
          ],
          'asks': [
            {'price': '0.56', 'size': '150'},
          ],
        };

        // Test the parsing logic directly
        // In a real test, you'd send this through the WebSocket
      });

      test('parses price_change message correctly', () {
        final json = {
          'event_type': 'price_change',
          'asset_id': 'token-123',
          'market': '0xabc',
          'timestamp': 1234567890,
          'price_changes': [
            {'asset_id': 'token-123', 'price': '0.55'},
            {'asset_id': 'token-456', 'price': '0.45'},
          ],
        };

        // Test parsing
      });
    });

    group('subscription management', () {
      test('tracks subscribed assets', () {
        final ws = ClobWebSocket();
        
        // Test that subscriptions are tracked
        // ws.subscribeToMarket(['token-1', 'token-2']);
        // Verify internal state
      });
    });
  });
}
```

---

## Test Fixtures

### test/fixtures/clob/order_book.json

```json
{
  "market": "0x1234567890abcdef1234567890abcdef12345678",
  "asset_id": "71321045679252212594626385532706912750332728571942532289631379312455583992563",
  "timestamp": "1704067200",
  "hash": "abc123def456",
  "bids": [
    {"price": "0.55", "size": "1000"},
    {"price": "0.54", "size": "2000"},
    {"price": "0.53", "size": "3000"}
  ],
  "asks": [
    {"price": "0.56", "size": "1500"},
    {"price": "0.57", "size": "2500"},
    {"price": "0.58", "size": "3500"}
  ],
  "min_tick_size": "0.01",
  "min_order_size": "5",
  "neg_risk": false
}
```

### test/fixtures/gamma/event.json

```json
{
  "id": "12345",
  "ticker": "BTC-100K",
  "slug": "will-bitcoin-reach-100k",
  "title": "Will Bitcoin reach $100,000 by end of 2024?",
  "description": "This market will resolve to Yes if...",
  "active": true,
  "closed": false,
  "archived": false,
  "new": false,
  "featured": true,
  "liquidity": 500000.00,
  "volume": 1500000.00,
  "volume_24hr": 50000.00,
  "open_interest": 250000.00,
  "neg_risk": false,
  "enable_order_book": true,
  "markets": [
    {
      "id": "67890",
      "condition_id": "0xabcdef123456",
      "slug": "will-bitcoin-reach-100k-yes",
      "question": "Will Bitcoin reach $100,000?",
      "active": true,
      "closed": false,
      "accepting_orders": true,
      "enable_order_book": true,
      "market_maker_address": "0x1234567890abcdef"
    }
  ],
  "tags": [
    {"id": 1, "label": "Crypto", "slug": "crypto"}
  ],
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-15T12:00:00Z"
}
```

---

## Running Tests

```bash
# Run all tests
dart test

# Run with coverage
dart test --coverage=coverage

# Run specific test file
dart test test/unit/enums/order_side_test.dart

# Run tests matching pattern
dart test --name "OrderBook"

# Run with verbose output
dart test --reporter expanded
```

---

## Coverage Requirements

| Component | Minimum Coverage |
|-----------|-----------------|
| Enums | 100% |
| Models | 95% |
| Core (exceptions, result) | 90% |
| API Clients | 80% |
| WebSocket | 75% |

---

## Test Helpers

### test/helpers/fixtures.dart

```dart
import 'dart:convert';
import 'dart:io';

/// Load a JSON fixture file.
Map<String, dynamic> loadFixture(String path) {
  final file = File('test/fixtures/$path');
  return jsonDecode(file.readAsStringSync());
}

/// Load a list fixture.
List<dynamic> loadListFixture(String path) {
  final file = File('test/fixtures/$path');
  return jsonDecode(file.readAsStringSync());
}
```

### test/helpers/mock_http.dart

```dart
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Create a mock client that returns the given response.
MockClient createMockClient({
  required int statusCode,
  required String body,
  Map<String, String>? headers,
}) {
  return MockClient((request) async {
    return http.Response(
      body,
      statusCode,
      headers: {
        'content-type': 'application/json',
        ...?headers,
      },
    );
  });
}

/// Create a mock client that throws an error.
MockClient createErrorMockClient(Exception error) {
  return MockClient((request) async {
    throw error;
  });
}
```

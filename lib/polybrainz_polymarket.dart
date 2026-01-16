/// Dart SDK for Polymarket APIs (Gamma, CLOB, Data, WebSocket).
///
/// This package provides a comprehensive wrapper for all Polymarket APIs:
/// - **Gamma API**: Market discovery, events, tags, comments, profiles
/// - **CLOB API**: Order book, pricing, orders, trades
/// - **Data API**: Positions, trade history, activity, leaderboard
/// - **WebSocket**: Real-time market data, user updates
///
/// ## Quick Start
///
/// ```dart
/// import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';
///
/// void main() async {
///   // Public client (no auth required)
///   final client = PolymarketClient.public();
///
///   // Get active events
///   final events = await client.gamma.events.listEvents(
///     limit: 10,
///     closed: false,
///   );
///
///   // Get order book
///   final book = await client.clob.orderbook.getOrderBook('token-id');
///   print('Best bid: ${book.bids.first.price}');
///
///   // Authenticated client (for trading)
///   final authClient = PolymarketClient.authenticated(
///     credentials: ApiCredentials(
///       apiKey: 'your-api-key',
///       secret: 'your-secret',
///       passphrase: 'your-passphrase',
///     ),
///     funder: '0x...',
///   );
///
///   // Stream real-time prices
///   authClient.clobWebSocket.subscribeToPriceChanges(['token-id']).listen((msg) {
///     print('Price: ${msg.priceChanges}');
///   });
/// }
/// ```
library polybrainz_polymarket;

// Main client
export 'src/polymarket_client.dart';

// Core
export 'src/core/core.dart';

// Enums
export 'src/enums/enums.dart';

// Auth
export 'src/auth/auth.dart';

// Gamma API
export 'src/gamma/gamma.dart';

// CLOB API
export 'src/clob/clob.dart';

// Data API
export 'src/data/data.dart';

// WebSocket
export 'src/websocket/websocket.dart';

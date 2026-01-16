# WebSocket Clients

Real-time data streams for order books, prices, and user updates.

---

## WebSocket URLs

| WebSocket | URL | Auth | Purpose |
|-----------|-----|------|---------|
| CLOB | `wss://ws-subscriptions-clob.polymarket.com/ws/` | Partial | Order books, prices, user orders |
| RTDS | `wss://ws-live-data.polymarket.com` | No | Crypto prices, comments |
| Sports | `wss://sports-api.polymarket.com/ws` | No | Live game updates |

---

## src/websocket/clob_websocket.dart

```dart
import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/constants.dart';
import '../core/exceptions.dart';
import '../auth/auth_service.dart';
import '../enums/ws_channel.dart';
import '../enums/ws_event_type.dart';
import 'models/ws_message.dart';
import 'models/book_message.dart';
import 'models/price_change_message.dart';
import 'models/last_trade_price_message.dart';
import 'models/trade_message.dart';
import 'models/order_message.dart';

/// WebSocket client for CLOB real-time data.
class ClobWebSocket {
  final String url;
  final AuthService? _auth;
  final Duration heartbeatInterval;
  final Duration reconnectDelay;
  final int maxReconnectAttempts;

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  int _reconnectAttempts = 0;
  bool _disposed = false;
  bool _intentionalClose = false;
  
  final Set<String> _subscribedMarketAssets = {};
  final Set<String> _subscribedUserAssets = {};
  
  final _messageController = StreamController<WsMessage>.broadcast();
  final _connectionController = StreamController<ClobWsConnectionState>.broadcast();

  ClobWebSocket({
    String? url,
    AuthService? auth,
    this.heartbeatInterval = PolymarketConstants.wsHeartbeatInterval,
    this.reconnectDelay = PolymarketConstants.wsReconnectDelay,
    this.maxReconnectAttempts = PolymarketConstants.wsMaxReconnectAttempts,
  }) : url = url ?? PolymarketConstants.clobWssUrl,
       _auth = auth;

  /// Stream of all WebSocket messages
  Stream<WsMessage> get messages => _messageController.stream;

  /// Stream of connection state changes
  Stream<ClobWsConnectionState> get connectionState => _connectionController.stream;

  /// Whether connected
  bool get isConnected => _channel != null && !_disposed;

  // ============ Typed Message Streams ============

  /// Stream of order book updates
  Stream<BookMessage> get bookUpdates => messages
      .where((m) => m.eventType == WsEventType.book)
      .map((m) => m as BookMessage);

  /// Stream of price changes
  Stream<PriceChangeMessage> get priceChanges => messages
      .where((m) => m.eventType == WsEventType.priceChange)
      .map((m) => m as PriceChangeMessage);

  /// Stream of last trade price updates
  Stream<LastTradePriceMessage> get lastTradePrices => messages
      .where((m) => m.eventType == WsEventType.lastTradePrice)
      .map((m) => m as LastTradePriceMessage);

  /// Stream of user trades (requires auth)
  Stream<TradeWsMessage> get userTrades => messages
      .where((m) => m.eventType == WsEventType.trade)
      .map((m) => m as TradeWsMessage);

  /// Stream of user order updates (requires auth)
  Stream<OrderWsMessage> get userOrders => messages
      .where((m) => m.eventType == WsEventType.order)
      .map((m) => m as OrderWsMessage);

  // ============ Connection Management ============

  /// Connect to WebSocket server.
  Future<void> connect() async {
    if (_disposed) {
      throw const WebSocketException('WebSocket client has been disposed');
    }
    
    if (_channel != null) return;

    _intentionalClose = false;
    _connectionController.add(ClobWsConnectionState.connecting);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await _channel!.ready;
      
      _reconnectAttempts = 0;
      _connectionController.add(ClobWsConnectionState.connected);
      
      _startHeartbeat();
      _listenToMessages();
      
      // Resubscribe to assets after reconnect
      await _resubscribe();
      
    } catch (e) {
      _connectionController.add(ClobWsConnectionState.disconnected);
      _scheduleReconnect();
      rethrow;
    }
  }

  /// Disconnect from WebSocket server.
  Future<void> disconnect() async {
    _intentionalClose = true;
    await _cleanup();
    _connectionController.add(ClobWsConnectionState.disconnected);
  }

  // ============ Market Channel (Public) ============

  /// Subscribe to market data for assets.
  void subscribeToMarket(List<String> assetIds) {
    _subscribedMarketAssets.addAll(assetIds);
    _send({
      'type': WsChannel.market.toJson(),
      'assets_ids': assetIds,
    });
  }

  /// Unsubscribe from market data.
  void unsubscribeFromMarket(List<String> assetIds) {
    _subscribedMarketAssets.removeAll(assetIds);
    _send({
      'type': 'unsubscribe',
      'assets_ids': assetIds,
    });
  }

  // ============ User Channel (Authenticated) ============

  /// Subscribe to user data for assets (requires auth).
  /// 
  /// Receives order and trade updates for your orders.
  void subscribeToUser(List<String> assetIds) {
    if (_auth == null || !_auth.hasCredentials) {
      throw const AuthenticationException(
        'Authentication required for user channel',
      );
    }

    _subscribedUserAssets.addAll(assetIds);
    
    // User channel requires auth headers in subscription
    final authHeaders = _auth.getAuthHeaders(
      method: 'GET',
      path: '/ws/user',
    );
    
    _send({
      'type': WsChannel.user.toJson(),
      'assets_ids': assetIds,
      'auth': authHeaders,
    });
  }

  /// Unsubscribe from user data.
  void unsubscribeFromUser(List<String> assetIds) {
    _subscribedUserAssets.removeAll(assetIds);
    _send({
      'type': 'unsubscribe',
      'assets_ids': assetIds,
    });
  }

  // ============ Convenience Methods ============

  /// Subscribe to price changes for specific tokens.
  Stream<PriceChangeMessage> subscribeToPriceChanges(List<String> tokenIds) {
    subscribeToMarket(tokenIds);
    return priceChanges.where((m) => tokenIds.contains(m.assetId));
  }

  /// Subscribe to order book for a specific token.
  Stream<BookMessage> subscribeToOrderBook(String tokenId) {
    subscribeToMarket([tokenId]);
    return bookUpdates.where((m) => m.assetId == tokenId);
  }

  /// Subscribe to your orders for specific tokens.
  Stream<OrderWsMessage> subscribeToMyOrders(List<String> tokenIds) {
    subscribeToUser(tokenIds);
    return userOrders.where((m) => tokenIds.contains(m.assetId));
  }

  // ============ Internal Methods ============

  void _send(Map<String, dynamic> message) {
    if (_channel == null) {
      throw const WebSocketException('WebSocket not connected');
    }
    _channel!.sink.add(jsonEncode(message));
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
      if (_channel != null) {
        try {
          _channel!.sink.add('ping');
        } catch (_) {}
      }
    });
  }

  void _listenToMessages() {
    _channel!.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDisconnect,
    );
  }

  void _handleMessage(dynamic data) {
    if (data == 'pong') return;
    
    try {
      final json = jsonDecode(data as String);
      
      // Handle array of messages
      if (json is List) {
        for (final item in json) {
          if (item is Map<String, dynamic>) {
            _parseAndEmit(item);
          }
        }
      } else if (json is Map<String, dynamic>) {
        _parseAndEmit(json);
      }
    } catch (e) {
      // Ignore parse errors
    }
  }

  void _parseAndEmit(Map<String, dynamic> json) {
    final eventType = json['event_type'] as String?;
    if (eventType == null) return;

    WsMessage? message;
    
    switch (eventType) {
      case 'book':
        message = BookMessage.fromJson(json);
        break;
      case 'price_change':
        message = PriceChangeMessage.fromJson(json);
        break;
      case 'last_trade_price':
        message = LastTradePriceMessage.fromJson(json);
        break;
      case 'trade':
        message = TradeWsMessage.fromJson(json);
        break;
      case 'order':
        message = OrderWsMessage.fromJson(json);
        break;
      default:
        message = WsMessage.fromJson(json);
    }

    _messageController.add(message);
  }

  void _handleError(Object error) {
    _messageController.addError(WebSocketException(
      'WebSocket error',
      originalError: error,
    ));
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    _connectionController.add(ClobWsConnectionState.disconnected);
    
    if (!_intentionalClose && !_disposed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _intentionalClose) return;
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _messageController.addError(const WebSocketException(
        'Max reconnect attempts exceeded',
      ));
      return;
    }

    _cleanup();
    _connectionController.add(ClobWsConnectionState.reconnecting);
    
    final delay = reconnectDelay * (_reconnectAttempts + 1);
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  Future<void> _resubscribe() async {
    if (_subscribedMarketAssets.isNotEmpty) {
      subscribeToMarket(_subscribedMarketAssets.toList());
    }
    if (_subscribedUserAssets.isNotEmpty && _auth?.hasCredentials == true) {
      subscribeToUser(_subscribedUserAssets.toList());
    }
  }

  Future<void> _cleanup() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void dispose() {
    _disposed = true;
    _cleanup();
    _messageController.close();
    _connectionController.close();
  }
}

/// Connection state for CLOB WebSocket.
enum ClobWsConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}
```

---

## src/websocket/rtds_websocket.dart

```dart
import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/constants.dart';
import '../core/exceptions.dart';
import '../enums/rtds_topic.dart';
import 'models/crypto_price_message.dart';
import 'models/comment_message.dart';

/// WebSocket client for RTDS (Real-Time Data Stream).
/// 
/// Provides crypto prices and comment streams.
class RtdsWebSocket {
  final String url;
  final Duration heartbeatInterval;
  final Duration reconnectDelay;

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  bool _disposed = false;
  bool _intentionalClose = false;
  int _reconnectAttempts = 0;
  
  final Set<RtdsTopic> _subscribedTopics = {};
  
  final _cryptoPriceController = StreamController<CryptoPriceMessage>.broadcast();
  final _commentController = StreamController<CommentMessage>.broadcast();

  RtdsWebSocket({
    String? url,
    this.heartbeatInterval = const Duration(seconds: 30),
    this.reconnectDelay = const Duration(seconds: 5),
  }) : url = url ?? PolymarketConstants.rtdsWssUrl;

  /// Stream of crypto price updates
  Stream<CryptoPriceMessage> get cryptoPrices => _cryptoPriceController.stream;

  /// Stream of comment updates
  Stream<CommentMessage> get comments => _commentController.stream;

  /// Whether connected
  bool get isConnected => _channel != null && !_disposed;

  /// Connect and subscribe to topics.
  Future<void> connect({List<RtdsTopic>? topics}) async {
    if (_disposed) {
      throw const WebSocketException('WebSocket client has been disposed');
    }
    
    if (_channel != null) return;

    _intentionalClose = false;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await _channel!.ready;
      
      _reconnectAttempts = 0;
      _startHeartbeat();
      _listenToMessages();
      
      // Subscribe to requested topics
      if (topics != null) {
        for (final topic in topics) {
          subscribe(topic);
        }
      }
      
      // Resubscribe to previous topics on reconnect
      for (final topic in _subscribedTopics) {
        _send({'topic': topic.toJson()});
      }
      
    } catch (e) {
      _scheduleReconnect();
      rethrow;
    }
  }

  /// Disconnect.
  Future<void> disconnect() async {
    _intentionalClose = true;
    await _cleanup();
  }

  /// Subscribe to a topic.
  void subscribe(RtdsTopic topic) {
    _subscribedTopics.add(topic);
    _send({'topic': topic.toJson()});
  }

  /// Unsubscribe from a topic.
  void unsubscribe(RtdsTopic topic) {
    _subscribedTopics.remove(topic);
    _send({'unsubscribe': topic.toJson()});
  }

  void _send(Map<String, dynamic> message) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode(message));
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
      if (_channel != null) {
        try {
          _channel!.sink.add('ping');
        } catch (_) {}
      }
    });
  }

  void _listenToMessages() {
    _channel!.stream.listen(
      _handleMessage,
      onError: (_) => _scheduleReconnect(),
      onDone: () {
        if (!_intentionalClose && !_disposed) {
          _scheduleReconnect();
        }
      },
    );
  }

  void _handleMessage(dynamic data) {
    if (data == 'pong') return;
    
    try {
      final json = jsonDecode(data as String);
      if (json is! Map<String, dynamic>) return;
      
      final topic = json['topic'] as String?;
      
      if (topic == 'crypto_prices' || topic == 'crypto_prices_chainlink') {
        _cryptoPriceController.add(CryptoPriceMessage.fromJson(json));
      } else if (topic == 'comments') {
        _commentController.add(CommentMessage.fromJson(json));
      }
    } catch (_) {}
  }

  void _scheduleReconnect() {
    if (_disposed || _intentionalClose) return;
    if (_reconnectAttempts >= 10) return;

    _cleanup();
    
    final delay = reconnectDelay * (_reconnectAttempts + 1);
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  Future<void> _cleanup() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void dispose() {
    _disposed = true;
    _cleanup();
    _cryptoPriceController.close();
    _commentController.close();
  }
}
```

---

## src/websocket/models/ws_message.dart

```dart
import 'package:equatable/equatable.dart';
import '../../enums/ws_event_type.dart';

/// Base WebSocket message.
class WsMessage extends Equatable {
  final WsEventType eventType;
  final String? assetId;
  final String? market;
  final int? timestamp;
  final Map<String, dynamic> raw;

  const WsMessage({
    required this.eventType,
    this.assetId,
    this.market,
    this.timestamp,
    required this.raw,
  });

  factory WsMessage.fromJson(Map<String, dynamic> json) {
    return WsMessage(
      eventType: WsEventType.fromJson(json['event_type'] as String),
      assetId: json['asset_id'] as String?,
      market: json['market'] as String?,
      timestamp: json['timestamp'] as int?,
      raw: json,
    );
  }

  @override
  List<Object?> get props => [eventType, assetId, market, timestamp];
}
```

---

## src/websocket/models/book_message.dart

```dart
import 'package:equatable/equatable.dart';
import '../../enums/ws_event_type.dart';
import '../../clob/models/order_summary.dart';
import 'ws_message.dart';

/// Order book update message.
class BookMessage extends WsMessage {
  final List<OrderSummary> bids;
  final List<OrderSummary> asks;
  final String hash;

  const BookMessage({
    required super.assetId,
    required super.market,
    required super.timestamp,
    required this.bids,
    required this.asks,
    required this.hash,
    required super.raw,
  }) : super(eventType: WsEventType.book);

  factory BookMessage.fromJson(Map<String, dynamic> json) {
    return BookMessage(
      assetId: json['asset_id'] as String?,
      market: json['market'] as String?,
      timestamp: json['timestamp'] as int?,
      bids: (json['bids'] as List? ?? [])
          .map((b) => OrderSummary.fromJson(b as Map<String, dynamic>))
          .toList(),
      asks: (json['asks'] as List? ?? [])
          .map((a) => OrderSummary.fromJson(a as Map<String, dynamic>))
          .toList(),
      hash: json['hash'] as String? ?? '',
      raw: json,
    );
  }

  double? get bestBid => bids.isNotEmpty ? bids.first.priceNum : null;
  double? get bestAsk => asks.isNotEmpty ? asks.first.priceNum : null;
  double? get spread => (bestBid != null && bestAsk != null) 
      ? bestAsk! - bestBid! 
      : null;

  @override
  List<Object?> get props => [...super.props, hash];
}
```

---

## src/websocket/models/price_change_message.dart

```dart
import 'package:equatable/equatable.dart';
import '../../enums/ws_event_type.dart';
import 'ws_message.dart';

/// Price change notification.
class PriceChangeMessage extends WsMessage {
  final List<PriceChange> priceChanges;

  const PriceChangeMessage({
    required super.assetId,
    required super.market,
    required super.timestamp,
    required this.priceChanges,
    required super.raw,
  }) : super(eventType: WsEventType.priceChange);

  factory PriceChangeMessage.fromJson(Map<String, dynamic> json) {
    return PriceChangeMessage(
      assetId: json['asset_id'] as String?,
      market: json['market'] as String?,
      timestamp: json['timestamp'] as int?,
      priceChanges: (json['price_changes'] as List? ?? [])
          .map((p) => PriceChange.fromJson(p as Map<String, dynamic>))
          .toList(),
      raw: json,
    );
  }

  /// Get price for a specific token
  double? getPriceForToken(String tokenId) {
    try {
      return priceChanges.firstWhere((p) => p.assetId == tokenId).price;
    } catch (_) {
      return null;
    }
  }
}

/// Individual price change.
class PriceChange extends Equatable {
  final String assetId;
  final double price;

  const PriceChange({
    required this.assetId,
    required this.price,
  });

  factory PriceChange.fromJson(Map<String, dynamic> json) {
    return PriceChange(
      assetId: json['asset_id'] as String,
      price: double.parse(json['price'].toString()),
    );
  }

  @override
  List<Object?> get props => [assetId, price];
}
```

---

## src/websocket/models/last_trade_price_message.dart

```dart
import '../../enums/ws_event_type.dart';
import 'ws_message.dart';

/// Last trade price update.
class LastTradePriceMessage extends WsMessage {
  final double price;
  final String side;
  final double size;

  const LastTradePriceMessage({
    required super.assetId,
    required super.market,
    required super.timestamp,
    required this.price,
    required this.side,
    required this.size,
    required super.raw,
  }) : super(eventType: WsEventType.lastTradePrice);

  factory LastTradePriceMessage.fromJson(Map<String, dynamic> json) {
    return LastTradePriceMessage(
      assetId: json['asset_id'] as String?,
      market: json['market'] as String?,
      timestamp: json['timestamp'] as int?,
      price: double.parse(json['price'].toString()),
      side: json['side'] as String? ?? '',
      size: double.parse(json['size']?.toString() ?? '0'),
      raw: json,
    );
  }
}
```

---

## src/websocket/models/trade_message.dart

```dart
import '../../enums/ws_event_type.dart';
import 'ws_message.dart';

/// User trade notification (user channel).
class TradeWsMessage extends WsMessage {
  final String tradeId;
  final String status;
  final String side;
  final double size;
  final double price;
  final String? transactionHash;
  final String outcome;

  const TradeWsMessage({
    required super.assetId,
    required super.market,
    required super.timestamp,
    required this.tradeId,
    required this.status,
    required this.side,
    required this.size,
    required this.price,
    this.transactionHash,
    required this.outcome,
    required super.raw,
  }) : super(eventType: WsEventType.trade);

  factory TradeWsMessage.fromJson(Map<String, dynamic> json) {
    return TradeWsMessage(
      assetId: json['asset_id'] as String?,
      market: json['market'] as String?,
      timestamp: json['timestamp'] as int?,
      tradeId: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      side: json['side'] as String? ?? '',
      size: double.parse(json['size']?.toString() ?? '0'),
      price: double.parse(json['price']?.toString() ?? '0'),
      transactionHash: json['transaction_hash'] as String?,
      outcome: json['outcome'] as String? ?? '',
      raw: json,
    );
  }
}
```

---

## src/websocket/models/order_message.dart

```dart
import '../../enums/ws_event_type.dart';
import '../../enums/order_action_type.dart';
import 'ws_message.dart';

/// User order update notification (user channel).
class OrderWsMessage extends WsMessage {
  final String orderId;
  final OrderActionType action;
  final String side;
  final double price;
  final double originalSize;
  final double sizeMatched;
  final String outcome;
  final String? type;

  const OrderWsMessage({
    required super.assetId,
    required super.market,
    required super.timestamp,
    required this.orderId,
    required this.action,
    required this.side,
    required this.price,
    required this.originalSize,
    required this.sizeMatched,
    required this.outcome,
    this.type,
    required super.raw,
  }) : super(eventType: WsEventType.order);

  factory OrderWsMessage.fromJson(Map<String, dynamic> json) {
    return OrderWsMessage(
      assetId: json['asset_id'] as String?,
      market: json['market'] as String?,
      timestamp: json['timestamp'] as int?,
      orderId: json['id'] as String? ?? '',
      action: OrderActionType.fromJson(json['action'] as String? ?? 'UPDATE'),
      side: json['side'] as String? ?? '',
      price: double.parse(json['price']?.toString() ?? '0'),
      originalSize: double.parse(json['original_size']?.toString() ?? '0'),
      sizeMatched: double.parse(json['size_matched']?.toString() ?? '0'),
      outcome: json['outcome'] as String? ?? '',
      type: json['type'] as String?,
      raw: json,
    );
  }

  double get remainingSize => originalSize - sizeMatched;
  bool get isFilled => remainingSize <= 0;
}
```

---

## src/websocket/models/crypto_price_message.dart

```dart
import 'package:equatable/equatable.dart';

/// Crypto price update from RTDS.
class CryptoPriceMessage extends Equatable {
  final String topic;
  final Map<String, double> prices;
  final int? timestamp;

  const CryptoPriceMessage({
    required this.topic,
    required this.prices,
    this.timestamp,
  });

  factory CryptoPriceMessage.fromJson(Map<String, dynamic> json) {
    final pricesData = json['data'] as Map<String, dynamic>? ?? {};
    final prices = <String, double>{};
    
    pricesData.forEach((key, value) {
      if (value is Map && value['price'] != null) {
        prices[key] = double.parse(value['price'].toString());
      } else if (value is num) {
        prices[key] = value.toDouble();
      }
    });

    return CryptoPriceMessage(
      topic: json['topic'] as String? ?? '',
      prices: prices,
      timestamp: json['timestamp'] as int?,
    );
  }

  double? getPrice(String symbol) => prices[symbol.toUpperCase()];

  @override
  List<Object?> get props => [topic, prices, timestamp];
}
```

---

## src/websocket/models/comment_message.dart

```dart
import 'package:equatable/equatable.dart';
import '../../gamma/models/profile.dart';

/// Comment update from RTDS.
class CommentMessage extends Equatable {
  final String topic;
  final String id;
  final String body;
  final String? parentEntityType;
  final int? parentEntityId;
  final String? userAddress;
  final DateTime? createdAt;
  final Profile? profile;

  const CommentMessage({
    required this.topic,
    required this.id,
    required this.body,
    this.parentEntityType,
    this.parentEntityId,
    this.userAddress,
    this.createdAt,
    this.profile,
  });

  factory CommentMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    return CommentMessage(
      topic: json['topic'] as String? ?? 'comments',
      id: data['id'] as String? ?? '',
      body: data['body'] as String? ?? '',
      parentEntityType: data['parent_entity_type'] as String?,
      parentEntityId: data['parent_entity_id'] as int?,
      userAddress: data['user_address'] as String?,
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at'] as String) 
          : null,
      profile: data['profile'] != null 
          ? Profile.fromJson(data['profile'] as Map<String, dynamic>) 
          : null,
    );
  }

  @override
  List<Object?> get props => [id, body, parentEntityId];
}
```

---

## Barrel Export

### src/websocket/websocket.dart

```dart
export 'clob_websocket.dart';
export 'rtds_websocket.dart';
export 'models/ws_message.dart';
export 'models/book_message.dart';
export 'models/price_change_message.dart';
export 'models/last_trade_price_message.dart';
export 'models/trade_message.dart';
export 'models/order_message.dart';
export 'models/crypto_price_message.dart';
export 'models/comment_message.dart';
```

---

## Usage Examples

```dart
// Subscribe to price changes
final ws = ClobWebSocket();
await ws.connect();

ws.subscribeToPriceChanges(['token-id-1', 'token-id-2']).listen((msg) {
  for (final change in msg.priceChanges) {
    print('${change.assetId}: ${change.price}');
  }
});

// Subscribe to order book
ws.subscribeToOrderBook('token-id').listen((book) {
  print('Best bid: ${book.bestBid}, Best ask: ${book.bestAsk}');
});

// Subscribe to your orders (authenticated)
final authWs = ClobWebSocket(auth: authService);
await authWs.connect();

authWs.subscribeToMyOrders(['token-id']).listen((order) {
  print('Order ${order.orderId}: ${order.action}');
});

// Crypto prices from RTDS
final rtds = RtdsWebSocket();
await rtds.connect(topics: [RtdsTopic.cryptoPrices]);

rtds.cryptoPrices.listen((msg) {
  print('BTC: ${msg.getPrice('BTC')}');
  print('ETH: ${msg.getPrice('ETH')}');
});
```

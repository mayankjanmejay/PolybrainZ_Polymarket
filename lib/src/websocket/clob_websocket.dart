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
  final _connectionController =
      StreamController<ClobWsConnectionState>.broadcast();

  ClobWebSocket({
    String? url,
    AuthService? auth,
    this.heartbeatInterval = PolymarketConstants.wsHeartbeatInterval,
    this.reconnectDelay = PolymarketConstants.wsReconnectDelay,
    this.maxReconnectAttempts = PolymarketConstants.wsMaxReconnectAttempts,
  })  : url = url ?? PolymarketConstants.clobWssUrl,
        _auth = auth;

  /// Stream of all WebSocket messages
  Stream<WsMessage> get messages => _messageController.stream;

  /// Stream of connection state changes
  Stream<ClobWsConnectionState> get connectionState =>
      _connectionController.stream;

  /// Whether connected
  bool get isConnected => _channel != null && !_disposed;

  // ============ Typed Message Streams ============

  /// Stream of order book updates
  Stream<BookMessage> get bookUpdates =>
      messages.where((m) => m.eventType == WsEventType.book).map((m) => m as BookMessage);

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

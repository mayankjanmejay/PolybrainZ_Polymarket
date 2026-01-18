import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../enums/ws_subscription_type.dart';
import 'constants.dart';
import 'exceptions.dart';

/// Base WebSocket client with auto-reconnect.
class WebSocketClient {
  final String url;
  final Duration heartbeatInterval;
  final Duration reconnectDelay;
  final int maxReconnectAttempts;

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  int _reconnectAttempts = 0;
  bool _disposed = false;
  bool _intentionalClose = false;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<ConnectionState>.broadcast();

  WebSocketClient({
    required this.url,
    this.heartbeatInterval = PolymarketConstants.wsHeartbeatInterval,
    this.reconnectDelay = PolymarketConstants.wsReconnectDelay,
    this.maxReconnectAttempts = PolymarketConstants.wsMaxReconnectAttempts,
  });

  /// Stream of parsed JSON messages
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Stream of connection state changes
  Stream<ConnectionState> get connectionState => _connectionController.stream;

  /// Whether the WebSocket is connected
  bool get isConnected => _channel != null && !_disposed;

  /// Connect to WebSocket server.
  Future<void> connect() async {
    if (_disposed) {
      throw const WebSocketException('WebSocket client has been disposed');
    }

    if (_channel != null) {
      return; // Already connected
    }

    _intentionalClose = false;
    _connectionController.add(ConnectionState.connecting);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await _channel!.ready;

      _reconnectAttempts = 0;
      _connectionController.add(ConnectionState.connected);

      _startHeartbeat();
      _listenToMessages();
    } catch (e) {
      _connectionController.add(ConnectionState.disconnected);
      _scheduleReconnect();
      rethrow;
    }
  }

  /// Disconnect from WebSocket server.
  Future<void> disconnect() async {
    _intentionalClose = true;
    await _cleanup();
    _connectionController.add(ConnectionState.disconnected);
  }

  /// Send a message.
  void send(Map<String, dynamic> message) {
    if (_channel == null) {
      throw const WebSocketException('WebSocket not connected');
    }
    _channel!.sink.add(jsonEncode(message));
  }

  /// Send a subscription message.
  void subscribe(
    List<String> assetIds, {
    WsSubscriptionType type = WsSubscriptionType.market,
  }) {
    send({
      'type': type.value,
      'assets_ids': assetIds,
    });
  }

  /// Unsubscribe from assets.
  void unsubscribe(List<String> assetIds) {
    send({
      'type': WsSubscriptionType.unsubscribe.value,
      'assets_ids': assetIds,
    });
  }

  /// Dispose the client.
  void dispose() {
    _disposed = true;
    _cleanup();
    _messageController.close();
    _connectionController.close();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
      if (_channel != null) {
        try {
          _channel!.sink.add('ping');
        } catch (_) {
          // Ignore ping errors
        }
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
    if (data == 'pong') return; // Heartbeat response

    try {
      final message = jsonDecode(data as String);
      if (message is Map<String, dynamic>) {
        _messageController.add(message);
      } else if (message is List) {
        // Some endpoints return arrays of messages
        for (final item in message) {
          if (item is Map<String, dynamic>) {
            _messageController.add(item);
          }
        }
      }
    } catch (e) {
      // Ignore parse errors for non-JSON messages
    }
  }

  void _handleError(Object error) {
    _messageController.addError(WebSocketException(
      'WebSocket error',
      originalError: error,
    ));
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    _connectionController.add(ConnectionState.disconnected);

    if (!_intentionalClose && !_disposed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _intentionalClose) return;
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _messageController.addError(WebSocketException(
        'Max reconnect attempts ($maxReconnectAttempts) exceeded',
      ));
      return;
    }

    _cleanup();
    _connectionController.add(ConnectionState.reconnecting);

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
}

/// WebSocket connection state.
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

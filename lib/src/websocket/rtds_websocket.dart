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

  final _cryptoPriceController =
      StreamController<CryptoPriceMessage>.broadcast();
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

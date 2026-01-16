# Core Infrastructure

Base classes for HTTP client, exceptions, and constants.

---

## src/core/constants.dart

```dart
/// Base URLs and constants for Polymarket APIs.
class PolymarketConstants {
  PolymarketConstants._();

  // ============ API Base URLs ============
  
  /// Gamma API - Market discovery and metadata
  static const String gammaBaseUrl = 'https://gamma-api.polymarket.com';
  
  /// CLOB API - Order book and trading
  static const String clobBaseUrl = 'https://clob.polymarket.com';
  
  /// Data API - Positions, trades, activity
  static const String dataBaseUrl = 'https://data-api.polymarket.com';

  // ============ WebSocket URLs ============
  
  /// CLOB WebSocket - Order book updates, user orders
  static const String clobWssUrl = 'wss://ws-subscriptions-clob.polymarket.com/ws/';
  
  /// RTDS WebSocket - Crypto prices, comments
  static const String rtdsWssUrl = 'wss://ws-live-data.polymarket.com';
  
  /// Sports WebSocket - Live game updates
  static const String sportsWssUrl = 'wss://sports-api.polymarket.com/ws';

  // ============ Chain Configuration ============
  
  /// Polygon mainnet chain ID
  static const int polygonChainId = 137;
  
  /// Exchange contract address
  static const String exchangeAddress = '0x4bFb41d5B3570DeFd03C39a9A4D8dE6Bd8B8982E';
  
  /// Neg Risk Exchange contract address
  static const String negRiskExchangeAddress = '0xC5d563A36AE78145C45a50134d48A1215220f80a';

  // ============ API Defaults ============
  
  /// Default timeout for HTTP requests
  static const Duration defaultTimeout = Duration(seconds: 30);
  
  /// Default max retries for failed requests
  static const int defaultMaxRetries = 3;
  
  /// Default page size for paginated requests
  static const int defaultPageSize = 100;
  
  /// Max page size for paginated requests
  static const int maxPageSize = 500;

  // ============ WebSocket Defaults ============
  
  /// Heartbeat interval for WebSocket connections
  static const Duration wsHeartbeatInterval = Duration(seconds: 30);
  
  /// Reconnect delay after disconnect
  static const Duration wsReconnectDelay = Duration(seconds: 5);
  
  /// Max reconnect attempts
  static const int wsMaxReconnectAttempts = 10;

  // ============ Auth Header Names ============
  
  static const String headerPolyAddress = 'POLY_ADDRESS';
  static const String headerPolySignature = 'POLY_SIGNATURE';
  static const String headerPolyTimestamp = 'POLY_TIMESTAMP';
  static const String headerPolyNonce = 'POLY_NONCE';
  static const String headerPolyApiKey = 'POLY_API_KEY';
  static const String headerPolyPassphrase = 'POLY_PASSPHRASE';
}
```

---

## src/core/exceptions.dart

```dart
/// Base exception for all Polymarket API errors.
abstract class PolymarketException implements Exception {
  /// Human-readable error message
  final String message;
  
  /// HTTP status code if applicable
  final int? statusCode;
  
  /// Original error that caused this exception
  final dynamic originalError;
  
  /// Stack trace from original error
  final StackTrace? stackTrace;

  const PolymarketException(
    this.message, {
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message';
}

/// HTTP API errors (4xx, 5xx responses).
class ApiException extends PolymarketException {
  /// The endpoint that was called
  final String? endpoint;
  
  /// Request method (GET, POST, etc.)
  final String? method;
  
  /// Response body if available
  final String? responseBody;

  const ApiException(
    super.message, {
    super.statusCode,
    super.originalError,
    super.stackTrace,
    this.endpoint,
    this.method,
    this.responseBody,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: $message');
    if (statusCode != null) buffer.write(' (status: $statusCode)');
    if (endpoint != null) buffer.write(' [${method ?? 'REQUEST'} $endpoint]');
    return buffer.toString();
  }
}

/// Authentication failures.
class AuthenticationException extends PolymarketException {
  const AuthenticationException(super.message, {super.originalError});
}

/// Invalid API credentials.
class InvalidCredentialsException extends AuthenticationException {
  const InvalidCredentialsException([String? message])
      : super(message ?? 'Invalid API credentials');
}

/// Expired API credentials.
class ExpiredCredentialsException extends AuthenticationException {
  const ExpiredCredentialsException([String? message])
      : super(message ?? 'API credentials have expired');
}

/// Rate limiting (429 responses).
class RateLimitException extends PolymarketException {
  /// Duration to wait before retrying
  final Duration? retryAfter;

  const RateLimitException(
    super.message, {
    super.statusCode = 429,
    this.retryAfter,
  });

  @override
  String toString() {
    final buffer = StringBuffer('RateLimitException: $message');
    if (retryAfter != null) {
      buffer.write(' (retry after ${retryAfter!.inSeconds}s)');
    }
    return buffer.toString();
  }
}

/// Network connectivity issues.
class NetworkException extends PolymarketException {
  /// Whether this might be a transient error worth retrying
  final bool isTransient;

  const NetworkException(
    super.message, {
    super.originalError,
    super.stackTrace,
    this.isTransient = true,
  });
}

/// Request timeout.
class TimeoutException extends NetworkException {
  /// The timeout duration that was exceeded
  final Duration timeout;

  const TimeoutException(
    super.message, {
    required this.timeout,
    super.originalError,
  }) : super(isTransient: true);
}

/// WebSocket connection errors.
class WebSocketException extends PolymarketException {
  /// WebSocket close code if available
  final int? closeCode;
  
  /// WebSocket close reason if available
  final String? closeReason;

  const WebSocketException(
    super.message, {
    super.originalError,
    super.stackTrace,
    this.closeCode,
    this.closeReason,
  });
}

/// WebSocket subscription errors.
class SubscriptionException extends WebSocketException {
  /// The channel that failed
  final String? channel;
  
  /// The assets that failed to subscribe
  final List<String>? assetIds;

  const SubscriptionException(
    super.message, {
    super.originalError,
    this.channel,
    this.assetIds,
  });
}

/// Validation errors for request parameters.
class ValidationException extends PolymarketException {
  /// The field that failed validation
  final String? field;
  
  /// The invalid value
  final dynamic invalidValue;

  const ValidationException(
    super.message, {
    this.field,
    this.invalidValue,
  });
}

/// Resource not found (404).
class NotFoundException extends ApiException {
  /// The resource type that wasn't found
  final String? resourceType;
  
  /// The ID that was searched for
  final String? resourceId;

  const NotFoundException(
    super.message, {
    super.endpoint,
    this.resourceType,
    this.resourceId,
  }) : super(statusCode: 404);
}

/// Server error (5xx).
class ServerException extends ApiException {
  const ServerException(
    super.message, {
    super.statusCode,
    super.endpoint,
    super.responseBody,
  });
}

/// Order-specific errors.
class OrderException extends PolymarketException {
  /// The order ID if available
  final String? orderId;

  const OrderException(
    super.message, {
    super.statusCode,
    this.orderId,
  });
}

/// Insufficient funds for order.
class InsufficientFundsException extends OrderException {
  final double required;
  final double available;

  const InsufficientFundsException({
    required this.required,
    required this.available,
    super.orderId,
  }) : super('Insufficient funds: required $required, available $available');
}
```

---

## src/core/result.dart

```dart
/// A Result type for operations that can fail.
/// 
/// Use this instead of exceptions for expected failure cases.
sealed class Result<T, E> {
  const Result();

  /// Whether this is a success
  bool get isSuccess => this is Success<T, E>;
  
  /// Whether this is a failure
  bool get isFailure => this is Failure<T, E>;

  /// Get the value if success, or null if failure
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  /// Get the error if failure, or null if success
  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };

  /// Map the success value
  Result<U, E> map<U>(U Function(T value) transform) => switch (this) {
    Success(:final value) => Success(transform(value)),
    Failure(:final error) => Failure(error),
  };

  /// Map the failure error
  Result<T, F> mapError<F>(F Function(E error) transform) => switch (this) {
    Success(:final value) => Success(value),
    Failure(:final error) => Failure(transform(error)),
  };

  /// FlatMap the success value
  Result<U, E> flatMap<U>(Result<U, E> Function(T value) transform) => 
      switch (this) {
        Success(:final value) => transform(value),
        Failure(:final error) => Failure(error),
      };

  /// Execute one of two functions based on success/failure
  R fold<R>(
    R Function(T value) onSuccess,
    R Function(E error) onFailure,
  ) => switch (this) {
    Success(:final value) => onSuccess(value),
    Failure(:final error) => onFailure(error),
  };

  /// Get value or throw
  T getOrThrow() => switch (this) {
    Success(:final value) => value,
    Failure(:final error) => throw error as Object,
  };

  /// Get value or default
  T getOrElse(T defaultValue) => switch (this) {
    Success(:final value) => value,
    Failure() => defaultValue,
  };

  /// Get value or compute default
  T getOrElseCompute(T Function(E error) compute) => switch (this) {
    Success(:final value) => value,
    Failure(:final error) => compute(error),
  };
}

/// Successful result containing a value.
final class Success<T, E> extends Result<T, E> {
  final T value;
  
  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Failed result containing an error.
final class Failure<T, E> extends Result<T, E> {
  final E error;
  
  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> && error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Extension for async Result handling
extension ResultFuture<T, E> on Future<Result<T, E>> {
  /// Map success value asynchronously
  Future<Result<U, E>> mapAsync<U>(Future<U> Function(T value) transform) async {
    final result = await this;
    return switch (result) {
      Success(:final value) => Success(await transform(value)),
      Failure(:final error) => Failure(error),
    };
  }
}

/// Helper to create Results
class Results {
  Results._();

  /// Create a success result
  static Result<T, E> success<T, E>(T value) => Success(value);

  /// Create a failure result
  static Result<T, E> failure<T, E>(E error) => Failure(error);

  /// Try an operation and wrap in Result
  static Result<T, Exception> trySync<T>(T Function() operation) {
    try {
      return Success(operation());
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  /// Try an async operation and wrap in Result
  static Future<Result<T, Exception>> tryAsync<T>(
    Future<T> Function() operation,
  ) async {
    try {
      return Success(await operation());
    } on Exception catch (e) {
      return Failure(e);
    }
  }
}
```

---

## src/core/api_client.dart

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'constants.dart';
import 'exceptions.dart';

/// Base HTTP client for API requests.
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final Duration timeout;
  final int maxRetries;
  
  /// Headers to include with every request
  final Map<String, String> _defaultHeaders;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.timeout = PolymarketConstants.defaultTimeout,
    this.maxRetries = PolymarketConstants.defaultMaxRetries,
    Map<String, String>? defaultHeaders,
  })  : _httpClient = httpClient ?? http.Client(),
        _defaultHeaders = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?defaultHeaders,
        };

  /// Make a GET request.
  Future<T> get<T>(
    String path, {
    Map<String, String>? queryParams,
    T Function(dynamic json)? fromJson,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParams);
    final response = await _executeWithRetry(
      () => _httpClient.get(uri, headers: _mergeHeaders(headers)),
      method: 'GET',
      path: path,
    );
    return _parseResponse(response, fromJson);
  }

  /// Make a POST request.
  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJson,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final response = await _executeWithRetry(
      () => _httpClient.post(
        uri,
        headers: _mergeHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      ),
      method: 'POST',
      path: path,
    );
    return _parseResponse(response, fromJson);
  }

  /// Make a DELETE request.
  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJson,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final response = await _executeWithRetry(
      () => _httpClient.delete(
        uri,
        headers: _mergeHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      ),
      method: 'DELETE',
      path: path,
    );
    return _parseResponse(response, fromJson);
  }

  /// Build URI with query parameters.
  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParams == null || queryParams.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams,
    });
  }

  /// Merge headers with defaults.
  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {
      ..._defaultHeaders,
      ...?headers,
    };
  }

  /// Execute request with retry logic.
  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request, {
    required String method,
    required String path,
  }) async {
    int attempts = 0;
    
    while (true) {
      attempts++;
      try {
        final response = await request().timeout(timeout);
        
        // Check for rate limiting
        if (response.statusCode == 429) {
          if (attempts >= maxRetries) {
            throw RateLimitException(
              'Rate limit exceeded after $attempts attempts',
              retryAfter: _parseRetryAfter(response.headers['retry-after']),
            );
          }
          
          final retryAfter = _parseRetryAfter(response.headers['retry-after']) 
              ?? Duration(seconds: attempts * 2);
          await Future.delayed(retryAfter);
          continue;
        }
        
        // Check for server errors (retry on 5xx)
        if (response.statusCode >= 500 && attempts < maxRetries) {
          await Future.delayed(Duration(seconds: attempts));
          continue;
        }
        
        return response;
        
      } on TimeoutException catch (e) {
        if (attempts >= maxRetries) {
          throw TimeoutException(
            'Request timed out after $attempts attempts',
            timeout: timeout,
            originalError: e,
          );
        }
        await Future.delayed(Duration(seconds: attempts));
      } on SocketException catch (e) {
        if (attempts >= maxRetries) {
          throw NetworkException(
            'Network error after $attempts attempts: ${e.message}',
            originalError: e,
          );
        }
        await Future.delayed(Duration(seconds: attempts));
      }
    }
  }

  /// Parse response body.
  T _parseResponse<T>(
    http.Response response,
    T Function(dynamic json)? fromJson,
  ) {
    // Handle error responses
    if (response.statusCode >= 400) {
      _handleErrorResponse(response);
    }
    
    // Parse JSON
    final dynamic json;
    try {
      json = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } on FormatException catch (e) {
      throw ApiException(
        'Invalid JSON response',
        statusCode: response.statusCode,
        responseBody: response.body,
        originalError: e,
      );
    }
    
    // Transform or return raw
    if (fromJson != null) {
      return fromJson(json);
    }
    return json as T;
  }

  /// Handle error responses.
  Never _handleErrorResponse(http.Response response) {
    final message = _extractErrorMessage(response);
    
    switch (response.statusCode) {
      case 400:
        throw ValidationException(message);
      case 401:
        throw AuthenticationException(message);
      case 403:
        throw AuthenticationException('Access denied: $message');
      case 404:
        throw NotFoundException(message);
      case 429:
        throw RateLimitException(
          message,
          retryAfter: _parseRetryAfter(response.headers['retry-after']),
        );
      default:
        if (response.statusCode >= 500) {
          throw ServerException(
            message,
            statusCode: response.statusCode,
            responseBody: response.body,
          );
        }
        throw ApiException(
          message,
          statusCode: response.statusCode,
          responseBody: response.body,
        );
    }
  }

  /// Extract error message from response.
  String _extractErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      if (json is Map) {
        return json['error'] ?? 
               json['message'] ?? 
               json['error_message'] ??
               json['errorMsg'] ??
               'Request failed with status ${response.statusCode}';
      }
    } catch (_) {}
    
    if (response.body.isNotEmpty && response.body.length < 200) {
      return response.body;
    }
    
    return 'Request failed with status ${response.statusCode}';
  }

  /// Parse Retry-After header.
  Duration? _parseRetryAfter(String? value) {
    if (value == null) return null;
    final seconds = int.tryParse(value);
    if (seconds != null) return Duration(seconds: seconds);
    return null;
  }

  /// Close the client.
  void close() {
    _httpClient.close();
  }
}

/// Extension for paginated requests.
extension PaginatedRequests on ApiClient {
  /// Fetch all pages of a paginated endpoint.
  Future<List<T>> getAllPages<T>({
    required String path,
    required T Function(Map<String, dynamic>) itemFromJson,
    String itemsKey = 'data',
    int pageSize = 100,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final allItems = <T>[];
    int offset = 0;
    
    while (true) {
      final response = await get<Map<String, dynamic>>(
        path,
        queryParams: {
          ...?queryParams,
          'limit': pageSize.toString(),
          'offset': offset.toString(),
        },
        headers: headers,
      );
      
      final items = response[itemsKey] as List?;
      if (items == null || items.isEmpty) break;
      
      for (final item in items) {
        allItems.add(itemFromJson(item as Map<String, dynamic>));
      }
      
      if (items.length < pageSize) break;
      offset += pageSize;
    }
    
    return allItems;
  }
}
```

---

## src/core/websocket_client.dart

```dart
import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

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
      throw WebSocketException('WebSocket client has been disposed');
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
      throw WebSocketException('WebSocket not connected');
    }
    _channel!.sink.add(jsonEncode(message));
  }

  /// Send a subscription message.
  void subscribe(List<String> assetIds, {String type = 'market'}) {
    send({
      'type': type,
      'assets_ids': assetIds,
    });
  }

  /// Unsubscribe from assets.
  void unsubscribe(List<String> assetIds) {
    send({
      'type': 'unsubscribe',
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
```

---

## Barrel Export

### src/core/core.dart

```dart
export 'constants.dart';
export 'exceptions.dart';
export 'result.dart';
export 'api_client.dart';
export 'websocket_client.dart';
```

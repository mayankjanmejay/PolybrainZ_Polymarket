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

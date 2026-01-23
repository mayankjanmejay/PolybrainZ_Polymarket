import 'exceptions.dart';

/// Base exception for trading operations.
class TradingException extends PolymarketException {
  /// Error code from the API
  final String? errorCode;

  const TradingException(
    super.message, {
    super.statusCode,
    super.originalError,
    super.stackTrace,
    this.errorCode,
  });

  @override
  String toString() {
    final buffer = StringBuffer('TradingException: $message');
    if (errorCode != null) buffer.write(' (code: $errorCode)');
    if (statusCode != null) buffer.write(' [status: $statusCode]');
    return buffer.toString();
  }
}

/// Order submission failed.
class OrderSubmissionException extends TradingException {
  /// The order ID if available
  final String? orderId;

  const OrderSubmissionException(
    super.message, {
    this.orderId,
    super.statusCode,
    super.errorCode,
  });

  @override
  String toString() {
    final buffer = StringBuffer('OrderSubmissionException: $message');
    if (orderId != null) buffer.write(' (order: $orderId)');
    return buffer.toString();
  }
}

/// Order signing failed.
class SigningException extends TradingException {
  const SigningException(super.message, {super.originalError, super.stackTrace});

  @override
  String toString() => 'SigningException: $message';
}

/// Wallet operation failed.
class WalletException extends TradingException {
  /// Transaction hash if available
  final String? txHash;

  const WalletException(
    super.message, {
    this.txHash,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('WalletException: $message');
    if (txHash != null) buffer.write(' (tx: $txHash)');
    return buffer.toString();
  }
}

/// Insufficient USDC balance for operation.
class InsufficientUsdcException extends TradingException {
  /// Required USDC amount
  final double required;

  /// Available USDC amount
  final double available;

  const InsufficientUsdcException({
    required this.required,
    required this.available,
  }) : super('Insufficient USDC: required $required, available $available');

  /// Shortfall amount
  double get shortfall => required - available;
}

/// Insufficient MATIC for gas fees.
class InsufficientGasException extends TradingException {
  /// Required MATIC amount
  final double required;

  /// Available MATIC amount
  final double available;

  const InsufficientGasException({
    required this.required,
    required this.available,
  }) : super('Insufficient MATIC for gas: required $required, available $available');

  /// Shortfall amount
  double get shortfall => required - available;
}

/// USDC approval not set or insufficient.
class InsufficientAllowanceException extends TradingException {
  /// Required allowance
  final double required;

  /// Current allowance
  final double current;

  /// Spender contract address
  final String spender;

  const InsufficientAllowanceException({
    required this.required,
    required this.current,
    required this.spender,
  }) : super('Insufficient USDC allowance for $spender: required $required, current $current');
}

/// Transaction failed on blockchain.
class TransactionFailedException extends WalletException {
  /// Revert reason if available
  final String? revertReason;

  const TransactionFailedException(
    super.message, {
    super.txHash,
    this.revertReason,
  });

  @override
  String toString() {
    final buffer = StringBuffer('TransactionFailedException: $message');
    if (revertReason != null) buffer.write(' (reason: $revertReason)');
    if (txHash != null) buffer.write(' [tx: $txHash]');
    return buffer.toString();
  }
}

/// Transaction timed out waiting for confirmation.
class TransactionTimeoutException extends WalletException {
  /// Timeout duration
  final Duration timeout;

  TransactionTimeoutException({
    required this.timeout,
    super.txHash,
  }) : super('Transaction confirmation timed out after ${timeout.inSeconds}s');
}

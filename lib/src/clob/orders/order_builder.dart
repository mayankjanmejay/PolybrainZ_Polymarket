import 'dart:math';

import '../../enums/order_side.dart';
import '../../enums/signature_type.dart';
import 'order_struct.dart';

/// Builds order parameters for CLOB submission.
///
/// Provides convenient methods to create orders with user-friendly
/// parameters (price, size) that get converted to the contract format.
class OrderBuilder {
  OrderBuilder._();

  /// Zero address constant
  static const String zeroAddress =
      '0x0000000000000000000000000000000000000000';

  /// USDC decimals
  static const int usdcDecimals = 6;

  /// Share decimals
  static const int shareDecimals = 6;

  /// Build an order struct with raw parameters.
  ///
  /// Use [buildLimitOrder] or [buildMarketOrder] for simpler APIs.
  static OrderStruct buildOrder({
    required String tokenId,
    required String makerAddress,
    required OrderSide side,
    required BigInt makerAmount,
    required BigInt takerAmount,
    int? expiration,
    int? nonce,
    int feeRateBps = 0,
    SignatureType signatureType = SignatureType.eoa,
  }) {
    return OrderStruct(
      salt: _generateSalt(),
      maker: makerAddress,
      signer: makerAddress,
      taker: zeroAddress,
      tokenId: tokenId,
      makerAmount: makerAmount,
      takerAmount: takerAmount,
      expiration: BigInt.from(expiration ?? 0),
      nonce: BigInt.from(nonce ?? DateTime.now().millisecondsSinceEpoch),
      feeRateBps: BigInt.from(feeRateBps),
      side: side == OrderSide.buy ? 0 : 1,
      signatureType: signatureType.value,
    );
  }

  /// Build a limit order with user-friendly parameters.
  ///
  /// [tokenId] - The conditional token ID to trade
  /// [makerAddress] - Your wallet address
  /// [side] - Buy or sell
  /// [size] - Number of shares
  /// [price] - Limit price per share (0.01 - 0.99)
  /// [expiration] - Optional order expiration duration
  /// [signatureType] - Signature type (default: EOA)
  static OrderStruct buildLimitOrder({
    required String tokenId,
    required String makerAddress,
    required OrderSide side,
    required double size,
    required double price,
    Duration? expiration,
    SignatureType signatureType = SignatureType.eoa,
  }) {
    _validatePrice(price);
    _validateSize(size);

    final BigInt makerAmount;
    final BigInt takerAmount;

    if (side == OrderSide.buy) {
      // Buying: maker gives USDC, receives shares
      final usdcAmount = size * price;
      makerAmount = _toUsdcWei(usdcAmount);
      takerAmount = _toShareWei(size);
    } else {
      // Selling: maker gives shares, receives USDC
      final usdcAmount = size * price;
      makerAmount = _toShareWei(size);
      takerAmount = _toUsdcWei(usdcAmount);
    }

    final expirationTimestamp = expiration != null
        ? DateTime.now().add(expiration).millisecondsSinceEpoch ~/ 1000
        : 0;

    return buildOrder(
      tokenId: tokenId,
      makerAddress: makerAddress,
      side: side,
      makerAmount: makerAmount,
      takerAmount: takerAmount,
      expiration: expirationTimestamp,
      signatureType: signatureType,
    );
  }

  /// Build a market order for immediate execution.
  ///
  /// [tokenId] - The conditional token ID to trade
  /// [makerAddress] - Your wallet address
  /// [side] - Buy or sell
  /// [amount] - USDC amount for BUY, shares for SELL
  /// [price] - Expected fill price
  /// [signatureType] - Signature type (default: EOA)
  static OrderStruct buildMarketOrder({
    required String tokenId,
    required String makerAddress,
    required OrderSide side,
    required double amount,
    required double price,
    SignatureType signatureType = SignatureType.eoa,
  }) {
    _validatePrice(price);

    final BigInt makerAmount;
    final BigInt takerAmount;

    if (side == OrderSide.buy) {
      // Buying with USDC amount
      final shares = amount / price;
      makerAmount = _toUsdcWei(amount);
      takerAmount = _toShareWei(shares);
    } else {
      // Selling shares
      final usdcAmount = amount * price;
      makerAmount = _toShareWei(amount);
      takerAmount = _toUsdcWei(usdcAmount);
    }

    return buildOrder(
      tokenId: tokenId,
      makerAddress: makerAddress,
      side: side,
      makerAmount: makerAmount,
      takerAmount: takerAmount,
      signatureType: signatureType,
    );
  }

  /// Calculate the required USDC for a buy order.
  static double calculateUsdcRequired({
    required double size,
    required double price,
  }) {
    return size * price;
  }

  /// Calculate the expected USDC from a sell order.
  static double calculateUsdcExpected({
    required double size,
    required double price,
  }) {
    return size * price;
  }

  /// Validate price is in valid range.
  static void _validatePrice(double price) {
    if (price <= 0 || price >= 1) {
      throw ArgumentError('Price must be between 0 and 1 (exclusive): $price');
    }
  }

  /// Validate size is positive.
  static void _validateSize(double size) {
    if (size <= 0) {
      throw ArgumentError('Size must be positive: $size');
    }
  }

  /// Convert USDC amount to wei (6 decimals).
  static BigInt _toUsdcWei(double amount) {
    return BigInt.from((amount * 1e6).round());
  }

  /// Convert share amount to wei (6 decimals).
  static BigInt _toShareWei(double amount) {
    return BigInt.from((amount * 1e6).round());
  }

  /// Generate a cryptographically secure random salt.
  static BigInt _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return BigInt.parse(
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );
  }
}

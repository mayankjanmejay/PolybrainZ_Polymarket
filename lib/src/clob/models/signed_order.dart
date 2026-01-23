import 'package:equatable/equatable.dart';

import '../../enums/order_side.dart';
import '../orders/order_struct.dart';

/// A signed order ready for CLOB submission.
///
/// Contains the order struct and its EIP-712 signature.
class SignedOrder extends Equatable {
  /// The order data
  final OrderStruct order;

  /// EIP-712 signature (0x-prefixed, 65 bytes)
  final String signature;

  const SignedOrder({
    required this.order,
    required this.signature,
  });

  /// Convert to JSON for API submission.
  Map<String, dynamic> toJson() => {
        'order': order.toJson(),
        'signature': signature,
      };

  /// Get the owner (maker) address.
  String get owner => order.maker;

  /// Get order side.
  OrderSide get side => order.sideEnum;

  /// Get price.
  double get price => order.price;

  /// Get size in shares.
  double get size => order.size;

  /// Get USDC amount.
  double get usdcAmount => order.usdcAmount;

  /// Get token ID.
  String get tokenId => order.tokenId;

  /// Whether order has expiration.
  bool get hasExpiration => order.hasExpiration;

  /// Whether order is expired.
  bool get isExpired => order.isExpired;

  @override
  List<Object?> get props => [order, signature];

  @override
  String toString() =>
      'SignedOrder(${side.name} $size @ $price, sig: ${signature.substring(0, 10)}...)';
}

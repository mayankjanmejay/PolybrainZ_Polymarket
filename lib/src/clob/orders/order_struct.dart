import 'package:equatable/equatable.dart';

import '../../enums/order_side.dart';
import '../../enums/signature_type.dart';

/// Raw order struct matching the CLOB contract.
///
/// This represents the on-chain order structure that gets signed
/// and submitted to the Polymarket CTF Exchange.
class OrderStruct extends Equatable {
  /// Random salt for order uniqueness
  final BigInt salt;

  /// Maker's wallet address
  final String maker;

  /// Signer's wallet address (usually same as maker)
  final String signer;

  /// Taker's address (0x0 for open orders)
  final String taker;

  /// Conditional token ID
  final String tokenId;

  /// Amount maker is providing
  final BigInt makerAmount;

  /// Amount maker wants to receive
  final BigInt takerAmount;

  /// Order expiration timestamp (0 = no expiration)
  final BigInt expiration;

  /// Unique nonce for replay protection
  final BigInt nonce;

  /// Fee rate in basis points
  final BigInt feeRateBps;

  /// Order side (0 = buy, 1 = sell)
  final int side;

  /// Signature type (0 = EOA, 1 = Poly, 2 = PolyProxy)
  final int signatureType;

  const OrderStruct({
    required this.salt,
    required this.maker,
    required this.signer,
    required this.taker,
    required this.tokenId,
    required this.makerAmount,
    required this.takerAmount,
    required this.expiration,
    required this.nonce,
    required this.feeRateBps,
    required this.side,
    required this.signatureType,
  });

  /// Convert to JSON map for signing and API submission.
  Map<String, dynamic> toJson() => {
        'salt': salt.toString(),
        'maker': maker,
        'signer': signer,
        'taker': taker,
        'tokenId': tokenId,
        'makerAmount': makerAmount.toString(),
        'takerAmount': takerAmount.toString(),
        'expiration': expiration.toString(),
        'nonce': nonce.toString(),
        'feeRateBps': feeRateBps.toString(),
        'side': side,
        'signatureType': signatureType,
      };

  /// Convert to map with BigInt values for EIP-712 signing.
  Map<String, dynamic> toTypedDataMessage() => {
        'salt': salt,
        'maker': maker,
        'signer': signer,
        'taker': taker,
        'tokenId': BigInt.parse(tokenId),
        'makerAmount': makerAmount,
        'takerAmount': takerAmount,
        'expiration': expiration,
        'nonce': nonce,
        'feeRateBps': feeRateBps,
        'side': side,
        'signatureType': signatureType,
      };

  /// Calculate implied price.
  ///
  /// For buy orders: price = makerAmount / takerAmount
  /// For sell orders: price = takerAmount / makerAmount
  double get price {
    if (takerAmount == BigInt.zero || makerAmount == BigInt.zero) {
      return 0.0;
    }
    if (side == 0) {
      // Buy: giving USDC (maker), receiving shares (taker)
      return makerAmount.toDouble() / takerAmount.toDouble();
    } else {
      // Sell: giving shares (maker), receiving USDC (taker)
      return takerAmount.toDouble() / makerAmount.toDouble();
    }
  }

  /// Get size in shares (with 6 decimal precision).
  double get size {
    if (side == 0) {
      // Buy: taker amount is shares
      return takerAmount.toDouble() / 1e6;
    } else {
      // Sell: maker amount is shares
      return makerAmount.toDouble() / 1e6;
    }
  }

  /// Get USDC amount (with 6 decimal precision).
  double get usdcAmount {
    if (side == 0) {
      // Buy: maker amount is USDC
      return makerAmount.toDouble() / 1e6;
    } else {
      // Sell: taker amount is USDC
      return takerAmount.toDouble() / 1e6;
    }
  }

  /// Get side as enum.
  OrderSide get sideEnum => side == 0 ? OrderSide.buy : OrderSide.sell;

  /// Get signature type as enum.
  SignatureType get signatureTypeEnum => SignatureType.fromJson(signatureType);

  /// Whether order has an expiration.
  bool get hasExpiration => expiration > BigInt.zero;

  /// Expiration as DateTime (null if no expiration).
  DateTime? get expirationDateTime {
    if (!hasExpiration) return null;
    return DateTime.fromMillisecondsSinceEpoch(expiration.toInt() * 1000);
  }

  /// Whether order is expired.
  bool get isExpired {
    if (!hasExpiration) return false;
    return DateTime.now().isAfter(expirationDateTime!);
  }

  @override
  List<Object?> get props => [salt, maker, tokenId, side, nonce];

  @override
  String toString() =>
      'OrderStruct(${sideEnum.name} $size @ $price, maker: ${maker.substring(0, 10)}...)';
}

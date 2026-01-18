import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'order_summary.dart';

part 'order_book.g.dart';

/// Order book for a token.
@JsonSerializable(fieldRename: FieldRename.snake)
class OrderBook extends Equatable {
  final String market;
  final String assetId;
  final String timestamp;
  final String hash;
  final List<OrderSummary> bids;
  final List<OrderSummary> asks;

  @JsonKey(name: 'min_tick_size')
  final String? minTickSize;

  final String? minOrderSize;

  @JsonKey(defaultValue: false)
  final bool negRisk;

  const OrderBook({
    required this.market,
    required this.assetId,
    required this.timestamp,
    required this.hash,
    required this.bids,
    required this.asks,
    this.minTickSize,
    this.minOrderSize,
    this.negRisk = false,
  });

  factory OrderBook.fromJson(Map<String, dynamic> json) =>
      _$OrderBookFromJson(json);
  Map<String, dynamic> toJson() => _$OrderBookToJson(this);

  /// Best bid price (highest buy order)
  double? get bestBid =>
      bids.isNotEmpty ? double.tryParse(bids.first.price) : null;

  /// Best ask price (lowest sell order)
  double? get bestAsk =>
      asks.isNotEmpty ? double.tryParse(asks.first.price) : null;

  /// Spread between best bid and ask
  double? get spread {
    if (bestBid == null || bestAsk == null) return null;
    return bestAsk! - bestBid!;
  }

  /// Midpoint price
  double? get midpoint {
    if (bestBid == null || bestAsk == null) return null;
    return (bestBid! + bestAsk!) / 2;
  }

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'market': market,
      'assetId': assetId,
      'timestamp': timestamp,
      'hash': hash,
      'bestBid': bestBid,
      'bestAsk': bestAsk,
      'spread': spread,
      'midpoint': midpoint,
      'minTickSize': minTickSize,
      'minOrderSize': minOrderSize,
      'negRisk': negRisk,
      'bids': bids.map((b) => b.toLegacyMap()).toList(),
      'asks': asks.map((a) => a.toLegacyMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [market, assetId, hash];
}

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trade.g.dart';

/// A trade from the CLOB.
@JsonSerializable(fieldRename: FieldRename.snake)
class Trade extends Equatable {
  final String id;
  final String takerOrderId;
  final String market;
  final String assetId;
  final String side;
  final String size;
  final String price;
  final String status;
  final String matchTime;
  final String lastUpdate;
  final String outcome;
  final String? owner;
  final String? tradeOwner;
  final String? type;
  final String? feeRateBps;
  final List<MakerOrder>? makerOrders;
  final String? transactionHash;
  final String? bucketIndex;

  const Trade({
    required this.id,
    required this.takerOrderId,
    required this.market,
    required this.assetId,
    required this.side,
    required this.size,
    required this.price,
    required this.status,
    required this.matchTime,
    required this.lastUpdate,
    required this.outcome,
    this.owner,
    this.tradeOwner,
    this.type,
    this.feeRateBps,
    this.makerOrders,
    this.transactionHash,
    this.bucketIndex,
  });

  factory Trade.fromJson(Map<String, dynamic> json) => _$TradeFromJson(json);
  Map<String, dynamic> toJson() => _$TradeToJson(this);

  double get priceNum => double.tryParse(price) ?? 0.0;
  double get sizeNum => double.tryParse(size) ?? 0.0;

  @override
  List<Object?> get props => [id, market, assetId];
}

/// Maker order in a trade.
@JsonSerializable(fieldRename: FieldRename.snake)
class MakerOrder extends Equatable {
  final String orderId;
  final String assetId;
  final String matchedAmount;
  final String price;
  final String outcome;
  final String owner;

  const MakerOrder({
    required this.orderId,
    required this.assetId,
    required this.matchedAmount,
    required this.price,
    required this.outcome,
    required this.owner,
  });

  factory MakerOrder.fromJson(Map<String, dynamic> json) =>
      _$MakerOrderFromJson(json);
  Map<String, dynamic> toJson() => _$MakerOrderToJson(this);

  @override
  List<Object?> get props => [orderId, assetId];
}

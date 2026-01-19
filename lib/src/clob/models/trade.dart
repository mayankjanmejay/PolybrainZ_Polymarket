import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../enums/order_side.dart';
import '../../enums/trade_status.dart';
import '../../enums/outcome_type.dart';

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
  final String? matchTime;
  final String? lastUpdate;
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
    this.matchTime,
    this.lastUpdate,
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

  /// Parse side to enum
  OrderSide get sideEnum => OrderSide.fromJson(side);

  /// Parse status to enum
  TradeStatus get statusEnum => TradeStatus.fromJson(status);

  /// Parse outcome to enum
  OutcomeType? get outcomeEnum => OutcomeType.tryFromJson(outcome);

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'takerOrderId': takerOrderId,
      'market': market,
      'assetId': assetId,
      'side': side,
      'size': sizeNum,
      'price': priceNum,
      'status': status,
      'matchTime': matchTime,
      'lastUpdate': lastUpdate,
      'outcome': outcome,
      'owner': owner,
      'tradeOwner': tradeOwner,
      'type': type,
      'feeRateBps': feeRateBps,
      'transactionHash': transactionHash,
      'bucketIndex': bucketIndex,
      'makerOrders': makerOrders?.map((m) => m.toLegacyMap()).toList(),
    };
  }

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

  /// Parse outcome to enum
  OutcomeType? get outcomeEnum => OutcomeType.tryFromJson(outcome);

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'orderId': orderId,
      'assetId': assetId,
      'matchedAmount': double.tryParse(matchedAmount) ?? 0.0,
      'price': double.tryParse(price) ?? 0.0,
      'outcome': outcome,
      'owner': owner,
    };
  }

  @override
  List<Object?> get props => [orderId, assetId];
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trade _$TradeFromJson(Map<String, dynamic> json) => Trade(
  id: json['id'] as String,
  takerOrderId: json['taker_order_id'] as String,
  market: json['market'] as String,
  assetId: json['asset_id'] as String,
  side: json['side'] as String,
  size: json['size'] as String,
  price: json['price'] as String,
  status: json['status'] as String,
  matchTime: json['match_time'] as String?,
  lastUpdate: json['last_update'] as String?,
  outcome: json['outcome'] as String,
  owner: json['owner'] as String?,
  tradeOwner: json['trade_owner'] as String?,
  type: json['type'] as String?,
  feeRateBps: json['fee_rate_bps'] as String?,
  makerOrders: (json['maker_orders'] as List<dynamic>?)
      ?.map((e) => MakerOrder.fromJson(e as Map<String, dynamic>))
      .toList(),
  transactionHash: json['transaction_hash'] as String?,
  bucketIndex: json['bucket_index'] as String?,
);

Map<String, dynamic> _$TradeToJson(Trade instance) => <String, dynamic>{
  'id': instance.id,
  'taker_order_id': instance.takerOrderId,
  'market': instance.market,
  'asset_id': instance.assetId,
  'side': instance.side,
  'size': instance.size,
  'price': instance.price,
  'status': instance.status,
  'match_time': instance.matchTime,
  'last_update': instance.lastUpdate,
  'outcome': instance.outcome,
  'owner': instance.owner,
  'trade_owner': instance.tradeOwner,
  'type': instance.type,
  'fee_rate_bps': instance.feeRateBps,
  'maker_orders': instance.makerOrders,
  'transaction_hash': instance.transactionHash,
  'bucket_index': instance.bucketIndex,
};

MakerOrder _$MakerOrderFromJson(Map<String, dynamic> json) => MakerOrder(
  orderId: json['order_id'] as String,
  assetId: json['asset_id'] as String,
  matchedAmount: json['matched_amount'] as String,
  price: json['price'] as String,
  outcome: json['outcome'] as String,
  owner: json['owner'] as String,
);

Map<String, dynamic> _$MakerOrderToJson(MakerOrder instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'asset_id': instance.assetId,
      'matched_amount': instance.matchedAmount,
      'price': instance.price,
      'outcome': instance.outcome,
      'owner': instance.owner,
    };

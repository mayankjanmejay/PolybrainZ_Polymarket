// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderBook _$OrderBookFromJson(Map<String, dynamic> json) => OrderBook(
  market: json['market'] as String,
  assetId: json['asset_id'] as String,
  timestamp: json['timestamp'] as String?,
  hash: json['hash'] as String?,
  bids: (json['bids'] as List<dynamic>)
      .map((e) => OrderSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  asks: (json['asks'] as List<dynamic>)
      .map((e) => OrderSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  minTickSize: json['min_tick_size'] as String?,
  minOrderSize: json['min_order_size'] as String?,
  negRisk: json['neg_risk'] as bool? ?? false,
);

Map<String, dynamic> _$OrderBookToJson(OrderBook instance) => <String, dynamic>{
  'market': instance.market,
  'asset_id': instance.assetId,
  'timestamp': instance.timestamp,
  'hash': instance.hash,
  'bids': instance.bids,
  'asks': instance.asks,
  'min_tick_size': instance.minTickSize,
  'min_order_size': instance.minOrderSize,
  'neg_risk': instance.negRisk,
};

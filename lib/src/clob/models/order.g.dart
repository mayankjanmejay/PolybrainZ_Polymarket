// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['id'] as String,
  market: json['market'] as String,
  assetId: json['asset_id'] as String,
  owner: json['owner'] as String,
  side: json['side'] as String,
  price: json['price'] as String,
  originalSize: json['original_size'] as String,
  sizeMatched: json['size_matched'] as String,
  outcome: json['outcome'] as String,
  expiration: json['expiration'] as String?,
  type: json['type'] as String?,
  timestamp: json['timestamp'] as String?,
  status: json['status'] as String?,
  associatedTrades: (json['associated_trades'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'market': instance.market,
  'asset_id': instance.assetId,
  'owner': instance.owner,
  'side': instance.side,
  'price': instance.price,
  'original_size': instance.originalSize,
  'size_matched': instance.sizeMatched,
  'outcome': instance.outcome,
  'expiration': instance.expiration,
  'type': instance.type,
  'timestamp': instance.timestamp,
  'status': instance.status,
  'associated_trades': instance.associatedTrades,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TradeRecord _$TradeRecordFromJson(Map<String, dynamic> json) => TradeRecord(
  proxyWallet: json['proxy_wallet'] as String,
  conditionId: json['condition_id'] as String,
  asset: json['asset'] as String,
  side: json['side'] as String,
  size: (json['size'] as num).toDouble(),
  price: (json['price'] as num).toDouble(),
  usdcSize: (json['usdc_size'] as num).toDouble(),
  timestamp: (json['timestamp'] as num).toInt(),
  transactionHash: json['transaction_hash'] as String,
  title: json['title'] as String,
  slug: json['slug'] as String,
  icon: json['icon'] as String?,
  eventSlug: json['event_slug'] as String,
  outcome: json['outcome'] as String,
  outcomeIndex: (json['outcome_index'] as num).toInt(),
  name: json['name'] as String?,
  pseudonym: json['pseudonym'] as String?,
  profileImage: json['profile_image'] as String?,
);

Map<String, dynamic> _$TradeRecordToJson(TradeRecord instance) =>
    <String, dynamic>{
      'proxy_wallet': instance.proxyWallet,
      'condition_id': instance.conditionId,
      'asset': instance.asset,
      'side': instance.side,
      'size': instance.size,
      'price': instance.price,
      'usdc_size': instance.usdcSize,
      'timestamp': instance.timestamp,
      'transaction_hash': instance.transactionHash,
      'title': instance.title,
      'slug': instance.slug,
      'icon': instance.icon,
      'event_slug': instance.eventSlug,
      'outcome': instance.outcome,
      'outcome_index': instance.outcomeIndex,
      'name': instance.name,
      'pseudonym': instance.pseudonym,
      'profile_image': instance.profileImage,
    };

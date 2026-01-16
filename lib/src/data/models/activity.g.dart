// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  proxyWallet: json['proxy_wallet'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  conditionId: json['condition_id'] as String,
  type: json['type'] as String,
  size: (json['size'] as num).toDouble(),
  usdcSize: (json['usdc_size'] as num).toDouble(),
  transactionHash: json['transaction_hash'] as String,
  price: (json['price'] as num?)?.toDouble(),
  asset: json['asset'] as String?,
  side: json['side'] as String?,
  outcomeIndex: (json['outcome_index'] as num?)?.toInt(),
  title: json['title'] as String?,
  slug: json['slug'] as String?,
  icon: json['icon'] as String?,
  eventSlug: json['event_slug'] as String?,
  outcome: json['outcome'] as String?,
  name: json['name'] as String?,
  pseudonym: json['pseudonym'] as String?,
  bio: json['bio'] as String?,
  profileImage: json['profile_image'] as String?,
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'proxy_wallet': instance.proxyWallet,
  'timestamp': instance.timestamp,
  'condition_id': instance.conditionId,
  'type': instance.type,
  'size': instance.size,
  'usdc_size': instance.usdcSize,
  'transaction_hash': instance.transactionHash,
  'price': instance.price,
  'asset': instance.asset,
  'side': instance.side,
  'outcome_index': instance.outcomeIndex,
  'title': instance.title,
  'slug': instance.slug,
  'icon': instance.icon,
  'event_slug': instance.eventSlug,
  'outcome': instance.outcome,
  'name': instance.name,
  'pseudonym': instance.pseudonym,
  'bio': instance.bio,
  'profile_image': instance.profileImage,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Market _$MarketFromJson(Map<String, dynamic> json) => Market(
  id: json['id'] as String,
  question: json['question'] as String?,
  conditionId: json['conditionId'] as String,
  slug: json['slug'] as String?,
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  liquidity: json['liquidity'] as String?,
  volume: json['volume'] as String?,
  active: json['active'] as bool? ?? false,
  closed: json['closed'] as bool? ?? false,
  acceptingOrders: json['acceptingOrders'] as bool? ?? false,
  enableOrderBook: json['enableOrderBook'] as bool? ?? false,
  volumeNum: (json['volumeNum'] as num?)?.toDouble(),
  liquidityNum: (json['liquidityNum'] as num?)?.toDouble(),
  outcomes: json['outcomes'] as String?,
  outcomePrices: json['outcomePrices'] as String?,
  marketMakerAddress: json['marketMakerAddress'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  events: (json['events'] as List<dynamic>?)
      ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
      .toList(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
  clobTokenIds: json['clobTokenIds'] as String?,
);

Map<String, dynamic> _$MarketToJson(Market instance) => <String, dynamic>{
  'id': instance.id,
  'question': instance.question,
  'conditionId': instance.conditionId,
  'slug': instance.slug,
  'endDate': instance.endDate?.toIso8601String(),
  'liquidity': instance.liquidity,
  'volume': instance.volume,
  'active': instance.active,
  'closed': instance.closed,
  'acceptingOrders': instance.acceptingOrders,
  'enableOrderBook': instance.enableOrderBook,
  'volumeNum': instance.volumeNum,
  'liquidityNum': instance.liquidityNum,
  'outcomes': instance.outcomes,
  'outcomePrices': instance.outcomePrices,
  'marketMakerAddress': instance.marketMakerAddress,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'events': instance.events,
  'categories': instance.categories,
  'tags': instance.tags,
  'clobTokenIds': instance.clobTokenIds,
};

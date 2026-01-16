// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Market _$MarketFromJson(Map<String, dynamic> json) => Market(
  id: json['id'] as String,
  question: json['question'] as String?,
  conditionId: json['condition_id'] as String,
  slug: json['slug'] as String?,
  endDate: json['end_date'] == null
      ? null
      : DateTime.parse(json['end_date'] as String),
  liquidity: json['liquidity'] as String?,
  volume: json['volume'] as String?,
  active: json['active'] as bool? ?? false,
  closed: json['closed'] as bool? ?? false,
  acceptingOrders: json['accepting_orders'] as bool? ?? false,
  enableOrderBook: json['enable_order_book'] as bool? ?? false,
  volumeNum: (json['volume_num'] as num?)?.toDouble(),
  liquidityNum: (json['liquidity_num'] as num?)?.toDouble(),
  outcomes: json['outcomes'] as String?,
  outcomePrices: json['outcome_prices'] as String?,
  marketMakerAddress: json['market_maker_address'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  events: (json['events'] as List<dynamic>?)
      ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
      .toList(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
  clobTokenIds: json['clob_token_ids'] as String?,
);

Map<String, dynamic> _$MarketToJson(Market instance) => <String, dynamic>{
  'id': instance.id,
  'question': instance.question,
  'condition_id': instance.conditionId,
  'slug': instance.slug,
  'end_date': instance.endDate?.toIso8601String(),
  'liquidity': instance.liquidity,
  'volume': instance.volume,
  'active': instance.active,
  'closed': instance.closed,
  'accepting_orders': instance.acceptingOrders,
  'enable_order_book': instance.enableOrderBook,
  'volume_num': instance.volumeNum,
  'liquidity_num': instance.liquidityNum,
  'outcomes': instance.outcomes,
  'outcome_prices': instance.outcomePrices,
  'market_maker_address': instance.marketMakerAddress,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'events': instance.events,
  'categories': instance.categories,
  'tags': instance.tags,
  'clob_token_ids': instance.clobTokenIds,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clob_market.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClobMarket _$ClobMarketFromJson(Map<String, dynamic> json) => ClobMarket(
  conditionId: json['condition_id'] as String,
  question: json['question'] as String?,
  description: json['description'] as String?,
  marketSlug: json['market_slug'] as String?,
  icon: json['icon'] as String?,
  image: json['image'] as String?,
  active: json['active'] as bool? ?? false,
  closed: json['closed'] as bool? ?? false,
  archived: json['archived'] as bool? ?? false,
  acceptingOrders: json['accepting_orders'] as bool? ?? false,
  enableOrderBook: json['enable_order_book'] as bool? ?? true,
  negRisk: json['neg_risk'] as bool? ?? false,
  negRiskMarketId: json['neg_risk_market_id'] as String?,
  negRiskRequestId: json['neg_risk_request_id'] as String?,
  minimumOrderSize: (json['minimum_order_size'] as num).toDouble(),
  minimumTickSize: (json['minimum_tick_size'] as num).toDouble(),
  makerBaseFee: (json['maker_base_fee'] as num).toDouble(),
  takerBaseFee: (json['taker_base_fee'] as num).toDouble(),
  endDateIso: json['end_date_iso'] as String?,
  gameStartTime: json['game_start_time'] as String?,
  secondsDelay: (json['seconds_delay'] as num?)?.toInt(),
  fpmm: json['fpmm'] as String?,
  is5050Outcome: json['is5050_outcome'] as bool? ?? false,
  notificationsEnabled: json['notifications_enabled'] as bool? ?? false,
  rewards: json['rewards'] == null
      ? null
      : ClobRewards.fromJson(json['rewards'] as Map<String, dynamic>),
  tokens: (json['tokens'] as List<dynamic>)
      .map((e) => ClobToken.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  acceptingOrderTimestamp: json['accepting_order_timestamp'] as String?,
  questionId: json['question_id'] as String?,
);

Map<String, dynamic> _$ClobMarketToJson(ClobMarket instance) =>
    <String, dynamic>{
      'condition_id': instance.conditionId,
      'question': instance.question,
      'description': instance.description,
      'market_slug': instance.marketSlug,
      'icon': instance.icon,
      'image': instance.image,
      'active': instance.active,
      'closed': instance.closed,
      'archived': instance.archived,
      'accepting_orders': instance.acceptingOrders,
      'enable_order_book': instance.enableOrderBook,
      'neg_risk': instance.negRisk,
      'neg_risk_market_id': instance.negRiskMarketId,
      'neg_risk_request_id': instance.negRiskRequestId,
      'minimum_order_size': instance.minimumOrderSize,
      'minimum_tick_size': instance.minimumTickSize,
      'maker_base_fee': instance.makerBaseFee,
      'taker_base_fee': instance.takerBaseFee,
      'end_date_iso': instance.endDateIso,
      'game_start_time': instance.gameStartTime,
      'seconds_delay': instance.secondsDelay,
      'fpmm': instance.fpmm,
      'is5050_outcome': instance.is5050Outcome,
      'notifications_enabled': instance.notificationsEnabled,
      'rewards': instance.rewards,
      'tokens': instance.tokens,
      'tags': instance.tags,
      'accepting_order_timestamp': instance.acceptingOrderTimestamp,
      'question_id': instance.questionId,
    };

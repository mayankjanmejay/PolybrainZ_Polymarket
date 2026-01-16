// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simplified_market.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimplifiedMarket _$SimplifiedMarketFromJson(Map<String, dynamic> json) =>
    SimplifiedMarket(
      conditionId: json['condition_id'] as String,
      acceptingOrders: json['accepting_orders'] as bool? ?? false,
      active: json['active'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
      closed: json['closed'] as bool? ?? false,
      rewards: json['rewards'] == null
          ? null
          : ClobRewards.fromJson(json['rewards'] as Map<String, dynamic>),
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => SimplifiedToken.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SimplifiedMarketToJson(SimplifiedMarket instance) =>
    <String, dynamic>{
      'condition_id': instance.conditionId,
      'accepting_orders': instance.acceptingOrders,
      'active': instance.active,
      'archived': instance.archived,
      'closed': instance.closed,
      'rewards': instance.rewards,
      'tokens': instance.tokens,
    };

SimplifiedToken _$SimplifiedTokenFromJson(Map<String, dynamic> json) =>
    SimplifiedToken(
      outcome: json['outcome'] as String,
      price: (json['price'] as num).toDouble(),
      tokenId: json['token_id'] as String,
    );

Map<String, dynamic> _$SimplifiedTokenToJson(SimplifiedToken instance) =>
    <String, dynamic>{
      'outcome': instance.outcome,
      'price': instance.price,
      'token_id': instance.tokenId,
    };

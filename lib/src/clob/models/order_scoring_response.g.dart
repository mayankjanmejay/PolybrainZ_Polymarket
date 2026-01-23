// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_scoring_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderScoringResponse _$OrderScoringResponseFromJson(
  Map<String, dynamic> json,
) => OrderScoringResponse(
  orderId: json['order_id'] as String,
  isScoring: json['is_scoring'] as bool,
  rewardRate: (json['reward_rate'] as num?)?.toDouble(),
);

Map<String, dynamic> _$OrderScoringResponseToJson(
  OrderScoringResponse instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'is_scoring': instance.isScoring,
  'reward_rate': instance.rewardRate,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clob_rewards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClobRewards _$ClobRewardsFromJson(Map<String, dynamic> json) => ClobRewards(
  maxSpread: (json['max_spread'] as num).toDouble(),
  minSize: (json['min_size'] as num).toDouble(),
  rates: json['rates'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ClobRewardsToJson(ClobRewards instance) =>
    <String, dynamic>{
      'max_spread': instance.maxSpread,
      'min_size': instance.minSize,
      'rates': instance.rates,
    };

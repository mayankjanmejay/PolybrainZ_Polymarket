// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holdings_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HoldingsValue _$HoldingsValueFromJson(Map<String, dynamic> json) =>
    HoldingsValue(
      proxyWallet: json['proxy_wallet'] as String,
      totalValue: (json['total_value'] as num).toDouble(),
      totalPnl: (json['total_pnl'] as num).toDouble(),
      totalPercentPnl: (json['total_percent_pnl'] as num).toDouble(),
    );

Map<String, dynamic> _$HoldingsValueToJson(HoldingsValue instance) =>
    <String, dynamic>{
      'proxy_wallet': instance.proxyWallet,
      'total_value': instance.totalValue,
      'total_pnl': instance.totalPnl,
      'total_percent_pnl': instance.totalPercentPnl,
    };

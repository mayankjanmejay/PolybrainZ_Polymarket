// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Position _$PositionFromJson(Map<String, dynamic> json) => Position(
  proxyWallet: json['proxy_wallet'] as String,
  asset: json['asset'] as String,
  conditionId: json['condition_id'] as String,
  size: (json['size'] as num).toDouble(),
  avgPrice: (json['avg_price'] as num).toDouble(),
  initialValue: (json['initial_value'] as num).toDouble(),
  currentValue: (json['current_value'] as num).toDouble(),
  cashPnl: (json['cash_pnl'] as num).toDouble(),
  percentPnl: (json['percent_pnl'] as num).toDouble(),
  totalBought: (json['total_bought'] as num).toDouble(),
  realizedPnl: (json['realized_pnl'] as num).toDouble(),
  percentRealizedPnl: (json['percent_realized_pnl'] as num).toDouble(),
  curPrice: (json['cur_price'] as num).toDouble(),
  redeemable: json['redeemable'] as bool? ?? false,
  mergeable: json['mergeable'] as bool? ?? false,
  title: json['title'] as String,
  slug: json['slug'] as String,
  icon: json['icon'] as String?,
  eventSlug: json['event_slug'] as String,
  outcome: json['outcome'] as String,
  outcomeIndex: (json['outcome_index'] as num).toInt(),
  oppositeOutcome: json['opposite_outcome'] as String,
  oppositeAsset: json['opposite_asset'] as String,
  endDate: json['end_date'] as String?,
  negativeRisk: json['negative_risk'] as bool? ?? false,
);

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
  'proxy_wallet': instance.proxyWallet,
  'asset': instance.asset,
  'condition_id': instance.conditionId,
  'size': instance.size,
  'avg_price': instance.avgPrice,
  'initial_value': instance.initialValue,
  'current_value': instance.currentValue,
  'cash_pnl': instance.cashPnl,
  'percent_pnl': instance.percentPnl,
  'total_bought': instance.totalBought,
  'realized_pnl': instance.realizedPnl,
  'percent_realized_pnl': instance.percentRealizedPnl,
  'cur_price': instance.curPrice,
  'redeemable': instance.redeemable,
  'mergeable': instance.mergeable,
  'title': instance.title,
  'slug': instance.slug,
  'icon': instance.icon,
  'event_slug': instance.eventSlug,
  'outcome': instance.outcome,
  'outcome_index': instance.outcomeIndex,
  'opposite_outcome': instance.oppositeOutcome,
  'opposite_asset': instance.oppositeAsset,
  'end_date': instance.endDate,
  'negative_risk': instance.negativeRisk,
};

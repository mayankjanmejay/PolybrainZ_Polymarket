// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'closed_position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClosedPosition _$ClosedPositionFromJson(Map<String, dynamic> json) =>
    ClosedPosition(
      proxyWallet: json['proxy_wallet'] as String,
      asset: json['asset'] as String,
      conditionId: json['condition_id'] as String,
      size: (json['size'] as num).toDouble(),
      avgPrice: (json['avg_price'] as num).toDouble(),
      initialValue: (json['initial_value'] as num).toDouble(),
      payout: (json['payout'] as num).toDouble(),
      cashPnl: (json['cash_pnl'] as num).toDouble(),
      percentPnl: (json['percent_pnl'] as num).toDouble(),
      title: json['title'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      eventSlug: json['event_slug'] as String,
      outcome: json['outcome'] as String,
      outcomeIndex: (json['outcome_index'] as num).toInt(),
      won: json['won'] as bool? ?? false,
      resolutionDate: json['resolution_date'] == null
          ? null
          : DateTime.parse(json['resolution_date'] as String),
    );

Map<String, dynamic> _$ClosedPositionToJson(ClosedPosition instance) =>
    <String, dynamic>{
      'proxy_wallet': instance.proxyWallet,
      'asset': instance.asset,
      'condition_id': instance.conditionId,
      'size': instance.size,
      'avg_price': instance.avgPrice,
      'initial_value': instance.initialValue,
      'payout': instance.payout,
      'cash_pnl': instance.cashPnl,
      'percent_pnl': instance.percentPnl,
      'title': instance.title,
      'slug': instance.slug,
      'icon': instance.icon,
      'event_slug': instance.eventSlug,
      'outcome': instance.outcome,
      'outcome_index': instance.outcomeIndex,
      'won': instance.won,
      'resolution_date': instance.resolutionDate?.toIso8601String(),
    };

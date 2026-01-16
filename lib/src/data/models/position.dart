import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'position.g.dart';

/// A user's position in a market.
@JsonSerializable(fieldRename: FieldRename.snake)
class Position extends Equatable {
  final String proxyWallet;
  final String asset;
  final String conditionId;
  final double size;
  final double avgPrice;
  final double initialValue;
  final double currentValue;
  final double cashPnl;
  final double percentPnl;
  final double totalBought;
  final double realizedPnl;
  final double percentRealizedPnl;
  final double curPrice;

  @JsonKey(defaultValue: false)
  final bool redeemable;

  @JsonKey(defaultValue: false)
  final bool mergeable;

  final String title;
  final String slug;
  final String? icon;
  final String eventSlug;
  final String outcome;
  final int outcomeIndex;
  final String oppositeOutcome;
  final String oppositeAsset;
  final String? endDate;

  @JsonKey(defaultValue: false)
  final bool negativeRisk;

  const Position({
    required this.proxyWallet,
    required this.asset,
    required this.conditionId,
    required this.size,
    required this.avgPrice,
    required this.initialValue,
    required this.currentValue,
    required this.cashPnl,
    required this.percentPnl,
    required this.totalBought,
    required this.realizedPnl,
    required this.percentRealizedPnl,
    required this.curPrice,
    this.redeemable = false,
    this.mergeable = false,
    required this.title,
    required this.slug,
    this.icon,
    required this.eventSlug,
    required this.outcome,
    required this.outcomeIndex,
    required this.oppositeOutcome,
    required this.oppositeAsset,
    this.endDate,
    this.negativeRisk = false,
  });

  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);
  Map<String, dynamic> toJson() => _$PositionToJson(this);

  @override
  List<Object?> get props => [proxyWallet, asset, conditionId];
}

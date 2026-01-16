import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'closed_position.g.dart';

/// A resolved/closed position with payout info.
@JsonSerializable(fieldRename: FieldRename.snake)
class ClosedPosition extends Equatable {
  final String proxyWallet;
  final String asset;
  final String conditionId;
  final double size;
  final double avgPrice;
  final double initialValue;
  final double payout;
  final double cashPnl;
  final double percentPnl;
  final String title;
  final String slug;
  final String? icon;
  final String eventSlug;
  final String outcome;
  final int outcomeIndex;

  @JsonKey(defaultValue: false)
  final bool won;

  final DateTime? resolutionDate;

  const ClosedPosition({
    required this.proxyWallet,
    required this.asset,
    required this.conditionId,
    required this.size,
    required this.avgPrice,
    required this.initialValue,
    required this.payout,
    required this.cashPnl,
    required this.percentPnl,
    required this.title,
    required this.slug,
    this.icon,
    required this.eventSlug,
    required this.outcome,
    required this.outcomeIndex,
    this.won = false,
    this.resolutionDate,
  });

  factory ClosedPosition.fromJson(Map<String, dynamic> json) =>
      _$ClosedPositionFromJson(json);
  Map<String, dynamic> toJson() => _$ClosedPositionToJson(this);

  @override
  List<Object?> get props => [proxyWallet, asset, conditionId];
}

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clob_rewards.g.dart';

/// Liquidity reward configuration for a market.
@JsonSerializable(fieldRename: FieldRename.snake)
class ClobRewards extends Equatable {
  final double maxSpread;
  final double minSize;
  final Map<String, dynamic>? rates;

  const ClobRewards({
    required this.maxSpread,
    required this.minSize,
    this.rates,
  });

  factory ClobRewards.fromJson(Map<String, dynamic> json) =>
      _$ClobRewardsFromJson(json);
  Map<String, dynamic> toJson() => _$ClobRewardsToJson(this);

  @override
  List<Object?> get props => [maxSpread, minSize];
}

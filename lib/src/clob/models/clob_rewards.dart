import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clob_rewards.g.dart';

/// Liquidity reward configuration for a market.
@JsonSerializable(fieldRename: FieldRename.snake)
class ClobRewards extends Equatable {
  final double maxSpread;
  final double minSize;

  /// Reward rates - can be a List or Map from the API.
  final dynamic rates;

  const ClobRewards({
    required this.maxSpread,
    required this.minSize,
    this.rates,
  });

  /// Get rates as a List if available.
  List<dynamic>? get ratesList => rates is List ? rates as List<dynamic> : null;

  /// Get rates as a Map if available.
  Map<String, dynamic>? get ratesMap =>
      rates is Map ? rates as Map<String, dynamic> : null;

  factory ClobRewards.fromJson(Map<String, dynamic> json) =>
      _$ClobRewardsFromJson(json);
  Map<String, dynamic> toJson() => _$ClobRewardsToJson(this);

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'maxSpread': maxSpread,
      'minSize': minSize,
      'rates': rates,
    };
  }

  @override
  List<Object?> get props => [maxSpread, minSize];
}

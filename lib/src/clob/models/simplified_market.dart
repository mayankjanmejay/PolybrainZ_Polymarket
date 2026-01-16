import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'clob_rewards.dart';

part 'simplified_market.g.dart';

/// Simplified market data for faster loading.
@JsonSerializable(fieldRename: FieldRename.snake)
class SimplifiedMarket extends Equatable {
  final String conditionId;

  @JsonKey(defaultValue: false)
  final bool acceptingOrders;

  @JsonKey(defaultValue: false)
  final bool active;

  @JsonKey(defaultValue: false)
  final bool archived;

  @JsonKey(defaultValue: false)
  final bool closed;

  final ClobRewards? rewards;
  final List<SimplifiedToken> tokens;

  const SimplifiedMarket({
    required this.conditionId,
    this.acceptingOrders = false,
    this.active = false,
    this.archived = false,
    this.closed = false,
    this.rewards,
    required this.tokens,
  });

  factory SimplifiedMarket.fromJson(Map<String, dynamic> json) =>
      _$SimplifiedMarketFromJson(json);
  Map<String, dynamic> toJson() => _$SimplifiedMarketToJson(this);

  @override
  List<Object?> get props => [conditionId];
}

/// Simplified token data.
@JsonSerializable(fieldRename: FieldRename.snake)
class SimplifiedToken extends Equatable {
  final String outcome;
  final double price;
  final String tokenId;

  const SimplifiedToken({
    required this.outcome,
    required this.price,
    required this.tokenId,
  });

  factory SimplifiedToken.fromJson(Map<String, dynamic> json) =>
      _$SimplifiedTokenFromJson(json);
  Map<String, dynamic> toJson() => _$SimplifiedTokenToJson(this);

  @override
  List<Object?> get props => [tokenId];
}

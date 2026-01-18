import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../enums/outcome_type.dart';

part 'clob_token.g.dart';

/// An outcome token in the CLOB.
@JsonSerializable(fieldRename: FieldRename.snake)
class ClobToken extends Equatable {
  final String outcome;
  final double price;
  final String tokenId;

  @JsonKey(defaultValue: false)
  final bool winner;

  const ClobToken({
    required this.outcome,
    required this.price,
    required this.tokenId,
    this.winner = false,
  });

  factory ClobToken.fromJson(Map<String, dynamic> json) =>
      _$ClobTokenFromJson(json);
  Map<String, dynamic> toJson() => _$ClobTokenToJson(this);

  /// Parse outcome to enum
  OutcomeType? get outcomeEnum => OutcomeType.tryFromJson(outcome);

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'outcome': outcome,
      'price': price,
      'tokenId': tokenId,
      'winner': winner,
    };
  }

  @override
  List<Object?> get props => [tokenId, outcome];
}

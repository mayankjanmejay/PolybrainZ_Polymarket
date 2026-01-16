import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'holdings_value.g.dart';

/// Total value of a user's holdings.
@JsonSerializable(fieldRename: FieldRename.snake)
class HoldingsValue extends Equatable {
  final String proxyWallet;
  final double totalValue;
  final double totalPnl;
  final double totalPercentPnl;

  const HoldingsValue({
    required this.proxyWallet,
    required this.totalValue,
    required this.totalPnl,
    required this.totalPercentPnl,
  });

  factory HoldingsValue.fromJson(Map<String, dynamic> json) =>
      _$HoldingsValueFromJson(json);
  Map<String, dynamic> toJson() => _$HoldingsValueToJson(this);

  @override
  List<Object?> get props => [proxyWallet, totalValue];
}

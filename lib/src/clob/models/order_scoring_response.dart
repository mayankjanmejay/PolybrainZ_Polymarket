import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_scoring_response.g.dart';

/// Response from checking if an order is scoring rewards.
@JsonSerializable(fieldRename: FieldRename.snake)
class OrderScoringResponse extends Equatable {
  /// The order ID
  final String orderId;

  /// Whether the order is currently scoring rewards
  final bool isScoring;

  /// Reward rate if scoring (optional)
  final double? rewardRate;

  const OrderScoringResponse({
    required this.orderId,
    required this.isScoring,
    this.rewardRate,
  });

  factory OrderScoringResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderScoringResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderScoringResponseToJson(this);

  @override
  List<Object?> get props => [orderId, isScoring];

  @override
  String toString() => isScoring
      ? 'OrderScoringResponse(order: $orderId, scoring at ${rewardRate ?? "unknown"} rate)'
      : 'OrderScoringResponse(order: $orderId, not scoring)';
}

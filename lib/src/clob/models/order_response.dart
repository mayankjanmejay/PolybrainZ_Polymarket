import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_response.g.dart';

/// Response from posting an order.
@JsonSerializable(fieldRename: FieldRename.snake)
class OrderResponse extends Equatable {
  final bool success;
  final String? errorMsg;
  final String? orderId;
  final List<String>? transactionHashes;
  final String? status;
  final String? takingAmount;
  final String? makingAmount;

  const OrderResponse({
    required this.success,
    this.errorMsg,
    this.orderId,
    this.transactionHashes,
    this.status,
    this.takingAmount,
    this.makingAmount,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'success': success,
      'errorMsg': errorMsg,
      'orderId': orderId,
      'transactionHashes': transactionHashes,
      'status': status,
      'takingAmount': takingAmount,
      'makingAmount': makingAmount,
    };
  }

  @override
  List<Object?> get props => [success, orderId];
}

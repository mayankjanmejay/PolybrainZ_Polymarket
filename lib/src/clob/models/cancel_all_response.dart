import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cancel_all_response.g.dart';

/// Response from cancelling all orders.
@JsonSerializable(fieldRename: FieldRename.snake)
class CancelAllResponse extends Equatable {
  /// Number of orders successfully cancelled
  @JsonKey(name: 'canceled')
  final int cancelledCount;

  /// Number of orders that failed to cancel
  @JsonKey(name: 'failed')
  final int failedCount;

  /// IDs of successfully cancelled orders
  @JsonKey(name: 'canceledIds', defaultValue: [])
  final List<String> cancelledIds;

  /// Details of failed cancellations
  @JsonKey(defaultValue: [])
  final List<CancelFailure> failures;

  const CancelAllResponse({
    required this.cancelledCount,
    required this.failedCount,
    required this.cancelledIds,
    required this.failures,
  });

  factory CancelAllResponse.fromJson(Map<String, dynamic> json) =>
      _$CancelAllResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CancelAllResponseToJson(this);

  /// Whether all orders were cancelled successfully.
  bool get isFullySuccessful => failedCount == 0;

  /// Whether any orders were cancelled.
  bool get hasAnyCancelled => cancelledCount > 0;

  /// Total number of orders processed.
  int get totalProcessed => cancelledCount + failedCount;

  @override
  List<Object?> get props => [cancelledCount, failedCount, cancelledIds];
}

/// Details of a failed order cancellation.
@JsonSerializable(fieldRename: FieldRename.snake)
class CancelFailure extends Equatable {
  /// ID of the order that failed to cancel
  final String orderId;

  /// Reason for the failure
  final String reason;

  const CancelFailure({
    required this.orderId,
    required this.reason,
  });

  factory CancelFailure.fromJson(Map<String, dynamic> json) =>
      _$CancelFailureFromJson(json);

  Map<String, dynamic> toJson() => _$CancelFailureToJson(this);

  @override
  List<Object?> get props => [orderId, reason];

  @override
  String toString() => 'CancelFailure(order: $orderId, reason: $reason)';
}

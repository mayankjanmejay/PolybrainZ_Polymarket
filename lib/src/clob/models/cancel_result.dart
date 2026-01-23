import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cancel_result.g.dart';

/// Result of a single order cancellation.
@JsonSerializable(fieldRename: FieldRename.snake)
class CancelResult extends Equatable {
  /// ID of the order
  final String orderId;

  /// Whether cancellation was successful
  final bool success;

  /// Error message if cancellation failed
  final String? error;

  const CancelResult({
    required this.orderId,
    required this.success,
    this.error,
  });

  factory CancelResult.fromJson(Map<String, dynamic> json) =>
      _$CancelResultFromJson(json);

  Map<String, dynamic> toJson() => _$CancelResultToJson(this);

  /// Whether this result represents a failure.
  bool get isFailure => !success;

  @override
  List<Object?> get props => [orderId, success];

  @override
  String toString() => success
      ? 'CancelResult(order: $orderId, success)'
      : 'CancelResult(order: $orderId, failed: $error)';
}

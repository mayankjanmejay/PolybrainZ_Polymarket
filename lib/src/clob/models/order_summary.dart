import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_summary.g.dart';

/// A price level in the order book.
@JsonSerializable(fieldRename: FieldRename.snake)
class OrderSummary extends Equatable {
  final String price;
  final String size;

  const OrderSummary({
    required this.price,
    required this.size,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) =>
      _$OrderSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$OrderSummaryToJson(this);

  /// Price as double
  double get priceNum => double.tryParse(price) ?? 0.0;

  /// Size as double
  double get sizeNum => double.tryParse(size) ?? 0.0;

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'price': priceNum,
      'size': sizeNum,
    };
  }

  @override
  List<Object?> get props => [price, size];
}

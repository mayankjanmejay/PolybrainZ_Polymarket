import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../enums/order_side.dart';
import '../../enums/order_type.dart';
import '../../enums/order_status.dart';
import '../../enums/outcome_type.dart';

part 'order.g.dart';

/// An order on the CLOB.
@JsonSerializable(fieldRename: FieldRename.snake)
class Order extends Equatable {
  final String id;
  final String market;
  final String assetId;
  final String owner;
  final String side;
  final String price;
  final String originalSize;
  final String sizeMatched;
  final String outcome;
  final String? expiration;
  final String? type;
  final String? timestamp;
  final String? status;
  final List<String>? associatedTrades;

  const Order({
    required this.id,
    required this.market,
    required this.assetId,
    required this.owner,
    required this.side,
    required this.price,
    required this.originalSize,
    required this.sizeMatched,
    required this.outcome,
    this.expiration,
    this.type,
    this.timestamp,
    this.status,
    this.associatedTrades,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  /// Parse side to enum
  OrderSide get sideEnum => OrderSide.fromJson(side);

  /// Parse type to enum
  OrderType? get typeEnum => type != null ? OrderType.fromJson(type!) : null;

  /// Parse status to enum
  OrderStatus? get statusEnum =>
      status != null ? OrderStatus.tryFromJson(status) : null;

  /// Parse outcome to enum
  OutcomeType? get outcomeEnum => OutcomeType.tryFromJson(outcome);

  /// Remaining size to fill
  double get remainingSize {
    final original = double.tryParse(originalSize) ?? 0.0;
    final matched = double.tryParse(sizeMatched) ?? 0.0;
    return original - matched;
  }

  /// Whether order is fully filled
  bool get isFilled => remainingSize <= 0;

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'market': market,
      'assetId': assetId,
      'owner': owner,
      'side': side,
      'sideEnum': sideEnum.toJson(),
      'price': double.tryParse(price) ?? 0.0,
      'originalSize': double.tryParse(originalSize) ?? 0.0,
      'sizeMatched': double.tryParse(sizeMatched) ?? 0.0,
      'remainingSize': remainingSize,
      'isFilled': isFilled,
      'outcome': outcome,
      'expiration': expiration,
      'type': type,
      'timestamp': timestamp,
      'status': status,
      'associatedTrades': associatedTrades,
    };
  }

  @override
  List<Object?> get props => [id, market, assetId];
}

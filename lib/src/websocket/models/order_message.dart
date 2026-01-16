import '../../enums/ws_event_type.dart';
import '../../enums/order_action_type.dart';
import 'ws_message.dart';

/// User order update notification (user channel).
class OrderWsMessage extends WsMessage {
  final String orderId;
  final OrderActionType action;
  final String side;
  final double price;
  final double originalSize;
  final double sizeMatched;
  final String outcome;
  final String? type;

  const OrderWsMessage({
    required super.assetId,
    required super.market,
    required super.timestamp,
    required this.orderId,
    required this.action,
    required this.side,
    required this.price,
    required this.originalSize,
    required this.sizeMatched,
    required this.outcome,
    this.type,
    required super.raw,
  }) : super(eventType: WsEventType.order);

  factory OrderWsMessage.fromJson(Map<String, dynamic> json) {
    return OrderWsMessage(
      assetId: json['asset_id'] as String?,
      market: json['market'] as String?,
      timestamp: json['timestamp'] as int?,
      orderId: json['id'] as String? ?? '',
      action: OrderActionType.fromJson(json['action'] as String? ?? 'UPDATE'),
      side: json['side'] as String? ?? '',
      price: double.parse(json['price']?.toString() ?? '0'),
      originalSize: double.parse(json['original_size']?.toString() ?? '0'),
      sizeMatched: double.parse(json['size_matched']?.toString() ?? '0'),
      outcome: json['outcome'] as String? ?? '',
      type: json['type'] as String?,
      raw: json,
    );
  }

  double get remainingSize => originalSize - sizeMatched;
  bool get isFilled => remainingSize <= 0;
}

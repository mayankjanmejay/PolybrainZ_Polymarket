import '../../enums/ws_event_type.dart';
import 'ws_message.dart';

/// Last trade price update.
class LastTradePriceMessage extends WsMessage {
  final double price;
  final String side;
  final double size;

  const LastTradePriceMessage({
    required super.assetId,
    required super.market,
    required super.timestamp,
    required this.price,
    required this.side,
    required this.size,
    required super.raw,
  }) : super(eventType: WsEventType.lastTradePrice);

  factory LastTradePriceMessage.fromJson(Map<String, dynamic> json) {
    return LastTradePriceMessage(
      assetId: json['asset_id'] as String?,
      market: json['market'] as String?,
      timestamp: json['timestamp'] as int?,
      price: double.parse(json['price'].toString()),
      side: json['side'] as String? ?? '',
      size: double.parse(json['size']?.toString() ?? '0'),
      raw: json,
    );
  }
}

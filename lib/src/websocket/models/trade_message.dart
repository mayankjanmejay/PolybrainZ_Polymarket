import '../../enums/ws_event_type.dart';
import '../../enums/order_side.dart';
import '../../enums/trade_status.dart';
import '../../enums/outcome_type.dart';
import 'ws_message.dart';

/// User trade notification (user channel).
class TradeWsMessage extends WsMessage {
  final String tradeId;
  final String status;
  final String side;
  final double size;
  final double price;
  final String? transactionHash;
  final String outcome;

  const TradeWsMessage({
    required super.assetId,
    required super.market,
    required super.timestamp,
    required this.tradeId,
    required this.status,
    required this.side,
    required this.size,
    required this.price,
    this.transactionHash,
    required this.outcome,
    required super.raw,
  }) : super(eventType: WsEventType.trade);

  factory TradeWsMessage.fromJson(Map<String, dynamic> json) {
    return TradeWsMessage(
      assetId: json['asset_id'] as String?,
      market: json['market'] as String?,
      timestamp: json['timestamp'] as int?,
      tradeId: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      side: json['side'] as String? ?? '',
      size: double.parse(json['size']?.toString() ?? '0'),
      price: double.parse(json['price']?.toString() ?? '0'),
      transactionHash: json['transaction_hash'] as String?,
      outcome: json['outcome'] as String? ?? '',
      raw: json,
    );
  }

  /// Parse side to enum
  OrderSide get sideEnum => OrderSide.fromJson(side);

  /// Parse status to enum
  TradeStatus get statusEnum => TradeStatus.fromJson(status);

  /// Parse outcome to enum
  OutcomeType? get outcomeEnum => OutcomeType.tryFromJson(outcome);
}

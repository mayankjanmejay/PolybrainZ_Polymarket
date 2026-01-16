import '../../enums/ws_event_type.dart';
import '../../clob/models/order_summary.dart';
import 'ws_message.dart';

/// Order book update message.
class BookMessage extends WsMessage {
  final List<OrderSummary> bids;
  final List<OrderSummary> asks;
  final String hash;

  const BookMessage({
    required super.assetId,
    required super.market,
    required super.timestamp,
    required this.bids,
    required this.asks,
    required this.hash,
    required super.raw,
  }) : super(eventType: WsEventType.book);

  factory BookMessage.fromJson(Map<String, dynamic> json) {
    return BookMessage(
      assetId: json['asset_id'] as String?,
      market: json['market'] as String?,
      timestamp: json['timestamp'] as int?,
      bids: (json['bids'] as List? ?? [])
          .map((b) => OrderSummary.fromJson(b as Map<String, dynamic>))
          .toList(),
      asks: (json['asks'] as List? ?? [])
          .map((a) => OrderSummary.fromJson(a as Map<String, dynamic>))
          .toList(),
      hash: json['hash'] as String? ?? '',
      raw: json,
    );
  }

  double? get bestBid => bids.isNotEmpty ? bids.first.priceNum : null;
  double? get bestAsk => asks.isNotEmpty ? asks.first.priceNum : null;
  double? get spread =>
      (bestBid != null && bestAsk != null) ? bestAsk! - bestBid! : null;

  @override
  List<Object?> get props => [...super.props, hash];
}

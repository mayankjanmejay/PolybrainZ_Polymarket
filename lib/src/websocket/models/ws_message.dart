import 'package:equatable/equatable.dart';
import '../../enums/ws_event_type.dart';

/// Base WebSocket message.
class WsMessage extends Equatable {
  final WsEventType eventType;
  final String? assetId;
  final String? market;
  final int? timestamp;
  final Map<String, dynamic> raw;

  const WsMessage({
    required this.eventType,
    this.assetId,
    this.market,
    this.timestamp,
    required this.raw,
  });

  factory WsMessage.fromJson(Map<String, dynamic> json) {
    return WsMessage(
      eventType: WsEventType.fromJson(json['event_type'] as String),
      assetId: json['asset_id'] as String?,
      market: json['market'] as String?,
      timestamp: json['timestamp'] as int?,
      raw: json,
    );
  }

  @override
  List<Object?> get props => [eventType, assetId, market, timestamp];
}

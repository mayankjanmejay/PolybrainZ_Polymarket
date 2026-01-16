import 'package:equatable/equatable.dart';
import '../../enums/ws_event_type.dart';
import 'ws_message.dart';

/// Price change notification.
class PriceChangeMessage extends WsMessage {
  final List<PriceChange> priceChanges;

  const PriceChangeMessage({
    required super.assetId,
    required super.market,
    required super.timestamp,
    required this.priceChanges,
    required super.raw,
  }) : super(eventType: WsEventType.priceChange);

  factory PriceChangeMessage.fromJson(Map<String, dynamic> json) {
    return PriceChangeMessage(
      assetId: json['asset_id'] as String?,
      market: json['market'] as String?,
      timestamp: json['timestamp'] as int?,
      priceChanges: (json['price_changes'] as List? ?? [])
          .map((p) => PriceChange.fromJson(p as Map<String, dynamic>))
          .toList(),
      raw: json,
    );
  }

  /// Get price for a specific token
  double? getPriceForToken(String tokenId) {
    try {
      return priceChanges.firstWhere((p) => p.assetId == tokenId).price;
    } catch (_) {
      return null;
    }
  }
}

/// Individual price change.
class PriceChange extends Equatable {
  final String assetId;
  final double price;

  const PriceChange({
    required this.assetId,
    required this.price,
  });

  factory PriceChange.fromJson(Map<String, dynamic> json) {
    return PriceChange(
      assetId: json['asset_id'] as String,
      price: double.parse(json['price'].toString()),
    );
  }

  @override
  List<Object?> get props => [assetId, price];
}

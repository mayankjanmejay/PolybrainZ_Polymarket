import 'package:json_annotation/json_annotation.dart';

/// Enum for WebSocket subscription types.
@JsonEnum(alwaysCreate: true)
enum WsSubscriptionType {
  /// Subscribe to market data (order book, prices)
  @JsonValue('market')
  market('market'),

  /// Subscribe to user-specific data (orders, trades)
  @JsonValue('user')
  user('user'),

  /// Unsubscribe from assets
  @JsonValue('unsubscribe')
  unsubscribe('unsubscribe');

  final String value;
  const WsSubscriptionType(this.value);

  /// Convert to JSON string value
  String toJson() => value;

  /// Parse from JSON string
  static WsSubscriptionType fromJson(String json) {
    return WsSubscriptionType.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown WsSubscriptionType: $json'),
    );
  }

  /// Try to parse from JSON string, returns null if invalid
  static WsSubscriptionType? tryFromJson(String? json) {
    if (json == null) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

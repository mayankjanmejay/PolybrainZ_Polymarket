import 'package:json_annotation/json_annotation.dart';

/// Type-safe enum for UMA (Universal Market Access) resolution statuses.
///
/// UMA is the oracle system used by Polymarket for market resolution.
///
/// Use with [MarketsEndpoint.listMarkets()] to filter by resolution status.
///
/// ```dart
/// final markets = await client.gamma.markets.listMarkets(
///   umaResolutionStatus: UmaResolutionStatus.resolved,
/// );
/// ```
@JsonEnum(valueField: 'value')
enum UmaResolutionStatus {
  /// Resolution has not started
  pending('pending'),

  /// A resolution has been proposed
  proposed('proposed'),

  /// The proposed resolution is being disputed
  disputed('disputed'),

  /// Market has been resolved
  resolved('resolved');

  final String value;
  const UmaResolutionStatus(this.value);

  /// Whether the resolution is in a terminal state
  bool get isTerminal => this == resolved;

  /// Whether the resolution is still in progress
  bool get isInProgress => this == proposed || this == disputed;

  /// Whether resolution has started
  bool get hasStarted => this != pending;

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static UmaResolutionStatus fromJson(String json) {
    return UmaResolutionStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown UmaResolutionStatus: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static UmaResolutionStatus? tryFromJson(String? json) {
    if (json == null) return null;
    return UmaResolutionStatus.values.cast<UmaResolutionStatus?>().firstWhere(
          (e) => e?.value.toLowerCase() == json.toLowerCase(),
          orElse: () => null,
        );
  }
}

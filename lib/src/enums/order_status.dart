/// Status of an order on the CLOB.
enum OrderStatus {
  /// Order is live and accepting matches
  live('LIVE'),

  /// Order has been partially filled
  matched('MATCHED'),

  /// Order has been fully filled
  filled('FILLED'),

  /// Order was cancelled by user
  cancelled('CANCELLED'),

  /// Order is pending submission
  pending('PENDING'),

  /// Order was delayed (e.g., for neg risk)
  delayed('DELAYED');

  const OrderStatus(this.value);
  final String value;

  String toJson() => value;

  static OrderStatus fromJson(String json) {
    final normalized = json.toUpperCase().trim();
    return OrderStatus.values.firstWhere(
      (e) => e.value == normalized || e.name.toUpperCase() == normalized,
      orElse: () => throw ArgumentError('Invalid OrderStatus: $json'),
    );
  }

  /// Try to parse, returns null if invalid
  static OrderStatus? tryFromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Whether the order is still active/open
  bool get isActive => this == live || this == matched || this == pending;

  /// Whether the order is in a terminal state
  bool get isTerminal => this == filled || this == cancelled;

  /// Whether the order can be cancelled
  bool get isCancellable => this == live || this == matched;
}

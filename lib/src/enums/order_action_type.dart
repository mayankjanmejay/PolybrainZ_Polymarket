/// Type of order action/update in WebSocket messages.
enum OrderActionType {
  placement('PLACEMENT'),
  update('UPDATE'),
  cancellation('CANCELLATION');

  const OrderActionType(this.value);
  final String value;

  String toJson() => value;

  static OrderActionType fromJson(String json) {
    return OrderActionType.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => update, // Default to update if unknown
    );
  }
}

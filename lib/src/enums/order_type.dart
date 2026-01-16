/// Type of order time-in-force.
enum OrderType {
  /// Good Till Cancelled - stays open until filled or cancelled
  gtc('GTC'),

  /// Good Till Date - expires at specified time
  gtd('GTD'),

  /// Fill Or Kill - must fill entirely immediately or cancel
  fok('FOK'),

  /// Fill And Kill - fill as much as possible immediately, cancel rest
  fak('FAK');

  const OrderType(this.value);
  final String value;

  String toJson() => value;

  static OrderType fromJson(String json) {
    return OrderType.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Invalid OrderType: $json'),
    );
  }
}

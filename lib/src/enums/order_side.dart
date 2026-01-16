/// Side of an order (buy or sell).
enum OrderSide {
  buy('BUY'),
  sell('SELL');

  const OrderSide(this.value);
  final String value;

  String toJson() => value;

  static OrderSide fromJson(String json) {
    return OrderSide.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Invalid OrderSide: $json'),
    );
  }

  /// Returns the opposite side
  OrderSide get opposite => this == buy ? sell : buy;
}

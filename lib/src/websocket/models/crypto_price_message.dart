import 'package:equatable/equatable.dart';

/// Crypto price update from RTDS.
class CryptoPriceMessage extends Equatable {
  final String topic;
  final Map<String, double> prices;
  final int? timestamp;

  const CryptoPriceMessage({
    required this.topic,
    required this.prices,
    this.timestamp,
  });

  factory CryptoPriceMessage.fromJson(Map<String, dynamic> json) {
    final pricesData = json['data'] as Map<String, dynamic>? ?? {};
    final prices = <String, double>{};

    pricesData.forEach((key, value) {
      if (value is Map && value['price'] != null) {
        prices[key] = double.parse(value['price'].toString());
      } else if (value is num) {
        prices[key] = value.toDouble();
      }
    });

    return CryptoPriceMessage(
      topic: json['topic'] as String? ?? '',
      prices: prices,
      timestamp: json['timestamp'] as int?,
    );
  }

  double? getPrice(String symbol) => prices[symbol.toUpperCase()];

  @override
  List<Object?> get props => [topic, prices, timestamp];
}

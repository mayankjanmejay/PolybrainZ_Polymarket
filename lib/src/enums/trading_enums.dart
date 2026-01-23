/// Order tick size (price precision).
enum TickSize {
  /// 0.01 (1 cent) tick size - standard markets
  point01('0.01'),

  /// 0.001 (0.1 cent) tick size - high precision markets
  point001('0.001'),

  /// 0.0001 tick size - ultra high precision
  point0001('0.0001');

  const TickSize(this.value);
  final String value;

  /// Get tick size as double
  double get asDouble => double.parse(value);

  String toJson() => value;

  static TickSize fromJson(String json) {
    return TickSize.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Invalid TickSize: $json'),
    );
  }

  /// Try to parse tick size, returns null on failure
  static TickSize? tryFromJson(String? json) {
    if (json == null) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

/// Negative risk flag indicating market type.
enum NegRiskFlag {
  /// Standard market (non-negative risk)
  standard(false),

  /// Negative risk market
  negRisk(true);

  const NegRiskFlag(this.value);
  final bool value;

  bool toJson() => value;

  static NegRiskFlag fromJson(bool json) {
    return json ? NegRiskFlag.negRisk : NegRiskFlag.standard;
  }

  /// Get the appropriate exchange address for this risk type
  String get exchangeAddress {
    return value
        ? '0xC5d563A36AE78145C45a50134d48A1215220f80a' // negRiskExchangeAddress
        : '0x4bFb41d5B3570DeFd03C39a9A4D8dE6Bd8B8982E'; // exchangeAddress
  }
}

/// Order time in force strategy.
enum TimeInForce {
  /// Good Till Cancelled - stays open until filled or cancelled
  gtc('GTC'),

  /// Good Till Date - expires at specified time
  gtd('GTD'),

  /// Fill Or Kill - must fill entirely immediately or cancel
  fok('FOK'),

  /// Immediate Or Cancel - fill as much as possible immediately, cancel rest
  ioc('IOC');

  const TimeInForce(this.value);
  final String value;

  String toJson() => value;

  static TimeInForce fromJson(String json) {
    return TimeInForce.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Invalid TimeInForce: $json'),
    );
  }

  /// Whether this order type requires immediate execution
  bool get isImmediate => this == fok || this == ioc;
}

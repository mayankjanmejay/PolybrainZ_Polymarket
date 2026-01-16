/// Type of on-chain activity.
enum ActivityType {
  trade('TRADE'),
  split('SPLIT'),
  merge('MERGE'),
  redeem('REDEEM'),
  deposit('DEPOSIT'),
  withdraw('WITHDRAW');

  const ActivityType(this.value);
  final String value;

  String toJson() => value;

  static ActivityType fromJson(String json) {
    return ActivityType.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Invalid ActivityType: $json'),
    );
  }
}

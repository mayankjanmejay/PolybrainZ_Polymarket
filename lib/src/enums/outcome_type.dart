/// Outcome type for market positions (Yes/No binary outcomes).
enum OutcomeType {
  /// Yes outcome
  yes('Yes'),

  /// No outcome
  no('No');

  const OutcomeType(this.value);
  final String value;

  String toJson() => value;

  static OutcomeType fromJson(String json) {
    final normalized = json.toLowerCase().trim();
    return OutcomeType.values.firstWhere(
      (e) => e.value.toLowerCase() == normalized || e.name == normalized,
      orElse: () => throw ArgumentError('Invalid OutcomeType: $json'),
    );
  }

  /// Try to parse, returns null if invalid
  static OutcomeType? tryFromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Returns the opposite outcome
  OutcomeType get opposite => this == yes ? no : yes;

  /// Whether this is the Yes outcome
  bool get isYes => this == yes;

  /// Whether this is the No outcome
  bool get isNo => this == no;
}

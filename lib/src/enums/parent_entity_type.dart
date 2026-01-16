/// Type of parent entity for comments.
enum ParentEntityType {
  event('Event'),
  series('Series'),
  market('market');

  const ParentEntityType(this.value);
  final String value;

  String toJson() => value;

  static ParentEntityType fromJson(String json) {
    return ParentEntityType.values.firstWhere(
      (e) => e.value.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid ParentEntityType: $json'),
    );
  }
}

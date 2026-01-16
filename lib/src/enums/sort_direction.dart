/// Sort direction.
enum SortDirection {
  asc('ASC'),
  desc('DESC');

  const SortDirection(this.value);
  final String value;

  String toJson() => value;

  static SortDirection fromJson(String json) {
    return SortDirection.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => desc, // Default to descending
    );
  }
}

/// Type-safe enum for series layout types.
///
/// ```dart
/// final series = await client.gamma.series.listSeries();
/// final layout = series.first.layoutEnum;
/// ```
enum SeriesLayout {
  /// Grid layout
  grid('grid'),

  /// List layout
  list('list'),

  /// Carousel/slider layout
  carousel('carousel'),

  /// Featured/highlight layout
  featured('featured'),

  /// Bracket/tournament layout
  bracket('bracket'),

  /// Timeline layout
  timeline('timeline'),

  /// Card layout
  card('card'),

  /// Compact layout
  compact('compact');

  final String value;
  const SeriesLayout(this.value);

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static SeriesLayout fromJson(String json) {
    return SeriesLayout.values.firstWhere(
      (e) =>
          e.value.toLowerCase() == json.toLowerCase() ||
          e.name.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown SeriesLayout: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static SeriesLayout? tryFromJson(String? json) {
    if (json == null) return null;
    return SeriesLayout.values.cast<SeriesLayout?>().firstWhere(
          (e) =>
              e?.value.toLowerCase() == json.toLowerCase() ||
              e?.name.toLowerCase() == json.toLowerCase(),
          orElse: () => null,
        );
  }
}

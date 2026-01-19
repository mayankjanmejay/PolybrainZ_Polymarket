/// Type-safe enum for series types.
///
/// ```dart
/// final series = await client.gamma.series.listSeries();
/// final type = series.first.seriesTypeEnum;
/// ```
enum SeriesType {
  /// Recurring event series
  recurring('recurring'),

  /// Championship/tournament series
  championship('championship'),

  /// Tournament bracket
  tournament('tournament'),

  /// Generic event series
  eventSeries('event_series'),

  /// Season-long series
  season('season'),

  /// Weekly series
  weekly('weekly'),

  /// Daily series
  daily('daily'),

  /// Special event series
  special('special');

  final String value;
  const SeriesType(this.value);

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static SeriesType fromJson(String json) {
    return SeriesType.values.firstWhere(
      (e) =>
          e.value.toLowerCase() == json.toLowerCase() ||
          e.name.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown SeriesType: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static SeriesType? tryFromJson(String? json) {
    if (json == null) return null;
    return SeriesType.values.cast<SeriesType?>().firstWhere(
          (e) =>
              e?.value.toLowerCase() == json.toLowerCase() ||
              e?.name.toLowerCase() == json.toLowerCase(),
          orElse: () => null,
        );
  }
}

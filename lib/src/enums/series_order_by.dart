import 'package:json_annotation/json_annotation.dart';

/// Type-safe enum for ordering series in list queries.
///
/// Use with [SeriesEndpoint.listSeries()] to specify sort order.
///
/// ```dart
/// final series = await client.gamma.series.listSeries(
///   order: SeriesOrderBy.volume,
///   ascending: false,
/// );
/// ```
@JsonEnum(valueField: 'value')
enum SeriesOrderBy {
  /// Order by total volume traded
  volume('volume'),

  /// Order by start date
  startDate('startDate'),

  /// Order by end date
  endDate('endDate'),

  /// Order by creation date
  createdAt('createdAt'),

  /// Order by liquidity
  liquidity('liquidity');

  final String value;
  const SeriesOrderBy(this.value);

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static SeriesOrderBy fromJson(String json) {
    return SeriesOrderBy.values.firstWhere(
      (e) => e.value.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown SeriesOrderBy: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static SeriesOrderBy? tryFromJson(String? json) {
    if (json == null) return null;
    return SeriesOrderBy.values.cast<SeriesOrderBy?>().firstWhere(
          (e) => e?.value.toLowerCase() == json.toLowerCase(),
          orElse: () => null,
        );
  }
}

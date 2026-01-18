import 'package:json_annotation/json_annotation.dart';

/// Type-safe enum for ordering comments in list queries.
///
/// Use with [CommentsEndpoint.listComments()] to specify sort order.
///
/// ```dart
/// final comments = await client.gamma.comments.listComments(
///   order: CommentOrderBy.createdAt,
///   ascending: false,
/// );
/// ```
@JsonEnum(valueField: 'value')
enum CommentOrderBy {
  /// Order by creation date
  createdAt('createdAt'),

  /// Order by number of likes
  likes('likes'),

  /// Order by number of replies
  replies('replies'),

  /// Order by update date
  updatedAt('updatedAt');

  final String value;
  const CommentOrderBy(this.value);

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static CommentOrderBy fromJson(String json) {
    return CommentOrderBy.values.firstWhere(
      (e) => e.value.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown CommentOrderBy: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static CommentOrderBy? tryFromJson(String? json) {
    if (json == null) return null;
    return CommentOrderBy.values.cast<CommentOrderBy?>().firstWhere(
          (e) => e?.value.toLowerCase() == json.toLowerCase(),
          orElse: () => null,
        );
  }
}

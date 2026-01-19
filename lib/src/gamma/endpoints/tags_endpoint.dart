import '../../core/api_client.dart';
import '../../enums/tag_order_by.dart';
import '../../enums/tag_slug.dart';
import '../models/tag.dart';

/// Endpoints for tags.
class TagsEndpoint {
  final ApiClient _client;

  TagsEndpoint(this._client);

  /// List all tags.
  ///
  /// [order] - Field to order by (volume, eventsCount, createdAt, label)
  /// [ascending] - Sort direction (true = ascending, false = descending)
  Future<List<Tag>> listTags({
    int limit = 100,
    int offset = 0,
    TagOrderBy? order,
    bool? ascending,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (order != null) params['order'] = order.value;
    if (ascending != null) params['ascending'] = ascending.toString();

    final response = await _client.get<List<dynamic>>(
      '/tags',
      queryParams: params,
    );

    return response.map((t) => Tag.fromJson(t as Map<String, dynamic>)).toList();
  }

  /// Get tag by ID.
  Future<Tag> getById(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/tags/$id',
    );
    return Tag.fromJson(response);
  }

  /// Get tag by slug.
  ///
  /// [slug] - The tag slug to retrieve (use [TagSlug] presets or custom)
  ///
  /// ```dart
  /// // Using preset
  /// final tag = await client.gamma.tags.getBySlug(TagSlug.politics);
  ///
  /// // Using custom
  /// final tag = await client.gamma.tags.getBySlug(TagSlug.custom('my-tag'));
  /// ```
  Future<Tag> getBySlug(TagSlug slug) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/tags/slug/${slug.value}',
    );
    return Tag.fromJson(response);
  }

  /// Get related tags for a tag.
  Future<List<Tag>> getRelatedTags(int tagId) async {
    final response = await _client.get<List<dynamic>>(
      '/tags/$tagId/related',
    );
    return response.map((t) => Tag.fromJson(t as Map<String, dynamic>)).toList();
  }
}

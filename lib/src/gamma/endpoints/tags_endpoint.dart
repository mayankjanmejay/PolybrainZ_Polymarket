import '../../core/api_client.dart';
import '../models/tag.dart';

/// Endpoints for tags.
class TagsEndpoint {
  final ApiClient _client;

  TagsEndpoint(this._client);

  /// List all tags.
  Future<List<Tag>> listTags({
    int limit = 100,
    int offset = 0,
    String? order,
    bool? ascending,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (order != null) params['order'] = order;
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
  Future<Tag> getBySlug(String slug) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/tags/slug/$slug',
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

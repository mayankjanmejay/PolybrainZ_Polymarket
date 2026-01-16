import '../../core/api_client.dart';
import '../../enums/parent_entity_type.dart';
import '../models/comment.dart';

/// Endpoints for comments.
class CommentsEndpoint {
  final ApiClient _client;

  CommentsEndpoint(this._client);

  /// List comments with filters.
  Future<List<Comment>> listComments({
    int limit = 100,
    int offset = 0,
    String? order,
    bool? ascending,
    ParentEntityType? parentEntityType,
    int? parentEntityId,
    bool? getPositions,
    bool? holdersOnly,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (order != null) params['order'] = order;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (parentEntityType != null) {
      params['parent_entity_type'] = parentEntityType.toJson();
    }
    if (parentEntityId != null) {
      params['parent_entity_id'] = parentEntityId.toString();
    }
    if (getPositions != null) params['get_positions'] = getPositions.toString();
    if (holdersOnly != null) params['holders_only'] = holdersOnly.toString();

    final response = await _client.get<List<dynamic>>(
      '/comments',
      queryParams: params,
    );

    return response
        .map((c) => Comment.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  /// Get comment by ID.
  Future<Comment> getById(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/comments/$id',
    );
    return Comment.fromJson(response);
  }

  /// Get comments by user address.
  Future<List<Comment>> getByUserAddress(String address) async {
    final response = await _client.get<List<dynamic>>(
      '/comments/user/$address',
    );
    return response
        .map((c) => Comment.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}

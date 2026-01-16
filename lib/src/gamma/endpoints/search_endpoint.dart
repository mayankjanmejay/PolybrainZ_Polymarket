import '../../core/api_client.dart';
import '../models/search_result.dart';

/// Endpoints for search.
class SearchEndpoint {
  final ApiClient _client;

  SearchEndpoint(this._client);

  /// Search events, tags, and profiles.
  Future<SearchResult> search({
    required String query,
    bool? cache,
    String? eventsStatus,
    int? limitPerType,
    int? page,
    List<String>? eventsTags,
    int? keepClosedMarkets,
    String? sort,
    bool? ascending,
    bool? searchTags,
    bool? searchProfiles,
    String? recurrence,
    List<int>? excludeTagIds,
    bool? optimized,
  }) async {
    final params = <String, String>{
      'query': query,
    };

    if (cache != null) params['cache'] = cache.toString();
    if (eventsStatus != null) params['events_status'] = eventsStatus;
    if (limitPerType != null) {
      params['limit_per_type'] = limitPerType.toString();
    }
    if (page != null) params['page'] = page.toString();
    if (eventsTags != null) params['events_tags'] = eventsTags.join(',');
    if (keepClosedMarkets != null) {
      params['keep_closed_markets'] = keepClosedMarkets.toString();
    }
    if (sort != null) params['sort'] = sort;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (searchTags != null) params['search_tags'] = searchTags.toString();
    if (searchProfiles != null) {
      params['search_profiles'] = searchProfiles.toString();
    }
    if (recurrence != null) params['recurrence'] = recurrence;
    if (excludeTagIds != null) {
      params['exclude_tag_ids'] = excludeTagIds.join(',');
    }
    if (optimized != null) params['optimized'] = optimized.toString();

    final response = await _client.get<Map<String, dynamic>>(
      '/search',
      queryParams: params,
    );

    return SearchResult.fromJson(response);
  }
}

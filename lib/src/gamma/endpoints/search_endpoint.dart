import '../../core/api_client.dart';
import '../../enums/events_status.dart';
import '../../enums/recurrence_type.dart';
import '../../enums/search_query.dart';
import '../../enums/search_sort.dart';
import '../../enums/tag_slug.dart';
import '../models/search_result.dart';

/// Endpoints for search.
class SearchEndpoint {
  final ApiClient _client;

  SearchEndpoint(this._client);

  /// Search events, tags, and profiles.
  ///
  /// [query] - Search query (use presets like `SearchQuery.bitcoin` or custom `SearchQuery.custom('my search')`)
  /// [eventsStatus] - Filter events by status (active, closed, all)
  /// [sort] - Sort results by (relevance, volume, liquidity, startDate, endDate, createdAt)
  ///
  /// Example:
  /// ```dart
  /// // Using preset queries
  /// final results = await search(query: SearchQuery.bitcoin);
  /// final results = await search(query: SearchQuery.election);
  ///
  /// // Using custom query
  /// final results = await search(query: SearchQuery.custom('my custom search'));
  /// ```
  Future<SearchResult> search({
    required SearchQuery query,
    bool? cache,
    EventsStatus? eventsStatus,
    int? limitPerType,
    int? page,
    List<TagSlug>? eventsTags,
    int? keepClosedMarkets,
    SearchSort? sort,
    bool? ascending,
    bool? searchTags,
    bool? searchProfiles,
    RecurrenceType? recurrence,
    List<int>? excludeTagIds,
    bool? optimized,
  }) async {
    final params = <String, String>{
      'query': query.value,
    };

    if (cache != null) params['cache'] = cache.toString();
    if (eventsStatus != null) params['events_status'] = eventsStatus.value;
    if (limitPerType != null) {
      params['limit_per_type'] = limitPerType.toString();
    }
    if (page != null) params['page'] = page.toString();
    if (eventsTags != null) {
      params['events_tags'] = eventsTags.map((t) => t.value).join(',');
    }
    if (keepClosedMarkets != null) {
      params['keep_closed_markets'] = keepClosedMarkets.toString();
    }
    if (sort != null) params['sort'] = sort.value;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (searchTags != null) params['search_tags'] = searchTags.toString();
    if (searchProfiles != null) {
      params['search_profiles'] = searchProfiles.toString();
    }
    if (recurrence != null) params['recurrence'] = recurrence.value;
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

  // ============================================
  // Convenience methods for common searches
  // ============================================

  /// Search for Bitcoin-related markets
  Future<SearchResult> searchBitcoin({
    EventsStatus? eventsStatus,
    SearchSort? sort,
    int? limitPerType,
  }) =>
      search(
        query: SearchQuery.bitcoin,
        eventsStatus: eventsStatus,
        sort: sort,
        limitPerType: limitPerType,
      );

  /// Search for Ethereum-related markets
  Future<SearchResult> searchEthereum({
    EventsStatus? eventsStatus,
    SearchSort? sort,
    int? limitPerType,
  }) =>
      search(
        query: SearchQuery.ethereum,
        eventsStatus: eventsStatus,
        sort: sort,
        limitPerType: limitPerType,
      );

  /// Search for crypto-related markets
  Future<SearchResult> searchCrypto({
    EventsStatus? eventsStatus,
    SearchSort? sort,
    int? limitPerType,
  }) =>
      search(
        query: SearchQuery.crypto,
        eventsStatus: eventsStatus,
        sort: sort,
        limitPerType: limitPerType,
      );

  /// Search for election-related markets
  Future<SearchResult> searchElection({
    EventsStatus? eventsStatus,
    SearchSort? sort,
    int? limitPerType,
  }) =>
      search(
        query: SearchQuery.election,
        eventsStatus: eventsStatus,
        sort: sort,
        limitPerType: limitPerType,
      );

  /// Search for Trump-related markets
  Future<SearchResult> searchTrump({
    EventsStatus? eventsStatus,
    SearchSort? sort,
    int? limitPerType,
  }) =>
      search(
        query: SearchQuery.trump,
        eventsStatus: eventsStatus,
        sort: sort,
        limitPerType: limitPerType,
      );

  /// Search for AI-related markets
  Future<SearchResult> searchAI({
    EventsStatus? eventsStatus,
    SearchSort? sort,
    int? limitPerType,
  }) =>
      search(
        query: SearchQuery.ai,
        eventsStatus: eventsStatus,
        sort: sort,
        limitPerType: limitPerType,
      );

  /// Search for NFL-related markets
  Future<SearchResult> searchNFL({
    EventsStatus? eventsStatus,
    SearchSort? sort,
    int? limitPerType,
  }) =>
      search(
        query: SearchQuery.nfl,
        eventsStatus: eventsStatus,
        sort: sort,
        limitPerType: limitPerType,
      );

  /// Search for NBA-related markets
  Future<SearchResult> searchNBA({
    EventsStatus? eventsStatus,
    SearchSort? sort,
    int? limitPerType,
  }) =>
      search(
        query: SearchQuery.nba,
        eventsStatus: eventsStatus,
        sort: sort,
        limitPerType: limitPerType,
      );
}

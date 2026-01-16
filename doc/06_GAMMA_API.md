# Gamma API

Market discovery and metadata API. No authentication required.

---

## Base URL

```
https://gamma-api.polymarket.com
```

---

## src/gamma/gamma_client.dart

```dart
import '../core/api_client.dart';
import '../core/constants.dart';
import 'endpoints/events_endpoint.dart';
import 'endpoints/markets_endpoint.dart';
import 'endpoints/tags_endpoint.dart';
import 'endpoints/sports_endpoint.dart';
import 'endpoints/series_endpoint.dart';
import 'endpoints/comments_endpoint.dart';
import 'endpoints/profiles_endpoint.dart';
import 'endpoints/search_endpoint.dart';

/// Client for the Gamma API (market discovery and metadata).
class GammaClient {
  final ApiClient _client;

  late final EventsEndpoint events;
  late final MarketsEndpoint markets;
  late final TagsEndpoint tags;
  late final SportsEndpoint sports;
  late final SeriesEndpoint series;
  late final CommentsEndpoint comments;
  late final ProfilesEndpoint profiles;
  late final SearchEndpoint search;

  GammaClient({
    String? baseUrl,
    ApiClient? client,
  }) : _client = client ?? ApiClient(
         baseUrl: baseUrl ?? PolymarketConstants.gammaBaseUrl,
       ) {
    events = EventsEndpoint(_client);
    markets = MarketsEndpoint(_client);
    tags = TagsEndpoint(_client);
    sports = SportsEndpoint(_client);
    series = SeriesEndpoint(_client);
    comments = CommentsEndpoint(_client);
    profiles = ProfilesEndpoint(_client);
    search = SearchEndpoint(_client);
  }

  /// Check API health.
  Future<bool> isHealthy() async {
    try {
      await _client.get<dynamic>('/health');
      return true;
    } catch (_) {
      return false;
    }
  }

  void close() => _client.close();
}
```

---

## src/gamma/endpoints/events_endpoint.dart

```dart
import '../../core/api_client.dart';
import '../models/event.dart';
import '../models/tag.dart';

/// Endpoints for events.
class EventsEndpoint {
  final ApiClient _client;

  EventsEndpoint(this._client);

  /// List events with filters.
  /// 
  /// [limit] - Max events to return (default 100)
  /// [offset] - Pagination offset
  /// [order] - Field to order by (e.g., 'volume', 'startDate')
  /// [ascending] - Sort direction
  /// [closed] - Filter by closed status
  /// [active] - Filter by active status
  /// [tagId] - Filter by tag ID
  /// [featured] - Filter featured events only
  Future<List<Event>> listEvents({
    int limit = 100,
    int offset = 0,
    String? order,
    bool? ascending,
    List<int>? ids,
    List<String>? slugs,
    int? tagId,
    List<int>? excludeTagIds,
    bool? relatedTags,
    bool? featured,
    bool? cyom,
    bool? includeChat,
    bool? includeTemplate,
    String? recurrence,
    bool? closed,
    bool? active,
    bool? archived,
    DateTime? startDateMin,
    DateTime? startDateMax,
    DateTime? endDateMin,
    DateTime? endDateMax,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (order != null) params['order'] = order;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (ids != null) params['id'] = ids.join(',');
    if (slugs != null) params['slug'] = slugs.join(',');
    if (tagId != null) params['tag_id'] = tagId.toString();
    if (excludeTagIds != null) params['exclude_tag_ids'] = excludeTagIds.join(',');
    if (relatedTags != null) params['related_tags'] = relatedTags.toString();
    if (featured != null) params['featured'] = featured.toString();
    if (cyom != null) params['cyom'] = cyom.toString();
    if (includeChat != null) params['include_chat'] = includeChat.toString();
    if (includeTemplate != null) params['include_template'] = includeTemplate.toString();
    if (recurrence != null) params['recurrence'] = recurrence;
    if (closed != null) params['closed'] = closed.toString();
    if (active != null) params['active'] = active.toString();
    if (archived != null) params['archived'] = archived.toString();
    if (startDateMin != null) params['start_date_min'] = startDateMin.toIso8601String();
    if (startDateMax != null) params['start_date_max'] = startDateMax.toIso8601String();
    if (endDateMin != null) params['end_date_min'] = endDateMin.toIso8601String();
    if (endDateMax != null) params['end_date_max'] = endDateMax.toIso8601String();

    final response = await _client.get<List<dynamic>>(
      '/events',
      queryParams: params,
    );

    return response
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get event by ID.
  Future<Event> getById(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/events/$id',
    );
    return Event.fromJson(response);
  }

  /// Get event by slug.
  Future<Event> getBySlug(String slug) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/events/slug/$slug',
    );
    return Event.fromJson(response);
  }

  /// Get tags for an event.
  Future<List<Tag>> getTags(int eventId) async {
    final response = await _client.get<List<dynamic>>(
      '/events/$eventId/tags',
    );
    return response
        .map((t) => Tag.fromJson(t as Map<String, dynamic>))
        .toList();
  }
}
```

---

## src/gamma/endpoints/markets_endpoint.dart

```dart
import '../../core/api_client.dart';
import '../models/market.dart';
import '../models/tag.dart';

/// Endpoints for Gamma markets.
class MarketsEndpoint {
  final ApiClient _client;

  MarketsEndpoint(this._client);

  /// List markets with filters.
  Future<List<Market>> listMarkets({
    int limit = 100,
    int offset = 0,
    String? order,
    bool? ascending,
    List<int>? ids,
    List<String>? slugs,
    List<String>? clobTokenIds,
    List<String>? conditionIds,
    List<String>? marketMakerAddresses,
    double? liquidityNumMin,
    double? liquidityNumMax,
    double? volumeNumMin,
    double? volumeNumMax,
    DateTime? startDateMin,
    DateTime? startDateMax,
    DateTime? endDateMin,
    DateTime? endDateMax,
    int? tagId,
    bool? relatedTags,
    bool? cyom,
    String? umaResolutionStatus,
    String? gameId,
    List<String>? sportsMarketTypes,
    double? rewardsMinSize,
    List<String>? questionIds,
    bool? includeTag,
    bool? closed,
    bool? active,
    bool? archived,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (order != null) params['order'] = order;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (ids != null) params['id'] = ids.join(',');
    if (slugs != null) params['slug'] = slugs.join(',');
    if (clobTokenIds != null) params['clob_token_ids'] = clobTokenIds.join(',');
    if (conditionIds != null) params['condition_id'] = conditionIds.join(',');
    if (marketMakerAddresses != null) params['market_maker_address'] = marketMakerAddresses.join(',');
    if (liquidityNumMin != null) params['liquidity_num_min'] = liquidityNumMin.toString();
    if (liquidityNumMax != null) params['liquidity_num_max'] = liquidityNumMax.toString();
    if (volumeNumMin != null) params['volume_num_min'] = volumeNumMin.toString();
    if (volumeNumMax != null) params['volume_num_max'] = volumeNumMax.toString();
    if (tagId != null) params['tag_id'] = tagId.toString();
    if (relatedTags != null) params['related_tags'] = relatedTags.toString();
    if (cyom != null) params['cyom'] = cyom.toString();
    if (umaResolutionStatus != null) params['uma_resolution_status'] = umaResolutionStatus;
    if (gameId != null) params['game_id'] = gameId;
    if (sportsMarketTypes != null) params['sports_market_types'] = sportsMarketTypes.join(',');
    if (rewardsMinSize != null) params['rewards_min_size'] = rewardsMinSize.toString();
    if (questionIds != null) params['question_id'] = questionIds.join(',');
    if (includeTag != null) params['include_tag'] = includeTag.toString();
    if (closed != null) params['closed'] = closed.toString();
    if (active != null) params['active'] = active.toString();
    if (archived != null) params['archived'] = archived.toString();

    final response = await _client.get<List<dynamic>>(
      '/markets',
      queryParams: params,
    );

    return response
        .map((m) => Market.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// Get market by ID.
  Future<Market> getById(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/markets/$id',
    );
    return Market.fromJson(response);
  }

  /// Get market by slug.
  Future<Market> getBySlug(String slug) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/markets/slug/$slug',
    );
    return Market.fromJson(response);
  }

  /// Get market by condition ID.
  Future<Market> getByConditionId(String conditionId) async {
    final markets = await listMarkets(conditionIds: [conditionId], limit: 1);
    if (markets.isEmpty) {
      throw Exception('Market not found: $conditionId');
    }
    return markets.first;
  }

  /// Get tags for a market.
  Future<List<Tag>> getTags(int marketId) async {
    final response = await _client.get<List<dynamic>>(
      '/markets/$marketId/tags',
    );
    return response
        .map((t) => Tag.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Get CLOB-tradable markets (active + orderbook enabled).
  Future<List<Market>> getClobTradable({int limit = 100, int offset = 0}) {
    return listMarkets(
      limit: limit,
      offset: offset,
      active: true,
      closed: false,
      archived: false,
    );
  }
}
```

---

## src/gamma/endpoints/tags_endpoint.dart

```dart
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

    return response
        .map((t) => Tag.fromJson(t as Map<String, dynamic>))
        .toList();
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
    return response
        .map((t) => Tag.fromJson(t as Map<String, dynamic>))
        .toList();
  }
}
```

---

## src/gamma/endpoints/series_endpoint.dart

```dart
import '../../core/api_client.dart';
import '../models/series.dart';

/// Endpoints for series.
class SeriesEndpoint {
  final ApiClient _client;

  SeriesEndpoint(this._client);

  /// List series with filters.
  Future<List<Series>> listSeries({
    int limit = 100,
    int offset = 0,
    String? order,
    bool? ascending,
    List<String>? slugs,
    List<int>? categoriesIds,
    List<String>? categoriesLabels,
    bool? closed,
    bool? includeChat,
    String? recurrence,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (order != null) params['order'] = order;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (slugs != null) params['slug'] = slugs.join(',');
    if (categoriesIds != null) params['categories_id'] = categoriesIds.join(',');
    if (categoriesLabels != null) params['categories_label'] = categoriesLabels.join(',');
    if (closed != null) params['closed'] = closed.toString();
    if (includeChat != null) params['include_chat'] = includeChat.toString();
    if (recurrence != null) params['recurrence'] = recurrence;

    final response = await _client.get<List<dynamic>>(
      '/series',
      queryParams: params,
    );

    return response
        .map((s) => Series.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  /// Get series by ID.
  Future<Series> getById(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/series/$id',
    );
    return Series.fromJson(response);
  }
}
```

---

## src/gamma/endpoints/comments_endpoint.dart

```dart
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
    if (parentEntityType != null) params['parent_entity_type'] = parentEntityType.toJson();
    if (parentEntityId != null) params['parent_entity_id'] = parentEntityId.toString();
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
```

---

## src/gamma/endpoints/profiles_endpoint.dart

```dart
import '../../core/api_client.dart';
import '../models/profile.dart';

/// Endpoints for user profiles.
class ProfilesEndpoint {
  final ApiClient _client;

  ProfilesEndpoint(this._client);

  /// Get public profile by wallet address.
  Future<Profile> getByAddress(String address) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/profiles/$address',
    );
    return Profile.fromJson(response);
  }
}
```

---

## src/gamma/endpoints/search_endpoint.dart

```dart
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
    if (limitPerType != null) params['limit_per_type'] = limitPerType.toString();
    if (page != null) params['page'] = page.toString();
    if (eventsTags != null) params['events_tags'] = eventsTags.join(',');
    if (keepClosedMarkets != null) params['keep_closed_markets'] = keepClosedMarkets.toString();
    if (sort != null) params['sort'] = sort;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (searchTags != null) params['search_tags'] = searchTags.toString();
    if (searchProfiles != null) params['search_profiles'] = searchProfiles.toString();
    if (recurrence != null) params['recurrence'] = recurrence;
    if (excludeTagIds != null) params['exclude_tag_ids'] = excludeTagIds.join(',');
    if (optimized != null) params['optimized'] = optimized.toString();

    final response = await _client.get<Map<String, dynamic>>(
      '/search',
      queryParams: params,
    );

    return SearchResult.fromJson(response);
  }
}
```

---

## src/gamma/endpoints/sports_endpoint.dart

```dart
import '../../core/api_client.dart';
import '../models/team.dart';

/// Endpoints for sports data.
class SportsEndpoint {
  final ApiClient _client;

  SportsEndpoint(this._client);

  /// List teams with filters.
  Future<List<Team>> listTeams({
    int limit = 100,
    int offset = 0,
    String? order,
    bool? ascending,
    List<String>? leagues,
    List<String>? names,
    List<String>? abbreviations,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (order != null) params['order'] = order;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (leagues != null) params['league'] = leagues.join(',');
    if (names != null) params['name'] = names.join(',');
    if (abbreviations != null) params['abbreviation'] = abbreviations.join(',');

    final response = await _client.get<List<dynamic>>(
      '/teams',
      queryParams: params,
    );

    return response
        .map((t) => Team.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Get sports metadata (leagues, market types, etc.)
  Future<Map<String, dynamic>> getMetadata() async {
    return await _client.get<Map<String, dynamic>>('/sports/metadata');
  }

  /// Get valid sports market types.
  Future<List<String>> getValidMarketTypes() async {
    final response = await _client.get<List<dynamic>>('/sports/market-types');
    return response.cast<String>();
  }
}
```

---

## Barrel Export

### src/gamma/gamma.dart

```dart
export 'gamma_client.dart';
export 'endpoints/events_endpoint.dart';
export 'endpoints/markets_endpoint.dart';
export 'endpoints/tags_endpoint.dart';
export 'endpoints/sports_endpoint.dart';
export 'endpoints/series_endpoint.dart';
export 'endpoints/comments_endpoint.dart';
export 'endpoints/profiles_endpoint.dart';
export 'endpoints/search_endpoint.dart';
export 'models/models.dart';
```

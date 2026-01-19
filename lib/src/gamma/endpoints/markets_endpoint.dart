import '../../core/api_client.dart';
import '../../enums/market_order_by.dart';
import '../../enums/sports_market_type.dart';
import '../../enums/tag_slug.dart';
import '../../enums/uma_resolution_status.dart';
import '../models/market.dart';
import '../models/tag.dart';

/// Endpoints for Gamma markets.
class MarketsEndpoint {
  final ApiClient _client;

  MarketsEndpoint(this._client);

  /// List markets with filters.
  ///
  /// [order] - Field to order by (volume, volume24hr, liquidity, endDate, startDate, createdAt)
  /// [ascending] - Sort direction (true = ascending, false = descending)
  /// [tagSlug] - Filter by tag slug (use [TagSlug] presets or custom)
  Future<List<Market>> listMarkets({
    int limit = 100,
    int offset = 0,
    MarketOrderBy? order,
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
    TagSlug? tagSlug,
    bool? relatedTags,
    bool? cyom,
    UmaResolutionStatus? umaResolutionStatus,
    String? gameId,
    List<SportsMarketType>? sportsMarketTypes,
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

    if (order != null) params['order'] = order.value;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (ids != null) params['id'] = ids.join(',');
    if (slugs != null) params['slug'] = slugs.join(',');
    if (clobTokenIds != null) params['clob_token_ids'] = clobTokenIds.join(',');
    if (conditionIds != null) params['condition_id'] = conditionIds.join(',');
    if (marketMakerAddresses != null) {
      params['market_maker_address'] = marketMakerAddresses.join(',');
    }
    if (liquidityNumMin != null) {
      params['liquidity_num_min'] = liquidityNumMin.toString();
    }
    if (liquidityNumMax != null) {
      params['liquidity_num_max'] = liquidityNumMax.toString();
    }
    if (volumeNumMin != null) params['volume_num_min'] = volumeNumMin.toString();
    if (volumeNumMax != null) params['volume_num_max'] = volumeNumMax.toString();
    if (tagId != null) params['tag_id'] = tagId.toString();
    if (tagSlug != null) params['tag_slug'] = tagSlug.value;
    if (relatedTags != null) params['related_tags'] = relatedTags.toString();
    if (cyom != null) params['cyom'] = cyom.toString();
    if (umaResolutionStatus != null) {
      params['uma_resolution_status'] = umaResolutionStatus.value;
    }
    if (gameId != null) params['game_id'] = gameId;
    if (sportsMarketTypes != null) {
      params['sports_market_types'] =
          sportsMarketTypes.map((t) => t.value).join(',');
    }
    if (rewardsMinSize != null) {
      params['rewards_min_size'] = rewardsMinSize.toString();
    }
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
    return response.map((t) => Tag.fromJson(t as Map<String, dynamic>)).toList();
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

  /// Get top markets by volume.
  Future<List<Market>> getTopByVolume({int limit = 20}) {
    return listMarkets(
      limit: limit,
      order: MarketOrderBy.volume,
      ascending: false,
      active: true,
      closed: false,
    );
  }

  /// Get top markets by 24h volume.
  Future<List<Market>> getTopByVolume24hr({int limit = 20}) {
    return listMarkets(
      limit: limit,
      order: MarketOrderBy.volume24hr,
      ascending: false,
      active: true,
      closed: false,
    );
  }

  /// Get top markets by liquidity.
  Future<List<Market>> getTopByLiquidity({int limit = 20}) {
    return listMarkets(
      limit: limit,
      order: MarketOrderBy.liquidity,
      ascending: false,
      active: true,
      closed: false,
    );
  }

  /// Get markets by tag slug.
  ///
  /// ```dart
  /// // Using preset
  /// final markets = await client.gamma.markets.getByTagSlug(TagSlug.crypto);
  ///
  /// // Using custom
  /// final markets = await client.gamma.markets.getByTagSlug(TagSlug.custom('my-tag'));
  /// ```
  Future<List<Market>> getByTagSlug(TagSlug tagSlug, {int limit = 100}) {
    return listMarkets(
      limit: limit,
      tagSlug: tagSlug,
      active: true,
      closed: false,
    );
  }

  /// Get markets ending soon.
  Future<List<Market>> getEndingSoon({
    int limit = 20,
    Duration within = const Duration(days: 7),
  }) {
    final now = DateTime.now();
    return listMarkets(
      limit: limit,
      endDateMin: now,
      endDateMax: now.add(within),
      active: true,
      closed: false,
      order: MarketOrderBy.endDate,
      ascending: true,
    );
  }
}

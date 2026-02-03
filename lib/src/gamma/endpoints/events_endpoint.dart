import '../../core/api_client.dart';
import '../../enums/event_order_by.dart';
import '../../enums/recurrence_type.dart';
import '../../enums/tag_slug.dart';
import '../models/event.dart';
import '../models/soccer_match.dart';
import '../models/tag.dart';

/// Endpoints for events.
class EventsEndpoint {
  final ApiClient _client;

  EventsEndpoint(this._client);

  /// List events with filters.
  ///
  /// [limit] - Max events to return (default 100)
  /// [offset] - Pagination offset
  /// [order] - Field to order by (volume, startDate, endDate, createdAt, liquidity)
  /// [ascending] - Sort direction
  /// [closed] - Filter by closed status
  /// [active] - Filter by active status
  /// [tagId] - Filter by tag ID
  /// [tagSlug] - Filter by tag slug (use [TagSlug] presets or custom)
  /// [featured] - Filter featured events only
  /// [hot] - Filter hot/trending events
  Future<List<Event>> listEvents({
    int limit = 100,
    int offset = 0,
    EventOrderBy? order,
    bool? ascending,
    List<int>? ids,
    List<String>? slugs,
    int? tagId,
    TagSlug? tagSlug,
    List<int>? excludeTagIds,
    bool? relatedTags,
    bool? featured,
    bool? hot,
    bool? cyom,
    bool? includeChat,
    bool? includeTemplate,
    RecurrenceType? recurrence,
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

    if (order != null) params['order'] = order.value;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (ids != null) params['id'] = ids.join(',');
    if (slugs != null) params['slug'] = slugs.join(',');
    if (tagId != null) params['tag_id'] = tagId.toString();
    if (tagSlug != null) params['tag_slug'] = tagSlug.value;
    if (excludeTagIds != null) {
      params['exclude_tag_ids'] = excludeTagIds.join(',');
    }
    if (relatedTags != null) params['related_tags'] = relatedTags.toString();
    if (featured != null) params['featured'] = featured.toString();
    if (hot != null) params['hot'] = hot.toString();
    if (cyom != null) params['cyom'] = cyom.toString();
    if (includeChat != null) params['include_chat'] = includeChat.toString();
    if (includeTemplate != null) {
      params['include_template'] = includeTemplate.toString();
    }
    if (recurrence != null) params['recurrence'] = recurrence.value;
    if (closed != null) params['closed'] = closed.toString();
    if (active != null) params['active'] = active.toString();
    if (archived != null) params['archived'] = archived.toString();
    if (startDateMin != null) {
      params['start_date_min'] = startDateMin.toIso8601String();
    }
    if (startDateMax != null) {
      params['start_date_max'] = startDateMax.toIso8601String();
    }
    if (endDateMin != null) {
      params['end_date_min'] = endDateMin.toIso8601String();
    }
    if (endDateMax != null) {
      params['end_date_max'] = endDateMax.toIso8601String();
    }

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
    return response.map((t) => Tag.fromJson(t as Map<String, dynamic>)).toList();
  }

  /// Get hot/trending events.
  Future<List<Event>> getHotEvents({int limit = 20}) {
    return listEvents(
      limit: limit,
      hot: true,
      active: true,
      closed: false,
    );
  }

  /// Get featured events.
  Future<List<Event>> getFeaturedEvents({int limit = 20}) {
    return listEvents(
      limit: limit,
      featured: true,
      active: true,
      closed: false,
    );
  }

  /// Get events by tag slug.
  ///
  /// ```dart
  /// // Using preset
  /// final events = await client.gamma.events.getByTagSlug(TagSlug.politics);
  ///
  /// // Using custom
  /// final events = await client.gamma.events.getByTagSlug(TagSlug.custom('my-tag'));
  /// ```
  Future<List<Event>> getByTagSlug(TagSlug tagSlug, {int limit = 100}) {
    return listEvents(
      limit: limit,
      tagSlug: tagSlug,
      active: true,
      closed: false,
    );
  }

  /// Get events ending soon.
  Future<List<Event>> getEndingSoon({
    int limit = 20,
    Duration within = const Duration(days: 7),
  }) {
    final now = DateTime.now();
    return listEvents(
      limit: limit,
      endDateMin: now,
      endDateMax: now.add(within),
      active: true,
      closed: false,
      order: EventOrderBy.endDate,
      ascending: true,
    );
  }

  // =========================================================================
  // SOCCER MATCH METHODS
  // =========================================================================

  /// Get active soccer matches from a specific league with draw markets.
  ///
  /// This method fetches events from the specified league tag and converts
  /// them to [SoccerMatch] objects, filtering for:
  /// - Active events only (not ended/resolved)
  /// - Match format events (Team A vs Team B)
  /// - Events with draw markets (required for hedge strategies)
  ///
  /// ```dart
  /// // Get Premier League matches
  /// final matches = await client.gamma.events.getSoccerMatches(
  ///   TagSlug.premierLeague,
  /// );
  ///
  /// for (final match in matches) {
  ///   print('${match.teamA} vs ${match.teamB}');
  ///   print('  Draw price: ${match.drawPrice}');
  ///   print('  No-draw price: ${match.noDrawPrice}');
  /// }
  /// ```
  Future<List<SoccerMatch>> getSoccerMatches(
    TagSlug leagueTag, {
    int limit = 100,
    bool requireDrawMarket = true,
    bool activeOnly = true,
    DateTime? matchAfter,
    DateTime? matchBefore,
  }) async {
    // Fetch more events to account for client-side filtering
    // (API date filters return 422 errors, so we filter client-side)
    final fetchLimit = (matchAfter != null || matchBefore != null)
        ? (limit * 3).clamp(limit, 300)
        : limit;

    final events = await listEvents(
      limit: fetchLimit,
      tagSlug: leagueTag,
      active: activeOnly,
      closed: false,
      archived: false,
      order: EventOrderBy.endDate,
      ascending: true,
    );

    var matches = SoccerMatch.fromEvents(events, league: leagueTag.value);

    // Client-side date filtering (API date params return 422 errors)
    if (matchAfter != null) {
      matches = matches
          .where((m) => m.matchTime != null && m.matchTime!.isAfter(matchAfter))
          .toList();
    }
    if (matchBefore != null) {
      matches = matches
          .where(
              (m) => m.matchTime != null && m.matchTime!.isBefore(matchBefore))
          .toList();
    }

    if (requireDrawMarket) {
      matches = matches.where((m) => m.hasDrawMarket).toList();
    }

    // Apply limit after filtering
    if (matches.length > limit) {
      matches = matches.sublist(0, limit);
    }

    return matches;
  }

  /// Get active soccer matches from multiple leagues.
  ///
  /// Fetches matches from all specified leagues and combines them.
  ///
  /// ```dart
  /// final matches = await client.gamma.events.getSoccerMatchesMultiLeague([
  ///   TagSlug.premierLeague,
  ///   TagSlug.laLiga,
  ///   TagSlug.bundesliga,
  /// ]);
  /// ```
  Future<List<SoccerMatch>> getSoccerMatchesMultiLeague(
    List<TagSlug> leagueTags, {
    int limitPerLeague = 50,
    bool requireDrawMarket = true,
    bool activeOnly = true,
    DateTime? matchAfter,
    DateTime? matchBefore,
  }) async {
    final allMatches = <SoccerMatch>[];

    for (final tag in leagueTags) {
      final matches = await getSoccerMatches(
        tag,
        limit: limitPerLeague,
        requireDrawMarket: requireDrawMarket,
        activeOnly: activeOnly,
        matchAfter: matchAfter,
        matchBefore: matchBefore,
      );
      allMatches.addAll(matches);
    }

    // Sort by match time
    allMatches.sort((a, b) {
      final aTime = a.matchTime;
      final bTime = b.matchTime;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return aTime.compareTo(bTime);
    });

    return allMatches;
  }

  /// Get all European football matches from major leagues.
  ///
  /// Convenience method that fetches from:
  /// - Premier League
  /// - La Liga
  /// - Bundesliga
  /// - Serie A
  /// - Ligue 1
  /// - Champions League
  /// - Europa League
  ///
  /// ```dart
  /// final matches = await client.gamma.events.getEuropeanFootballMatches();
  /// ```
  Future<List<SoccerMatch>> getEuropeanFootballMatches({
    int limitPerLeague = 30,
    bool requireDrawMarket = true,
    DateTime? matchAfter,
    DateTime? matchBefore,
  }) {
    return getSoccerMatchesMultiLeague(
      [
        TagSlug.premierLeague,
        TagSlug.laLiga,
        TagSlug.bundesliga,
        TagSlug.serieA,
        TagSlug.ligue1,
        TagSlug.championsLeague,
        TagSlug.europaLeague,
      ],
      limitPerLeague: limitPerLeague,
      requireDrawMarket: requireDrawMarket,
      matchAfter: matchAfter,
      matchBefore: matchBefore,
    );
  }

  /// Get upcoming soccer matches (within the next N days).
  ///
  /// ```dart
  /// // Get matches in the next 7 days
  /// final upcoming = await client.gamma.events.getUpcomingSoccerMatches(
  ///   TagSlug.premierLeague,
  ///   withinDays: 7,
  /// );
  /// ```
  Future<List<SoccerMatch>> getUpcomingSoccerMatches(
    TagSlug leagueTag, {
    int withinDays = 7,
    int limit = 50,
  }) {
    final now = DateTime.now();
    return getSoccerMatches(
      leagueTag,
      limit: limit,
      matchAfter: now,
      matchBefore: now.add(Duration(days: withinDays)),
    );
  }
}

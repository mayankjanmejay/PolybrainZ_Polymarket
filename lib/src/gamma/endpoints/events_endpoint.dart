import '../../core/api_client.dart';
import '../../enums/event_order_by.dart';
import '../../enums/recurrence_type.dart';
import '../../enums/tag_slug.dart';
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
}

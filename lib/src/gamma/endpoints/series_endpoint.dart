import '../../core/api_client.dart';
import '../../enums/market_category.dart';
import '../../enums/recurrence_type.dart';
import '../../enums/series_order_by.dart';
import '../models/series.dart';

/// Endpoints for series.
class SeriesEndpoint {
  final ApiClient _client;

  SeriesEndpoint(this._client);

  /// List series with filters.
  ///
  /// [order] - Field to order by (volume, startDate, endDate, createdAt, liquidity)
  /// [ascending] - Sort direction (true = ascending, false = descending)
  /// [recurrence] - Filter by recurrence type (daily, weekly, monthly, yearly, none)
  Future<List<Series>> listSeries({
    int limit = 100,
    int offset = 0,
    SeriesOrderBy? order,
    bool? ascending,
    List<String>? slugs,
    List<int>? categoriesIds,
    List<MarketCategory>? categories,
    bool? closed,
    bool? includeChat,
    RecurrenceType? recurrence,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (order != null) params['order'] = order.value;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (slugs != null) params['slug'] = slugs.join(',');
    if (categoriesIds != null) {
      params['categories_id'] = categoriesIds.join(',');
    }
    if (categories != null) {
      params['categories_label'] = categories.map((c) => c.label).join(',');
    }
    if (closed != null) params['closed'] = closed.toString();
    if (includeChat != null) params['include_chat'] = includeChat.toString();
    if (recurrence != null) params['recurrence'] = recurrence.value;

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

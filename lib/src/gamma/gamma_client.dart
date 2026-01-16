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
  }) : _client = client ??
            ApiClient(
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

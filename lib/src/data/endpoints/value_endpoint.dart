import '../../core/api_client.dart';
import '../models/holdings_value.dart';

/// Endpoints for portfolio value.
class ValueEndpoint {
  final ApiClient _client;

  ValueEndpoint(this._client);

  /// Get total holdings value for a user.
  Future<HoldingsValue> getValue(String userAddress) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/value',
      queryParams: {'user': userAddress},
    );

    return HoldingsValue.fromJson(response);
  }
}

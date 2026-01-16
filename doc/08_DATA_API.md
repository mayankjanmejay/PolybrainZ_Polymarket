# Data API

Positions, trades, activity, and leaderboard data. No authentication required.

---

## Base URL

```
https://data-api.polymarket.com
```

---

## src/data/data_client.dart

```dart
import '../core/api_client.dart';
import '../core/constants.dart';
import 'endpoints/positions_endpoint.dart';
import 'endpoints/trades_endpoint.dart';
import 'endpoints/activity_endpoint.dart';
import 'endpoints/holders_endpoint.dart';
import 'endpoints/value_endpoint.dart';
import 'endpoints/leaderboard_endpoint.dart';

/// Client for the Data API (positions, trades, activity).
class DataClient {
  final ApiClient _client;

  late final PositionsEndpoint positions;
  late final DataTradesEndpoint trades;
  late final ActivityEndpoint activity;
  late final HoldersEndpoint holders;
  late final ValueEndpoint value;
  late final LeaderboardEndpoint leaderboard;

  DataClient({
    String? baseUrl,
    ApiClient? client,
  }) : _client = client ?? ApiClient(
         baseUrl: baseUrl ?? PolymarketConstants.dataBaseUrl,
       ) {
    positions = PositionsEndpoint(_client);
    trades = DataTradesEndpoint(_client);
    activity = ActivityEndpoint(_client);
    holders = HoldersEndpoint(_client);
    value = ValueEndpoint(_client);
    leaderboard = LeaderboardEndpoint(_client);
  }

  /// Health check.
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

## src/data/endpoints/positions_endpoint.dart

```dart
import '../../core/api_client.dart';
import '../../enums/sort_by.dart';
import '../../enums/sort_direction.dart';
import '../models/position.dart';
import '../models/closed_position.dart';

/// Endpoints for user positions.
class PositionsEndpoint {
  final ApiClient _client;

  PositionsEndpoint(this._client);

  /// Get open positions for a user.
  /// 
  /// [userAddress] - Wallet address (proxy wallet)
  /// [sizeThreshold] - Min position size to include
  /// [sortBy] - Sort field
  /// [sortDirection] - Sort direction
  Future<List<Position>> getPositions({
    required String userAddress,
    double? sizeThreshold,
    SortBy? sortBy,
    SortDirection? sortDirection,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'user': userAddress,
    };

    if (sizeThreshold != null) params['sizeThreshold'] = sizeThreshold.toString();
    if (sortBy != null) params['sortBy'] = sortBy.toJson();
    if (sortDirection != null) params['sortDir'] = sortDirection.toJson();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/positions',
      queryParams: params,
    );

    return response
        .map((p) => Position.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Get closed (resolved) positions for a user.
  Future<List<ClosedPosition>> getClosedPositions({
    required String userAddress,
    SortBy? sortBy,
    SortDirection? sortDirection,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'user': userAddress,
    };

    if (sortBy != null) params['sortBy'] = sortBy.toJson();
    if (sortDirection != null) params['sortDir'] = sortDirection.toJson();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/closed-positions',
      queryParams: params,
    );

    return response
        .map((p) => ClosedPosition.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Get positions for a specific market.
  Future<List<Position>> getMarketPositions({
    required String conditionId,
    double? sizeThreshold,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'market': conditionId,
    };

    if (sizeThreshold != null) params['sizeThreshold'] = sizeThreshold.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/positions',
      queryParams: params,
    );

    return response
        .map((p) => Position.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}
```

---

## src/data/endpoints/trades_endpoint.dart

```dart
import '../../core/api_client.dart';
import '../../enums/sort_by.dart';
import '../../enums/sort_direction.dart';
import '../../enums/filter_type.dart';
import '../models/trade_record.dart';

/// Endpoints for trade history (Data API).
class DataTradesEndpoint {
  final ApiClient _client;

  DataTradesEndpoint(this._client);

  /// Get trades for a user.
  Future<List<TradeRecord>> getUserTrades({
    required String userAddress,
    SortBy? sortBy,
    SortDirection? sortDirection,
    FilterType? filterType,
    double? filterValue,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'user': userAddress,
    };

    if (sortBy != null) params['sortBy'] = sortBy.toJson();
    if (sortDirection != null) params['sortDir'] = sortDirection.toJson();
    if (filterType != null) params['filterType'] = filterType.toJson();
    if (filterValue != null) params['filterValue'] = filterValue.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/trades',
      queryParams: params,
    );

    return response
        .map((t) => TradeRecord.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Get trades for a specific market.
  Future<List<TradeRecord>> getMarketTrades({
    required String conditionId,
    SortBy? sortBy,
    SortDirection? sortDirection,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'market': conditionId,
    };

    if (sortBy != null) params['sortBy'] = sortBy.toJson();
    if (sortDirection != null) params['sortDir'] = sortDirection.toJson();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/trades',
      queryParams: params,
    );

    return response
        .map((t) => TradeRecord.fromJson(t as Map<String, dynamic>))
        .toList();
  }
}
```

---

## src/data/endpoints/activity_endpoint.dart

```dart
import '../../core/api_client.dart';
import '../../enums/activity_type.dart';
import '../../enums/sort_direction.dart';
import '../models/activity.dart';

/// Endpoints for on-chain activity.
class ActivityEndpoint {
  final ApiClient _client;

  ActivityEndpoint(this._client);

  /// Get activity for a user.
  /// 
  /// [types] - Filter by activity types (TRADE, SPLIT, MERGE, REDEEM, etc.)
  Future<List<Activity>> getUserActivity({
    required String userAddress,
    List<ActivityType>? types,
    SortDirection? sortDirection,
    int? startTs,
    int? endTs,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'user': userAddress,
    };

    if (types != null && types.isNotEmpty) {
      params['type'] = types.map((t) => t.toJson()).join(',');
    }
    if (sortDirection != null) params['sortDir'] = sortDirection.toJson();
    if (startTs != null) params['startTs'] = startTs.toString();
    if (endTs != null) params['endTs'] = endTs.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/activity',
      queryParams: params,
    );

    return response
        .map((a) => Activity.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  /// Get activity for a specific market.
  Future<List<Activity>> getMarketActivity({
    required String conditionId,
    List<ActivityType>? types,
    SortDirection? sortDirection,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'market': conditionId,
    };

    if (types != null && types.isNotEmpty) {
      params['type'] = types.map((t) => t.toJson()).join(',');
    }
    if (sortDirection != null) params['sortDir'] = sortDirection.toJson();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/activity',
      queryParams: params,
    );

    return response
        .map((a) => Activity.fromJson(a as Map<String, dynamic>))
        .toList();
  }
}
```

---

## src/data/endpoints/holders_endpoint.dart

```dart
import '../../core/api_client.dart';
import '../models/holder.dart';

/// Endpoints for token holders.
class HoldersEndpoint {
  final ApiClient _client;

  HoldersEndpoint(this._client);

  /// Get holders of a specific token.
  Future<List<Holder>> getTokenHolders({
    required String tokenId,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'token': tokenId,
    };

    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/holders',
      queryParams: params,
    );

    return response
        .map((h) => Holder.fromJson(h as Map<String, dynamic>))
        .toList();
  }

  /// Get holders for a market (both outcomes).
  Future<List<Holder>> getMarketHolders({
    required String conditionId,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'market': conditionId,
    };

    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/holders',
      queryParams: params,
    );

    return response
        .map((h) => Holder.fromJson(h as Map<String, dynamic>))
        .toList();
  }
}
```

---

## src/data/endpoints/value_endpoint.dart

```dart
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
```

---

## src/data/endpoints/leaderboard_endpoint.dart

```dart
import '../../core/api_client.dart';
import '../../enums/leaderboard_window.dart';
import '../../enums/leaderboard_type.dart';
import '../models/leaderboard_entry.dart';

/// Endpoints for leaderboard.
class LeaderboardEndpoint {
  final ApiClient _client;

  LeaderboardEndpoint(this._client);

  /// Get leaderboard rankings.
  /// 
  /// [window] - Time window (1d, 7d, 30d, all)
  /// [type] - Ranking type (PROFIT or VOLUME)
  Future<List<LeaderboardEntry>> getLeaderboard({
    LeaderboardWindow window = LeaderboardWindow.all,
    LeaderboardType type = LeaderboardType.profit,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'window': window.toJson(),
      'type': type.toJson(),
    };

    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/leaderboard',
      queryParams: params,
    );

    return response
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific user's leaderboard rank.
  Future<LeaderboardEntry?> getUserRank(
    String userAddress, {
    LeaderboardWindow window = LeaderboardWindow.all,
    LeaderboardType type = LeaderboardType.profit,
  }) async {
    final params = <String, String>{
      'user': userAddress,
      'window': window.toJson(),
      'type': type.toJson(),
    };

    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/leaderboard/user',
        queryParams: params,
      );
      return LeaderboardEntry.fromJson(response);
    } catch (_) {
      return null; // User not on leaderboard
    }
  }
}
```

---

## src/data/models/closed_position.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'closed_position.g.dart';

/// A resolved/closed position with payout info.
@JsonSerializable(fieldRename: FieldRename.snake)
class ClosedPosition extends Equatable {
  final String proxyWallet;
  final String asset;
  final String conditionId;
  final double size;
  final double avgPrice;
  final double initialValue;
  final double payout;
  final double cashPnl;
  final double percentPnl;
  final String title;
  final String slug;
  final String? icon;
  final String eventSlug;
  final String outcome;
  final int outcomeIndex;
  
  @JsonKey(defaultValue: false)
  final bool won;
  
  final DateTime? resolutionDate;

  const ClosedPosition({
    required this.proxyWallet,
    required this.asset,
    required this.conditionId,
    required this.size,
    required this.avgPrice,
    required this.initialValue,
    required this.payout,
    required this.cashPnl,
    required this.percentPnl,
    required this.title,
    required this.slug,
    this.icon,
    required this.eventSlug,
    required this.outcome,
    required this.outcomeIndex,
    this.won = false,
    this.resolutionDate,
  });

  factory ClosedPosition.fromJson(Map<String, dynamic> json) => 
      _$ClosedPositionFromJson(json);
  Map<String, dynamic> toJson() => _$ClosedPositionToJson(this);

  @override
  List<Object?> get props => [proxyWallet, asset, conditionId];
}
```

---

## src/data/models/trade_record.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trade_record.g.dart';

/// A trade record from the Data API.
@JsonSerializable(fieldRename: FieldRename.snake)
class TradeRecord extends Equatable {
  final String proxyWallet;
  final String conditionId;
  final String asset;
  final String side;
  final double size;
  final double price;
  final double usdcSize;
  final int timestamp;
  final String transactionHash;
  final String title;
  final String slug;
  final String? icon;
  final String eventSlug;
  final String outcome;
  final int outcomeIndex;
  final String? name;
  final String? pseudonym;
  final String? profileImage;

  const TradeRecord({
    required this.proxyWallet,
    required this.conditionId,
    required this.asset,
    required this.side,
    required this.size,
    required this.price,
    required this.usdcSize,
    required this.timestamp,
    required this.transactionHash,
    required this.title,
    required this.slug,
    this.icon,
    required this.eventSlug,
    required this.outcome,
    required this.outcomeIndex,
    this.name,
    this.pseudonym,
    this.profileImage,
  });

  factory TradeRecord.fromJson(Map<String, dynamic> json) => 
      _$TradeRecordFromJson(json);
  Map<String, dynamic> toJson() => _$TradeRecordToJson(this);

  DateTime get timestampDate => 
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  @override
  List<Object?> get props => [proxyWallet, conditionId, timestamp, transactionHash];
}
```

---

## Barrel Export

### src/data/data.dart

```dart
export 'data_client.dart';
export 'endpoints/positions_endpoint.dart';
export 'endpoints/trades_endpoint.dart';
export 'endpoints/activity_endpoint.dart';
export 'endpoints/holders_endpoint.dart';
export 'endpoints/value_endpoint.dart';
export 'endpoints/leaderboard_endpoint.dart';
export 'models/models.dart';
```

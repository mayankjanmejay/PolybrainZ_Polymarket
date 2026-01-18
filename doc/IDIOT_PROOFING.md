# Idiot-Proofing Progress Tracker

> Making `polybrainz_polymarket` impossible to misuse through comprehensive type safety.

**Current Grade: A-** (Target: A)

**Last Updated:** 2026-01-18

---

## Overview

This document tracks the progress of converting all string parameters with fixed/known values to type-safe enums, sealed classes, or validated types. The goal is to make the SDK "idiot proof" - users should get compile-time errors for invalid inputs, not runtime failures or silent bugs.

---

## ✅ Completed Work

### v1.3.0 - Order Parameter Enums

| Task | Status | File |
|------|--------|------|
| Create `MarketOrderBy` enum | ✅ Done | `lib/src/enums/market_order_by.dart` |
| Create `EventOrderBy` enum | ✅ Done | `lib/src/enums/event_order_by.dart` |
| Update `MarketsEndpoint.listMarkets()` | ✅ Done | `lib/src/gamma/endpoints/markets_endpoint.dart` |
| Update `EventsEndpoint.listEvents()` | ✅ Done | `lib/src/gamma/endpoints/events_endpoint.dart` |

### v1.4.0 - Additional Type-Safe Enums

| Task | Status | File |
|------|--------|------|
| Create `PriceHistoryInterval` enum | ✅ Done | `lib/src/enums/price_history_interval.dart` |
| Create `GammaLeaderboardOrderBy` enum | ✅ Done | `lib/src/enums/gamma_leaderboard_order_by.dart` |
| Create `SearchSort` enum | ✅ Done | `lib/src/enums/search_sort.dart` |
| Create `EventsStatus` enum | ✅ Done | `lib/src/enums/events_status.dart` |
| Create `WsSubscriptionType` enum | ✅ Done | `lib/src/enums/ws_subscription_type.dart` |
| Update `PricingEndpoint.getPriceHistory()` | ✅ Done | `lib/src/clob/endpoints/pricing_endpoint.dart` |
| Update `LeaderboardEndpoint` (Gamma) | ✅ Done | `lib/src/gamma/endpoints/leaderboard_endpoint.dart` |
| Update `SearchEndpoint` sort/status | ✅ Done | `lib/src/gamma/endpoints/search_endpoint.dart` |
| Update `WebSocketClient.subscribe()` | ✅ Done | `lib/src/core/websocket_client.dart` |

### v1.5.0 - SearchQuery Sealed Class

| Task | Status | File |
|------|--------|------|
| Create `SearchQuery` sealed class | ✅ Done | `lib/src/enums/search_query.dart` |
| Add 60+ preset queries | ✅ Done | `lib/src/enums/search_query.dart` |
| Add category-grouped presets | ✅ Done | `lib/src/enums/search_query.dart` |
| Update `SearchEndpoint.search()` | ✅ Done | `lib/src/gamma/endpoints/search_endpoint.dart` |
| Add convenience methods (searchBitcoin, etc.) | ✅ Done | `lib/src/gamma/endpoints/search_endpoint.dart` |
| Update example files | ✅ Done | `example/market_discovery_example.dart` |

### v1.6.0 - Critical Fixes (Phase 1 Complete!)

| Task | Status | File |
|------|--------|------|
| Create `TagOrderBy` enum | ✅ Done | `lib/src/enums/tag_order_by.dart` |
| Create `CommentOrderBy` enum | ✅ Done | `lib/src/enums/comment_order_by.dart` |
| Create `SeriesOrderBy` enum | ✅ Done | `lib/src/enums/series_order_by.dart` |
| Create `SportsOrderBy` enum | ✅ Done | `lib/src/enums/sports_order_by.dart` |
| Create `RecurrenceType` enum | ✅ Done | `lib/src/enums/recurrence_type.dart` |
| Create `UmaResolutionStatus` enum | ✅ Done | `lib/src/enums/uma_resolution_status.dart` |
| Update `TagsEndpoint` to use `TagOrderBy` | ✅ Done | `lib/src/gamma/endpoints/tags_endpoint.dart` |
| Update `CommentsEndpoint` to use `CommentOrderBy` | ✅ Done | `lib/src/gamma/endpoints/comments_endpoint.dart` |
| Update `SeriesEndpoint` to use `SeriesOrderBy` | ✅ Done | `lib/src/gamma/endpoints/series_endpoint.dart` |
| Update `SportsEndpoint` to use `SportsOrderBy` | ✅ Done | `lib/src/gamma/endpoints/sports_endpoint.dart` |
| Update `SearchEndpoint` to use `RecurrenceType` | ✅ Done | `lib/src/gamma/endpoints/search_endpoint.dart` |
| Update `EventsEndpoint` to use `RecurrenceType` | ✅ Done | `lib/src/gamma/endpoints/events_endpoint.dart` |
| Update `SeriesEndpoint` to use `RecurrenceType` | ✅ Done | `lib/src/gamma/endpoints/series_endpoint.dart` |
| Update `MarketsEndpoint` to use `UmaResolutionStatus` | ✅ Done | `lib/src/gamma/endpoints/markets_endpoint.dart` |
| Export all new enums in `enums.dart` | ✅ Done | `lib/src/enums/enums.dart` |

### v1.6.0 - Major Fixes (Phase 2 Complete!)

| Task | Status | File |
|------|--------|------|
| Standardize `fromJson` error handling (LeaderboardWindow) | ✅ Done | `lib/src/enums/leaderboard_window.dart` |
| Standardize `fromJson` error handling (LeaderboardType) | ✅ Done | `lib/src/enums/leaderboard_type.dart` |
| Standardize `fromJson` error handling (SortDirection) | ✅ Done | `lib/src/enums/sort_direction.dart` |
| Add `tryFromPreset()` to `SearchQuery` | ✅ Done | `lib/src/enums/search_query.dart` |
| Add `fromValue()` to `SearchQuery` | ✅ Done | `lib/src/enums/search_query.dart` |

### v1.6.0 - Polish Fixes (Phase 3 Complete!)

| Task | Status | File |
|------|--------|------|
| Add validation to `SearchQuery.custom()` | ✅ Done | `lib/src/enums/search_query.dart` |
| Add `opposite` getter to `SortDirection` | ✅ Done | `lib/src/enums/sort_direction.dart` |
| Add `@JsonEnum` annotations to fixed enums | ✅ Done | Multiple files |
| Add comprehensive docs to all new enums | ✅ Done | Multiple files |

---

## 🟡 Remaining Minor Issues (Optional)

### 1. `tagSlug` Could Have Convenience Methods

**Current State:** `String? tagSlug` in markets/events endpoints

**Rationale:** The API accepts arbitrary tag slugs, so we can't fully replace with an enum. However, we already have `MarketCategory` which provides common slugs.

**Recommendation:** Document that users can use `MarketCategory.politics.slug` etc., or keep as-is since the current design is flexible.

**Status:** ⬜ Optional Enhancement

### 2. `sportsMarketTypes` is `List<String>`

**Current State:** `List<String>? sportsMarketTypes` in markets endpoint

**Rationale:** Sports market types come from API (`SportsEndpoint.getValidMarketTypes()`), making them dynamic. Creating a static enum could become stale.

**Recommendation:** Keep as-is; the API-driven approach is more maintainable.

**Status:** ⬜ Optional Enhancement

### 3. `eventsTags` is `List<String>`

**Current State:** `List<String>? eventsTags` in search endpoint

**Rationale:** Tags are user-defined and dynamic.

**Recommendation:** Keep as-is.

**Status:** ⬜ Not Needed

---

## New Enums Created (v1.6.0)

| Enum | Values | Priority | Status |
|------|--------|----------|--------|
| `TagOrderBy` | `volume`, `eventsCount`, `createdAt`, `label` | 🔴 Critical | ✅ Done |
| `CommentOrderBy` | `createdAt`, `likes`, `replies`, `updatedAt` | 🔴 Critical | ✅ Done |
| `SeriesOrderBy` | `volume`, `startDate`, `endDate`, `createdAt`, `liquidity` | 🔴 Critical | ✅ Done |
| `SportsOrderBy` | `name`, `league`, `abbreviation`, `createdAt` | 🔴 Critical | ✅ Done |
| `RecurrenceType` | `daily`, `weekly`, `monthly`, `yearly`, `none` | 🔴 Critical | ✅ Done |
| `UmaResolutionStatus` | `pending`, `proposed`, `disputed`, `resolved` | 🔴 Critical | ✅ Done |

---

## Enum Standard Pattern

All enums now follow this consistent pattern:

```dart
import 'package:json_annotation/json_annotation.dart';

/// Description of the enum.
@JsonEnum(valueField: 'value')
enum MyEnum {
  /// Description of value1
  value1('value1'),

  /// Description of value2
  value2('value2');

  final String value;
  const MyEnum(this.value);

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static MyEnum fromJson(String json) {
    return MyEnum.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown MyEnum: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static MyEnum? tryFromJson(String? json) {
    if (json == null) return null;
    return MyEnum.values.cast<MyEnum?>().firstWhere(
          (e) => e?.value == json,
          orElse: () => null,
        );
  }
}
```

---

## Files Modified Log

| Date | Version | Files Changed |
|------|---------|---------------|
| 2026-01-18 | 1.3.0 | `market_order_by.dart`, `event_order_by.dart`, `markets_endpoint.dart`, `events_endpoint.dart` |
| 2026-01-18 | 1.4.0 | `price_history_interval.dart`, `gamma_leaderboard_order_by.dart`, `search_sort.dart`, `events_status.dart`, `ws_subscription_type.dart`, `pricing_endpoint.dart`, `leaderboard_endpoint.dart`, `search_endpoint.dart`, `websocket_client.dart` |
| 2026-01-18 | 1.5.0 | `search_query.dart`, `search_endpoint.dart`, `market_discovery_example.dart` |
| 2026-01-18 | 1.6.0 | `tag_order_by.dart`, `comment_order_by.dart`, `series_order_by.dart`, `sports_order_by.dart`, `recurrence_type.dart`, `uma_resolution_status.dart`, `tags_endpoint.dart`, `comments_endpoint.dart`, `series_endpoint.dart`, `sports_endpoint.dart`, `events_endpoint.dart`, `markets_endpoint.dart`, `search_endpoint.dart`, `leaderboard_window.dart`, `leaderboard_type.dart`, `sort_direction.dart`, `enums.dart` |

---

## Summary

### Total Enums: 30+

**Order Enums (8):**
- `MarketOrderBy`, `EventOrderBy`, `TagOrderBy`, `CommentOrderBy`, `SeriesOrderBy`, `SportsOrderBy`, `GammaLeaderboardOrderBy`, `SearchSort`

**Status/Type Enums (10):**
- `EventsStatus`, `UmaResolutionStatus`, `RecurrenceType`, `OrderStatus`, `TradeStatus`, `GameStatus`, `LeaderboardType`, `LeaderboardWindow`, `ActivityType`, `WsSubscriptionType`

**Value Enums (6):**
- `OrderSide`, `OrderType`, `OutcomeType`, `SortDirection`, `SortBy`, `PriceHistoryInterval`

**Category Enums (6):**
- `MarketCategory`, `PoliticsSubcategory`, `SportsSubcategory`, `CryptoSubcategory`, `PopCultureSubcategory`, `BusinessSubcategory`, `ScienceSubcategory`

**Sealed Classes (1):**
- `SearchQuery` (60+ presets + custom)

### Breaking Changes in v1.6.0

1. `TagsEndpoint.listTags()` - `order` parameter changed from `String?` to `TagOrderBy?`
2. `CommentsEndpoint.listComments()` - `order` parameter changed from `String?` to `CommentOrderBy?`
3. `SeriesEndpoint.listSeries()` - `order` parameter changed from `String?` to `SeriesOrderBy?`, `recurrence` changed from `String?` to `RecurrenceType?`
4. `SportsEndpoint.listTeams()` - `order` parameter changed from `String?` to `SportsOrderBy?`
5. `EventsEndpoint.listEvents()` - `recurrence` parameter changed from `String?` to `RecurrenceType?`
6. `SearchEndpoint.search()` - `recurrence` parameter changed from `String?` to `RecurrenceType?`
7. `MarketsEndpoint.listMarkets()` - `umaResolutionStatus` parameter changed from `String?` to `UmaResolutionStatus?`
8. `SearchQuery.custom()` - Now throws `ArgumentError` on empty/whitespace input (previously accepted)
9. `LeaderboardWindow.fromJson()` - Now throws on invalid input (previously returned `all`)
10. `LeaderboardType.fromJson()` - Now throws on invalid input (previously returned `profit`)
11. `SortDirection.fromJson()` - Now throws on invalid input (previously returned `desc`)

---

## References

- [Principal Dart Reviewer Feedback](./REVIEW_B_PLUS.md) - Original B+ review
- [Polymarket API Docs](https://docs.polymarket.com)

# Models Reference

All model classes for the Polymarket API wrapper.

---

## Standard Model Pattern

Every model MUST follow this pattern:

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_name.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ModelName extends Equatable {
  final String requiredField;
  final String? optionalField;
  
  @JsonKey(defaultValue: false)
  final bool fieldWithDefault;

  const ModelName({
    required this.requiredField,
    this.optionalField,
    this.fieldWithDefault = false,
  });

  factory ModelName.fromJson(Map<String, dynamic> json) => 
      _$ModelNameFromJson(json);
      
  Map<String, dynamic> toJson() => _$ModelNameToJson(this);

  @override
  List<Object?> get props => [requiredField, optionalField, fieldWithDefault];
}
```

---

## GAMMA API MODELS

### src/gamma/models/event.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'market.dart';
import 'tag.dart';
import 'category.dart';
import 'series.dart';

part 'event.g.dart';

/// A Polymarket event containing one or more markets.
@JsonSerializable(fieldRename: FieldRename.snake)
class Event extends Equatable {
  final String id;
  final String? ticker;
  final String? slug;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? resolutionSource;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? creationDate;
  final String? image;
  final String? icon;
  final String? featuredImage;
  
  @JsonKey(defaultValue: false)
  final bool active;
  
  @JsonKey(defaultValue: false)
  final bool closed;
  
  @JsonKey(defaultValue: false)
  final bool archived;
  
  @JsonKey(name: 'new', defaultValue: false)
  final bool isNew;
  
  @JsonKey(defaultValue: false)
  final bool featured;
  
  @JsonKey(defaultValue: false)
  final bool restricted;
  
  @JsonKey(defaultValue: false)
  final bool cyom;
  
  final double? liquidity;
  final double? liquidityAmm;
  final double? liquidityClob;
  final double? volume;
  final double? volume24hr;
  final double? volume1wk;
  final double? volume1mo;
  final double? volume1yr;
  final double? openInterest;
  final double? competitive;
  
  final String? category;
  final String? subcategory;
  final String? sortBy;
  
  final List<Category>? categories;
  final List<Tag>? tags;
  final List<Market>? markets;
  final List<Series>? series;
  
  @JsonKey(defaultValue: false)
  final bool negRisk;
  
  final String? negRiskMarketId;
  final int? negRiskFeeBips;
  
  final int? commentCount;
  
  @JsonKey(defaultValue: true)
  final bool commentsEnabled;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  @JsonKey(defaultValue: false)
  final bool enableOrderBook;
  
  @JsonKey(defaultValue: false)
  final bool live;
  
  @JsonKey(defaultValue: false)
  final bool ended;
  
  final String? gameStatus;

  const Event({
    required this.id,
    this.ticker,
    this.slug,
    this.title,
    this.subtitle,
    this.description,
    this.resolutionSource,
    this.startDate,
    this.endDate,
    this.creationDate,
    this.image,
    this.icon,
    this.featuredImage,
    this.active = false,
    this.closed = false,
    this.archived = false,
    this.isNew = false,
    this.featured = false,
    this.restricted = false,
    this.cyom = false,
    this.liquidity,
    this.liquidityAmm,
    this.liquidityClob,
    this.volume,
    this.volume24hr,
    this.volume1wk,
    this.volume1mo,
    this.volume1yr,
    this.openInterest,
    this.competitive,
    this.category,
    this.subcategory,
    this.sortBy,
    this.categories,
    this.tags,
    this.markets,
    this.series,
    this.negRisk = false,
    this.negRiskMarketId,
    this.negRiskFeeBips,
    this.commentCount,
    this.commentsEnabled = true,
    this.createdAt,
    this.updatedAt,
    this.enableOrderBook = false,
    this.live = false,
    this.ended = false,
    this.gameStatus,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  @override
  List<Object?> get props => [id, slug, title];
}
```

---

### src/gamma/models/market.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'tag.dart';
import 'category.dart';
import 'event.dart';

part 'market.g.dart';

/// A Polymarket market (Gamma API format).
@JsonSerializable(fieldRename: FieldRename.snake)
class Market extends Equatable {
  final String id;
  final String? question;
  final String conditionId;
  final String? slug;
  final DateTime? endDate;
  final String? liquidity;
  final String? volume;
  
  @JsonKey(defaultValue: false)
  final bool active;
  
  @JsonKey(defaultValue: false)
  final bool closed;
  
  @JsonKey(defaultValue: false)
  final bool acceptingOrders;
  
  @JsonKey(defaultValue: false)
  final bool enableOrderBook;
  
  final double? volumeNum;
  final double? liquidityNum;
  
  /// JSON string of outcomes array - use [outcomesList] for parsed list
  final String? outcomes;
  
  /// JSON string of prices array - use [outcomePricesList] for parsed list
  final String? outcomePrices;
  
  final String marketMakerAddress;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  final List<Event>? events;
  final List<Category>? categories;
  final List<Tag>? tags;
  
  /// JSON string of token IDs - use [tokenIdsList] for parsed list
  final String? clobTokenIds;

  const Market({
    required this.id,
    this.question,
    required this.conditionId,
    this.slug,
    this.endDate,
    this.liquidity,
    this.volume,
    this.active = false,
    this.closed = false,
    this.acceptingOrders = false,
    this.enableOrderBook = false,
    this.volumeNum,
    this.liquidityNum,
    this.outcomes,
    this.outcomePrices,
    required this.marketMakerAddress,
    this.createdAt,
    this.updatedAt,
    this.events,
    this.categories,
    this.tags,
    this.clobTokenIds,
  });

  factory Market.fromJson(Map<String, dynamic> json) => _$MarketFromJson(json);
  Map<String, dynamic> toJson() => _$MarketToJson(this);

  /// Parse outcomes JSON string to list
  List<String> get outcomesList {
    if (outcomes == null) return [];
    try {
      return List<String>.from(jsonDecode(outcomes!));
    } catch (_) {
      return [];
    }
  }

  /// Parse outcome prices JSON string to list
  List<double> get outcomePricesList {
    if (outcomePrices == null) return [];
    try {
      return List<String>.from(jsonDecode(outcomePrices!))
          .map((s) => double.tryParse(s) ?? 0.0)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Parse CLOB token IDs JSON string to list
  List<String> get tokenIdsList {
    if (clobTokenIds == null) return [];
    try {
      return List<String>.from(jsonDecode(clobTokenIds!));
    } catch (_) {
      return [];
    }
  }

  @override
  List<Object?> get props => [id, conditionId, slug];
}
```

---

### src/gamma/models/tag.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

/// A tag for categorizing events and markets.
@JsonSerializable(fieldRename: FieldRename.snake)
class Tag extends Equatable {
  final int id;
  final String? label;
  final String? slug;
  
  @JsonKey(defaultValue: false)
  final bool forceShow;
  
  @JsonKey(defaultValue: false)
  final bool display;
  
  final int? eventCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Tag({
    required this.id,
    this.label,
    this.slug,
    this.forceShow = false,
    this.display = false,
    this.eventCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);

  @override
  List<Object?> get props => [id, slug];
}
```

---

### src/gamma/models/category.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// A category for organizing events.
@JsonSerializable(fieldRename: FieldRename.snake)
class Category extends Equatable {
  final int? id;
  final String? label;
  final String? slug;

  const Category({
    this.id,
    this.label,
    this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  List<Object?> get props => [id, slug];
}
```

---

### src/gamma/models/profile.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

/// A user profile on Polymarket.
@JsonSerializable(fieldRename: FieldRename.snake)
class Profile extends Equatable {
  final DateTime? createdAt;
  final String? proxyWallet;
  final String? profileImage;
  final String? profileImageOptimized;
  
  @JsonKey(defaultValue: false)
  final bool displayUsernamePublic;
  
  final String? bio;
  final String? pseudonym;
  final String? name;
  final String? xUsername;
  
  @JsonKey(defaultValue: false)
  final bool verifiedBadge;
  
  final String? baseAddress;

  const Profile({
    this.createdAt,
    this.proxyWallet,
    this.profileImage,
    this.profileImageOptimized,
    this.displayUsernamePublic = false,
    this.bio,
    this.pseudonym,
    this.name,
    this.xUsername,
    this.verifiedBadge = false,
    this.baseAddress,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @override
  List<Object?> get props => [proxyWallet, pseudonym];
}
```

---

### src/gamma/models/comment.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'profile.dart';

part 'comment.g.dart';

/// A comment on an event, series, or market.
@JsonSerializable(fieldRename: FieldRename.snake)
class Comment extends Equatable {
  final String id;
  final String? body;
  final String? parentEntityType;
  final int? parentEntityId;
  final String? parentCommentId;
  final String? userAddress;
  final String? replyAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Profile? profile;
  final int? reportCount;
  final int? reactionCount;

  const Comment({
    required this.id,
    this.body,
    this.parentEntityType,
    this.parentEntityId,
    this.parentCommentId,
    this.userAddress,
    this.replyAddress,
    this.createdAt,
    this.updatedAt,
    this.profile,
    this.reportCount,
    this.reactionCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  @override
  List<Object?> get props => [id];
}
```

---

### src/gamma/models/series.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'event.dart';
import 'tag.dart';
import 'category.dart';

part 'series.g.dart';

/// A series of related events.
@JsonSerializable(fieldRename: FieldRename.snake)
class Series extends Equatable {
  final int? id;
  final String? ticker;
  final String? slug;
  final String? title;
  final String? subtitle;
  final String? seriesType;
  final String? recurrence;
  final String? description;
  final String? image;
  final String? icon;
  final String? layout;
  
  @JsonKey(defaultValue: false)
  final bool active;
  
  @JsonKey(defaultValue: false)
  final bool closed;
  
  @JsonKey(defaultValue: false)
  final bool archived;
  
  @JsonKey(name: 'new', defaultValue: false)
  final bool isNew;
  
  @JsonKey(defaultValue: false)
  final bool featured;
  
  @JsonKey(defaultValue: false)
  final bool restricted;
  
  final double? volume24hr;
  final double? volume;
  final double? liquidity;
  final double? score;
  final int? commentCount;
  
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? startDate;
  
  final List<Event>? events;
  final List<Category>? categories;
  final List<Tag>? tags;

  const Series({
    this.id,
    this.ticker,
    this.slug,
    this.title,
    this.subtitle,
    this.seriesType,
    this.recurrence,
    this.description,
    this.image,
    this.icon,
    this.layout,
    this.active = false,
    this.closed = false,
    this.archived = false,
    this.isNew = false,
    this.featured = false,
    this.restricted = false,
    this.volume24hr,
    this.volume,
    this.liquidity,
    this.score,
    this.commentCount,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.startDate,
    this.events,
    this.categories,
    this.tags,
  });

  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);
  Map<String, dynamic> toJson() => _$SeriesToJson(this);

  @override
  List<Object?> get props => [id, slug];
}
```

---

### src/gamma/models/team.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'team.g.dart';

/// A sports team.
@JsonSerializable(fieldRename: FieldRename.snake)
class Team extends Equatable {
  final int id;
  final String? name;
  final String? league;
  final String? record;
  final String? logo;
  final String? abbreviation;
  final String? alias;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Team({
    required this.id,
    this.name,
    this.league,
    this.record,
    this.logo,
    this.abbreviation,
    this.alias,
    this.createdAt,
    this.updatedAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  @override
  List<Object?> get props => [id, name];
}
```

---

### src/gamma/models/search_result.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'event.dart';
import 'tag.dart';
import 'profile.dart';

part 'search_result.g.dart';

/// Search results from Gamma API.
@JsonSerializable(fieldRename: FieldRename.snake)
class SearchResult extends Equatable {
  final List<Event>? events;
  final List<Tag>? tags;
  final List<Profile>? profiles;

  const SearchResult({
    this.events,
    this.tags,
    this.profiles,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) => 
      _$SearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$SearchResultToJson(this);

  @override
  List<Object?> get props => [events, tags, profiles];
}
```

---

## CLOB API MODELS

### src/clob/models/clob_market.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'clob_token.dart';
import 'clob_rewards.dart';

part 'clob_market.g.dart';

/// A market from the CLOB API (different structure from Gamma).
@JsonSerializable(fieldRename: FieldRename.snake)
class ClobMarket extends Equatable {
  final String conditionId;
  final String? question;
  final String? description;
  final String? marketSlug;
  final String? icon;
  final String? image;
  
  @JsonKey(defaultValue: false)
  final bool active;
  
  @JsonKey(defaultValue: false)
  final bool closed;
  
  @JsonKey(defaultValue: false)
  final bool archived;
  
  @JsonKey(defaultValue: false)
  final bool acceptingOrders;
  
  @JsonKey(defaultValue: true)
  final bool enableOrderBook;
  
  @JsonKey(defaultValue: false)
  final bool negRisk;
  
  final String? negRiskMarketId;
  final String? negRiskRequestId;
  
  final double minimumOrderSize;
  final double minimumTickSize;
  final double makerBaseFee;
  final double takerBaseFee;
  
  final String? endDateIso;
  final String? gameStartTime;
  final int? secondsDelay;
  
  final String? fpmm;
  
  @JsonKey(defaultValue: false)
  final bool is5050Outcome;
  
  @JsonKey(defaultValue: false)
  final bool notificationsEnabled;
  
  final ClobRewards? rewards;
  final List<ClobToken> tokens;
  final List<String>? tags;
  
  final String? acceptingOrderTimestamp;
  final String? questionId;

  const ClobMarket({
    required this.conditionId,
    this.question,
    this.description,
    this.marketSlug,
    this.icon,
    this.image,
    this.active = false,
    this.closed = false,
    this.archived = false,
    this.acceptingOrders = false,
    this.enableOrderBook = true,
    this.negRisk = false,
    this.negRiskMarketId,
    this.negRiskRequestId,
    required this.minimumOrderSize,
    required this.minimumTickSize,
    required this.makerBaseFee,
    required this.takerBaseFee,
    this.endDateIso,
    this.gameStartTime,
    this.secondsDelay,
    this.fpmm,
    this.is5050Outcome = false,
    this.notificationsEnabled = false,
    this.rewards,
    required this.tokens,
    this.tags,
    this.acceptingOrderTimestamp,
    this.questionId,
  });

  factory ClobMarket.fromJson(Map<String, dynamic> json) => 
      _$ClobMarketFromJson(json);
  Map<String, dynamic> toJson() => _$ClobMarketToJson(this);

  /// Get the Yes token
  ClobToken? get yesToken => tokens.isNotEmpty ? tokens[0] : null;
  
  /// Get the No token
  ClobToken? get noToken => tokens.length > 1 ? tokens[1] : null;

  @override
  List<Object?> get props => [conditionId, marketSlug];
}
```

---

### src/clob/models/clob_token.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clob_token.g.dart';

/// An outcome token in the CLOB.
@JsonSerializable(fieldRename: FieldRename.snake)
class ClobToken extends Equatable {
  final String outcome;
  final double price;
  final String tokenId;
  
  @JsonKey(defaultValue: false)
  final bool winner;

  const ClobToken({
    required this.outcome,
    required this.price,
    required this.tokenId,
    this.winner = false,
  });

  factory ClobToken.fromJson(Map<String, dynamic> json) => 
      _$ClobTokenFromJson(json);
  Map<String, dynamic> toJson() => _$ClobTokenToJson(this);

  @override
  List<Object?> get props => [tokenId, outcome];
}
```

---

### src/clob/models/clob_rewards.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clob_rewards.g.dart';

/// Liquidity reward configuration for a market.
@JsonSerializable(fieldRename: FieldRename.snake)
class ClobRewards extends Equatable {
  final double maxSpread;
  final double minSize;
  final Map<String, dynamic>? rates;

  const ClobRewards({
    required this.maxSpread,
    required this.minSize,
    this.rates,
  });

  factory ClobRewards.fromJson(Map<String, dynamic> json) => 
      _$ClobRewardsFromJson(json);
  Map<String, dynamic> toJson() => _$ClobRewardsToJson(this);

  @override
  List<Object?> get props => [maxSpread, minSize];
}
```

---

### src/clob/models/order_book.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'order_summary.dart';

part 'order_book.g.dart';

/// Order book for a token.
@JsonSerializable(fieldRename: FieldRename.snake)
class OrderBook extends Equatable {
  final String market;
  final String assetId;
  final String timestamp;
  final String hash;
  final List<OrderSummary> bids;
  final List<OrderSummary> asks;
  
  @JsonKey(name: 'min_tick_size')
  final String? minTickSize;
  
  final String? minOrderSize;
  
  @JsonKey(defaultValue: false)
  final bool negRisk;

  const OrderBook({
    required this.market,
    required this.assetId,
    required this.timestamp,
    required this.hash,
    required this.bids,
    required this.asks,
    this.minTickSize,
    this.minOrderSize,
    this.negRisk = false,
  });

  factory OrderBook.fromJson(Map<String, dynamic> json) => 
      _$OrderBookFromJson(json);
  Map<String, dynamic> toJson() => _$OrderBookToJson(this);

  /// Best bid price (highest buy order)
  double? get bestBid => bids.isNotEmpty 
      ? double.tryParse(bids.first.price) 
      : null;

  /// Best ask price (lowest sell order)
  double? get bestAsk => asks.isNotEmpty 
      ? double.tryParse(asks.first.price) 
      : null;

  /// Spread between best bid and ask
  double? get spread {
    if (bestBid == null || bestAsk == null) return null;
    return bestAsk! - bestBid!;
  }

  /// Midpoint price
  double? get midpoint {
    if (bestBid == null || bestAsk == null) return null;
    return (bestBid! + bestAsk!) / 2;
  }

  @override
  List<Object?> get props => [market, assetId, hash];
}
```

---

### src/clob/models/order_summary.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_summary.g.dart';

/// A price level in the order book.
@JsonSerializable(fieldRename: FieldRename.snake)
class OrderSummary extends Equatable {
  final String price;
  final String size;

  const OrderSummary({
    required this.price,
    required this.size,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) => 
      _$OrderSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$OrderSummaryToJson(this);

  /// Price as double
  double get priceNum => double.tryParse(price) ?? 0.0;
  
  /// Size as double
  double get sizeNum => double.tryParse(size) ?? 0.0;

  @override
  List<Object?> get props => [price, size];
}
```

---

### src/clob/models/order.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../enums/order_side.dart';
import '../../enums/order_type.dart';

part 'order.g.dart';

/// An order on the CLOB.
@JsonSerializable(fieldRename: FieldRename.snake)
class Order extends Equatable {
  final String id;
  final String market;
  final String assetId;
  final String owner;
  final String side;
  final String price;
  final String originalSize;
  final String sizeMatched;
  final String outcome;
  final String? expiration;
  final String? type;
  final String timestamp;
  final String? status;
  final List<String>? associatedTrades;

  const Order({
    required this.id,
    required this.market,
    required this.assetId,
    required this.owner,
    required this.side,
    required this.price,
    required this.originalSize,
    required this.sizeMatched,
    required this.outcome,
    this.expiration,
    this.type,
    required this.timestamp,
    this.status,
    this.associatedTrades,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  /// Parse side to enum
  OrderSide get sideEnum => OrderSide.fromJson(side);
  
  /// Remaining size to fill
  double get remainingSize {
    final original = double.tryParse(originalSize) ?? 0.0;
    final matched = double.tryParse(sizeMatched) ?? 0.0;
    return original - matched;
  }
  
  /// Whether order is fully filled
  bool get isFilled => remainingSize <= 0;

  @override
  List<Object?> get props => [id, market, assetId];
}
```

---

### src/clob/models/order_response.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_response.g.dart';

/// Response from posting an order.
@JsonSerializable(fieldRename: FieldRename.snake)
class OrderResponse extends Equatable {
  final bool success;
  final String? errorMsg;
  final String? orderId;
  final List<String>? transactionHashes;
  final String? status;
  final String? takingAmount;
  final String? makingAmount;

  const OrderResponse({
    required this.success,
    this.errorMsg,
    this.orderId,
    this.transactionHashes,
    this.status,
    this.takingAmount,
    this.makingAmount,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) => 
      _$OrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);

  @override
  List<Object?> get props => [success, orderId];
}
```

---

## DATA API MODELS

### src/data/models/position.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'position.g.dart';

/// A user's position in a market.
@JsonSerializable(fieldRename: FieldRename.snake)
class Position extends Equatable {
  final String proxyWallet;
  final String asset;
  final String conditionId;
  final double size;
  final double avgPrice;
  final double initialValue;
  final double currentValue;
  final double cashPnl;
  final double percentPnl;
  final double totalBought;
  final double realizedPnl;
  final double percentRealizedPnl;
  final double curPrice;
  
  @JsonKey(defaultValue: false)
  final bool redeemable;
  
  @JsonKey(defaultValue: false)
  final bool mergeable;
  
  final String title;
  final String slug;
  final String? icon;
  final String eventSlug;
  final String outcome;
  final int outcomeIndex;
  final String oppositeOutcome;
  final String oppositeAsset;
  final String? endDate;
  
  @JsonKey(defaultValue: false)
  final bool negativeRisk;

  const Position({
    required this.proxyWallet,
    required this.asset,
    required this.conditionId,
    required this.size,
    required this.avgPrice,
    required this.initialValue,
    required this.currentValue,
    required this.cashPnl,
    required this.percentPnl,
    required this.totalBought,
    required this.realizedPnl,
    required this.percentRealizedPnl,
    required this.curPrice,
    this.redeemable = false,
    this.mergeable = false,
    required this.title,
    required this.slug,
    this.icon,
    required this.eventSlug,
    required this.outcome,
    required this.outcomeIndex,
    required this.oppositeOutcome,
    required this.oppositeAsset,
    this.endDate,
    this.negativeRisk = false,
  });

  factory Position.fromJson(Map<String, dynamic> json) => 
      _$PositionFromJson(json);
  Map<String, dynamic> toJson() => _$PositionToJson(this);

  @override
  List<Object?> get props => [proxyWallet, asset, conditionId];
}
```

---

### src/data/models/activity.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../enums/activity_type.dart';
import '../../enums/order_side.dart';

part 'activity.g.dart';

/// On-chain activity record.
@JsonSerializable(fieldRename: FieldRename.snake)
class Activity extends Equatable {
  final String proxyWallet;
  final int timestamp;
  final String conditionId;
  final String type;
  final double size;
  final double usdcSize;
  final String transactionHash;
  final double? price;
  final String? asset;
  final String? side;
  final int? outcomeIndex;
  final String? title;
  final String? slug;
  final String? icon;
  final String? eventSlug;
  final String? outcome;
  final String? name;
  final String? pseudonym;
  final String? bio;
  final String? profileImage;

  const Activity({
    required this.proxyWallet,
    required this.timestamp,
    required this.conditionId,
    required this.type,
    required this.size,
    required this.usdcSize,
    required this.transactionHash,
    this.price,
    this.asset,
    this.side,
    this.outcomeIndex,
    this.title,
    this.slug,
    this.icon,
    this.eventSlug,
    this.outcome,
    this.name,
    this.pseudonym,
    this.bio,
    this.profileImage,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => 
      _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  /// Parse type to enum
  ActivityType get activityType => ActivityType.fromJson(type);
  
  /// Parse side to enum (only for trades)
  OrderSide? get sideEnum => side != null ? OrderSide.fromJson(side!) : null;
  
  /// Timestamp as DateTime
  DateTime get timestampDate => 
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  @override
  List<Object?> get props => [proxyWallet, timestamp, transactionHash];
}
```

---

### src/data/models/leaderboard_entry.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_entry.g.dart';

/// An entry on the leaderboard.
@JsonSerializable(fieldRename: FieldRename.snake)
class LeaderboardEntry extends Equatable {
  final int rank;
  final String proxyWallet;
  final String? name;
  final String? pseudonym;
  final String? profileImage;
  final double profit;
  final double volume;
  final int tradesCount;
  final double winRate;

  const LeaderboardEntry({
    required this.rank,
    required this.proxyWallet,
    this.name,
    this.pseudonym,
    this.profileImage,
    required this.profit,
    required this.volume,
    required this.tradesCount,
    required this.winRate,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => 
      _$LeaderboardEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);

  @override
  List<Object?> get props => [rank, proxyWallet];
}
```

---

### src/data/models/holdings_value.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'holdings_value.g.dart';

/// Total value of a user's holdings.
@JsonSerializable(fieldRename: FieldRename.snake)
class HoldingsValue extends Equatable {
  final String proxyWallet;
  final double totalValue;
  final double totalPnl;
  final double totalPercentPnl;

  const HoldingsValue({
    required this.proxyWallet,
    required this.totalValue,
    required this.totalPnl,
    required this.totalPercentPnl,
  });

  factory HoldingsValue.fromJson(Map<String, dynamic> json) => 
      _$HoldingsValueFromJson(json);
  Map<String, dynamic> toJson() => _$HoldingsValueToJson(this);

  @override
  List<Object?> get props => [proxyWallet, totalValue];
}
```

---

### src/data/models/holder.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'holder.g.dart';

/// A holder of a specific token.
@JsonSerializable(fieldRename: FieldRename.snake)
class Holder extends Equatable {
  final String proxyWallet;
  final String? bio;
  final String? asset;
  final String? pseudonym;
  final double amount;
  
  @JsonKey(defaultValue: false)
  final bool displayUsernamePublic;
  
  final int? outcomeIndex;
  final String? name;
  final String? profileImage;
  final String? profileImageOptimized;

  const Holder({
    required this.proxyWallet,
    this.bio,
    this.asset,
    this.pseudonym,
    required this.amount,
    this.displayUsernamePublic = false,
    this.outcomeIndex,
    this.name,
    this.profileImage,
    this.profileImageOptimized,
  });

  factory Holder.fromJson(Map<String, dynamic> json) => _$HolderFromJson(json);
  Map<String, dynamic> toJson() => _$HolderToJson(this);

  @override
  List<Object?> get props => [proxyWallet, asset, amount];
}
```

---

## AUTH MODELS

### src/auth/models/api_credentials.dart

```dart
import 'package:equatable/equatable.dart';

/// API credentials for L2 authentication.
class ApiCredentials extends Equatable {
  final String apiKey;
  final String secret;
  final String passphrase;

  const ApiCredentials({
    required this.apiKey,
    required this.secret,
    required this.passphrase,
  });

  @override
  List<Object?> get props => [apiKey];
  
  @override
  String toString() => 'ApiCredentials(apiKey: ${apiKey.substring(0, 8)}...)';
}
```

---

## Barrel Exports

Create barrel exports for each module:

### src/gamma/models/models.dart

```dart
export 'event.dart';
export 'market.dart';
export 'tag.dart';
export 'category.dart';
export 'profile.dart';
export 'comment.dart';
export 'series.dart';
export 'team.dart';
export 'search_result.dart';
```

### src/clob/models/models.dart

```dart
export 'clob_market.dart';
export 'clob_token.dart';
export 'clob_rewards.dart';
export 'order_book.dart';
export 'order_summary.dart';
export 'order.dart';
export 'order_response.dart';
```

### src/data/models/models.dart

```dart
export 'position.dart';
export 'activity.dart';
export 'leaderboard_entry.dart';
export 'holdings_value.dart';
export 'holder.dart';
```

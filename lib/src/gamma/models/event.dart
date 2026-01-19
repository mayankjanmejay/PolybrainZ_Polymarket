import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../enums/business_subcategory.dart';
import '../../enums/crypto_subcategory.dart';
import '../../enums/game_status.dart';
import '../../enums/market_category.dart';
import '../../enums/politics_subcategory.dart';
import '../../enums/pop_culture_subcategory.dart';
import '../../enums/science_subcategory.dart';
import '../../enums/sort_by.dart';
import '../../enums/sports_subcategory.dart';
import 'market.dart';
import 'tag.dart';
import 'category.dart';
import 'series.dart';

part 'event.g.dart';

/// A Polymarket event containing one or more markets.
@JsonSerializable()
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

  /// Parse category to enum
  MarketCategory? get categoryEnum =>
      category != null ? MarketCategory.bySlug(category!) : null;

  /// Parse sortBy to enum
  SortBy? get sortByEnum {
    if (sortBy == null) return null;
    try {
      return SortBy.fromJson(sortBy!);
    } catch (_) {
      return null;
    }
  }

  /// Parse gameStatus to enum
  GameStatus? get gameStatusEnum => GameStatus.tryFromJson(gameStatus);

  /// Parse subcategory to enum based on the category.
  ///
  /// Returns the appropriate subcategory enum based on [categoryEnum]:
  /// - [PoliticsSubcategory] for politics
  /// - [SportsSubcategory] for sports
  /// - [CryptoSubcategory] for crypto
  /// - [PopCultureSubcategory] for pop culture
  /// - [BusinessSubcategory] for business
  /// - [ScienceSubcategory] for science
  Object? get subcategoryEnum {
    if (subcategory == null) return null;
    final cat = categoryEnum;
    if (cat == null) return null;

    switch (cat) {
      case MarketCategory.politics:
        return PoliticsSubcategory.bySlug(subcategory!);
      case MarketCategory.sports:
        return SportsSubcategory.bySlug(subcategory!);
      case MarketCategory.crypto:
        return CryptoSubcategory.bySlug(subcategory!);
      case MarketCategory.popCulture:
        return PopCultureSubcategory.bySlug(subcategory!);
      case MarketCategory.business:
        return BusinessSubcategory.bySlug(subcategory!);
      case MarketCategory.science:
        return ScienceSubcategory.bySlug(subcategory!);
      default:
        return null;
    }
  }

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'ticker': ticker,
      'slug': slug,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'resolutionSource': resolutionSource,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'creationDate': creationDate?.toIso8601String(),
      'image': image,
      'icon': icon,
      'featuredImage': featuredImage,
      'active': active,
      'closed': closed,
      'archived': archived,
      'isNew': isNew,
      'featured': featured,
      'restricted': restricted,
      'liquidity': liquidity,
      'volume': volume,
      'volume24hr': volume24hr,
      'volume1wk': volume1wk,
      'volume1mo': volume1mo,
      'volume1yr': volume1yr,
      'openInterest': openInterest,
      'category': category,
      'subcategory': subcategory,
      'negRisk': negRisk,
      'negRiskMarketId': negRiskMarketId,
      'commentCount': commentCount,
      'enableOrderBook': enableOrderBook,
      'live': live,
      'ended': ended,
      'gameStatus': gameStatus,
      'markets': markets?.map((m) => m.toLegacyMap()).toList(),
      'tags': tags?.map((t) => t.toLegacyMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, slug, title];
}

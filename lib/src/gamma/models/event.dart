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

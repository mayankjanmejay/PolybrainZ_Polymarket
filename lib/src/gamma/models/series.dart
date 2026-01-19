import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../enums/recurrence_type.dart';
import '../../enums/series_layout.dart';
import '../../enums/series_type.dart';
import 'json_helpers.dart';
import 'event.dart';
import 'tag.dart';
import 'category.dart';

part 'series.g.dart';

/// A series of related events.
@JsonSerializable()
class Series extends Equatable {
  @JsonKey(fromJson: parseIdNullable)
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

  @JsonKey(fromJson: parseDoubleNullable)
  final double? volume24hr;
  @JsonKey(fromJson: parseDoubleNullable)
  final double? volume;
  @JsonKey(fromJson: parseDoubleNullable)
  final double? liquidity;
  @JsonKey(fromJson: parseDoubleNullable)
  final double? score;
  @JsonKey(fromJson: parseIdNullable)
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

  /// Get seriesType as type-safe [SeriesType] enum.
  SeriesType? get seriesTypeEnum => SeriesType.tryFromJson(seriesType);

  /// Get recurrence as type-safe [RecurrenceType] enum.
  RecurrenceType? get recurrenceEnum => RecurrenceType.tryFromJson(recurrence);

  /// Get layout as type-safe [SeriesLayout] enum.
  SeriesLayout? get layoutEnum => SeriesLayout.tryFromJson(layout);

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'ticker': ticker,
      'slug': slug,
      'title': title,
      'subtitle': subtitle,
      'seriesType': seriesType,
      'recurrence': recurrence,
      'description': description,
      'image': image,
      'icon': icon,
      'layout': layout,
      'active': active,
      'closed': closed,
      'archived': archived,
      'isNew': isNew,
      'featured': featured,
      'restricted': restricted,
      'volume24hr': volume24hr,
      'volume': volume,
      'liquidity': liquidity,
      'score': score,
      'commentCount': commentCount,
      'publishedAt': publishedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'events': events?.map((e) => e.toLegacyMap()).toList(),
      'categories': categories?.map((c) => c.toLegacyMap()).toList(),
      'tags': tags?.map((t) => t.toLegacyMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, slug];
}

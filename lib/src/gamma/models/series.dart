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

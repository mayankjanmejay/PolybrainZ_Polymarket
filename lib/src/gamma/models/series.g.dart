// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Series _$SeriesFromJson(Map<String, dynamic> json) => Series(
  id: (json['id'] as num?)?.toInt(),
  ticker: json['ticker'] as String?,
  slug: json['slug'] as String?,
  title: json['title'] as String?,
  subtitle: json['subtitle'] as String?,
  seriesType: json['series_type'] as String?,
  recurrence: json['recurrence'] as String?,
  description: json['description'] as String?,
  image: json['image'] as String?,
  icon: json['icon'] as String?,
  layout: json['layout'] as String?,
  active: json['active'] as bool? ?? false,
  closed: json['closed'] as bool? ?? false,
  archived: json['archived'] as bool? ?? false,
  isNew: json['new'] as bool? ?? false,
  featured: json['featured'] as bool? ?? false,
  restricted: json['restricted'] as bool? ?? false,
  volume24hr: (json['volume24hr'] as num?)?.toDouble(),
  volume: (json['volume'] as num?)?.toDouble(),
  liquidity: (json['liquidity'] as num?)?.toDouble(),
  score: (json['score'] as num?)?.toDouble(),
  commentCount: (json['comment_count'] as num?)?.toInt(),
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  events: (json['events'] as List<dynamic>?)
      ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
      .toList(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SeriesToJson(Series instance) => <String, dynamic>{
  'id': instance.id,
  'ticker': instance.ticker,
  'slug': instance.slug,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'series_type': instance.seriesType,
  'recurrence': instance.recurrence,
  'description': instance.description,
  'image': instance.image,
  'icon': instance.icon,
  'layout': instance.layout,
  'active': instance.active,
  'closed': instance.closed,
  'archived': instance.archived,
  'new': instance.isNew,
  'featured': instance.featured,
  'restricted': instance.restricted,
  'volume24hr': instance.volume24hr,
  'volume': instance.volume,
  'liquidity': instance.liquidity,
  'score': instance.score,
  'comment_count': instance.commentCount,
  'published_at': instance.publishedAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'start_date': instance.startDate?.toIso8601String(),
  'events': instance.events,
  'categories': instance.categories,
  'tags': instance.tags,
};

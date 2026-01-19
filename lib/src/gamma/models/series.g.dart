// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Series _$SeriesFromJson(Map<String, dynamic> json) => Series(
  id: parseIdNullable(json['id']),
  ticker: json['ticker'] as String?,
  slug: json['slug'] as String?,
  title: json['title'] as String?,
  subtitle: json['subtitle'] as String?,
  seriesType: json['seriesType'] as String?,
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
  volume24hr: parseDoubleNullable(json['volume24hr']),
  volume: parseDoubleNullable(json['volume']),
  liquidity: parseDoubleNullable(json['liquidity']),
  score: parseDoubleNullable(json['score']),
  commentCount: parseIdNullable(json['commentCount']),
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
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
  'seriesType': instance.seriesType,
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
  'commentCount': instance.commentCount,
  'publishedAt': instance.publishedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'startDate': instance.startDate?.toIso8601String(),
  'events': instance.events,
  'categories': instance.categories,
  'tags': instance.tags,
};

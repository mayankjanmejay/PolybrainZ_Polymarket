// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: json['id'] as String,
  ticker: json['ticker'] as String?,
  slug: json['slug'] as String?,
  title: json['title'] as String?,
  subtitle: json['subtitle'] as String?,
  description: json['description'] as String?,
  resolutionSource: json['resolutionSource'] as String?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  creationDate: json['creationDate'] == null
      ? null
      : DateTime.parse(json['creationDate'] as String),
  image: json['image'] as String?,
  icon: json['icon'] as String?,
  featuredImage: json['featuredImage'] as String?,
  active: json['active'] as bool? ?? false,
  closed: json['closed'] as bool? ?? false,
  archived: json['archived'] as bool? ?? false,
  isNew: json['new'] as bool? ?? false,
  featured: json['featured'] as bool? ?? false,
  restricted: json['restricted'] as bool? ?? false,
  cyom: json['cyom'] as bool? ?? false,
  liquidity: (json['liquidity'] as num?)?.toDouble(),
  liquidityAmm: (json['liquidityAmm'] as num?)?.toDouble(),
  liquidityClob: (json['liquidityClob'] as num?)?.toDouble(),
  volume: (json['volume'] as num?)?.toDouble(),
  volume24hr: (json['volume24hr'] as num?)?.toDouble(),
  volume1wk: (json['volume1wk'] as num?)?.toDouble(),
  volume1mo: (json['volume1mo'] as num?)?.toDouble(),
  volume1yr: (json['volume1yr'] as num?)?.toDouble(),
  openInterest: (json['openInterest'] as num?)?.toDouble(),
  competitive: (json['competitive'] as num?)?.toDouble(),
  category: json['category'] as String?,
  subcategory: json['subcategory'] as String?,
  sortBy: json['sortBy'] as String?,
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
  markets: (json['markets'] as List<dynamic>?)
      ?.map((e) => Market.fromJson(e as Map<String, dynamic>))
      .toList(),
  series: (json['series'] as List<dynamic>?)
      ?.map((e) => Series.fromJson(e as Map<String, dynamic>))
      .toList(),
  negRisk: json['negRisk'] as bool? ?? false,
  negRiskMarketId: json['negRiskMarketId'] as String?,
  negRiskFeeBips: (json['negRiskFeeBips'] as num?)?.toInt(),
  commentCount: (json['commentCount'] as num?)?.toInt(),
  commentsEnabled: json['commentsEnabled'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  enableOrderBook: json['enableOrderBook'] as bool? ?? false,
  live: json['live'] as bool? ?? false,
  ended: json['ended'] as bool? ?? false,
  gameStatus: json['gameStatus'] as String?,
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'ticker': instance.ticker,
  'slug': instance.slug,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'description': instance.description,
  'resolutionSource': instance.resolutionSource,
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'creationDate': instance.creationDate?.toIso8601String(),
  'image': instance.image,
  'icon': instance.icon,
  'featuredImage': instance.featuredImage,
  'active': instance.active,
  'closed': instance.closed,
  'archived': instance.archived,
  'new': instance.isNew,
  'featured': instance.featured,
  'restricted': instance.restricted,
  'cyom': instance.cyom,
  'liquidity': instance.liquidity,
  'liquidityAmm': instance.liquidityAmm,
  'liquidityClob': instance.liquidityClob,
  'volume': instance.volume,
  'volume24hr': instance.volume24hr,
  'volume1wk': instance.volume1wk,
  'volume1mo': instance.volume1mo,
  'volume1yr': instance.volume1yr,
  'openInterest': instance.openInterest,
  'competitive': instance.competitive,
  'category': instance.category,
  'subcategory': instance.subcategory,
  'sortBy': instance.sortBy,
  'categories': instance.categories,
  'tags': instance.tags,
  'markets': instance.markets,
  'series': instance.series,
  'negRisk': instance.negRisk,
  'negRiskMarketId': instance.negRiskMarketId,
  'negRiskFeeBips': instance.negRiskFeeBips,
  'commentCount': instance.commentCount,
  'commentsEnabled': instance.commentsEnabled,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'enableOrderBook': instance.enableOrderBook,
  'live': instance.live,
  'ended': instance.ended,
  'gameStatus': instance.gameStatus,
};

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
  resolutionSource: json['resolution_source'] as String?,
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  endDate: json['end_date'] == null
      ? null
      : DateTime.parse(json['end_date'] as String),
  creationDate: json['creation_date'] == null
      ? null
      : DateTime.parse(json['creation_date'] as String),
  image: json['image'] as String?,
  icon: json['icon'] as String?,
  featuredImage: json['featured_image'] as String?,
  active: json['active'] as bool? ?? false,
  closed: json['closed'] as bool? ?? false,
  archived: json['archived'] as bool? ?? false,
  isNew: json['new'] as bool? ?? false,
  featured: json['featured'] as bool? ?? false,
  restricted: json['restricted'] as bool? ?? false,
  cyom: json['cyom'] as bool? ?? false,
  liquidity: (json['liquidity'] as num?)?.toDouble(),
  liquidityAmm: (json['liquidity_amm'] as num?)?.toDouble(),
  liquidityClob: (json['liquidity_clob'] as num?)?.toDouble(),
  volume: (json['volume'] as num?)?.toDouble(),
  volume24hr: (json['volume24hr'] as num?)?.toDouble(),
  volume1wk: (json['volume1wk'] as num?)?.toDouble(),
  volume1mo: (json['volume1mo'] as num?)?.toDouble(),
  volume1yr: (json['volume1yr'] as num?)?.toDouble(),
  openInterest: (json['open_interest'] as num?)?.toDouble(),
  competitive: (json['competitive'] as num?)?.toDouble(),
  category: json['category'] as String?,
  subcategory: json['subcategory'] as String?,
  sortBy: json['sort_by'] as String?,
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
  negRisk: json['neg_risk'] as bool? ?? false,
  negRiskMarketId: json['neg_risk_market_id'] as String?,
  negRiskFeeBips: (json['neg_risk_fee_bips'] as num?)?.toInt(),
  commentCount: (json['comment_count'] as num?)?.toInt(),
  commentsEnabled: json['comments_enabled'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  enableOrderBook: json['enable_order_book'] as bool? ?? false,
  live: json['live'] as bool? ?? false,
  ended: json['ended'] as bool? ?? false,
  gameStatus: json['game_status'] as String?,
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'ticker': instance.ticker,
  'slug': instance.slug,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'description': instance.description,
  'resolution_source': instance.resolutionSource,
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'creation_date': instance.creationDate?.toIso8601String(),
  'image': instance.image,
  'icon': instance.icon,
  'featured_image': instance.featuredImage,
  'active': instance.active,
  'closed': instance.closed,
  'archived': instance.archived,
  'new': instance.isNew,
  'featured': instance.featured,
  'restricted': instance.restricted,
  'cyom': instance.cyom,
  'liquidity': instance.liquidity,
  'liquidity_amm': instance.liquidityAmm,
  'liquidity_clob': instance.liquidityClob,
  'volume': instance.volume,
  'volume24hr': instance.volume24hr,
  'volume1wk': instance.volume1wk,
  'volume1mo': instance.volume1mo,
  'volume1yr': instance.volume1yr,
  'open_interest': instance.openInterest,
  'competitive': instance.competitive,
  'category': instance.category,
  'subcategory': instance.subcategory,
  'sort_by': instance.sortBy,
  'categories': instance.categories,
  'tags': instance.tags,
  'markets': instance.markets,
  'series': instance.series,
  'neg_risk': instance.negRisk,
  'neg_risk_market_id': instance.negRiskMarketId,
  'neg_risk_fee_bips': instance.negRiskFeeBips,
  'comment_count': instance.commentCount,
  'comments_enabled': instance.commentsEnabled,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'enable_order_book': instance.enableOrderBook,
  'live': instance.live,
  'ended': instance.ended,
  'game_status': instance.gameStatus,
};

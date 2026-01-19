import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'tag.dart';
import 'category.dart';
import 'event.dart';

part 'market.g.dart';

/// A Polymarket market (Gamma API format).
@JsonSerializable()
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

  final String? marketMakerAddress;

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
    this.marketMakerAddress,
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

  /// Get YES price from outcome prices (first outcome)
  double get yesPrice {
    final prices = outcomePricesList;
    return prices.isNotEmpty ? prices[0] : 0.5;
  }

  /// Get NO price from outcome prices (second outcome or 1 - yesPrice)
  double get noPrice {
    final prices = outcomePricesList;
    return prices.length > 1 ? prices[1] : (1.0 - yesPrice);
  }

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'question': question,
      'conditionId': conditionId,
      'slug': slug,
      'endDate': endDate?.toIso8601String(),
      'liquidity': liquidityNum,
      'volume': volumeNum,
      'active': active,
      'closed': closed,
      'acceptingOrders': acceptingOrders,
      'enableOrderBook': enableOrderBook,
      'yesPrice': yesPrice,
      'noPrice': noPrice,
      'outcomePrices': outcomePricesList,
      'outcomes': outcomesList,
      'tokenIds': tokenIdsList,
      'marketMakerAddress': marketMakerAddress,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, conditionId, slug];
}

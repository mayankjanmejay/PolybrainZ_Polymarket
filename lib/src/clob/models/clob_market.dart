import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../enums/tag_slug.dart';
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

  /// Get tags as type-safe [TagSlug] list.
  List<TagSlug>? get tagSlugs => tags?.map((t) => TagSlug.fromValue(t)).toList();

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'conditionId': conditionId,
      'question': question,
      'description': description,
      'marketSlug': marketSlug,
      'icon': icon,
      'image': image,
      'active': active,
      'closed': closed,
      'archived': archived,
      'acceptingOrders': acceptingOrders,
      'enableOrderBook': enableOrderBook,
      'negRisk': negRisk,
      'negRiskMarketId': negRiskMarketId,
      'negRiskRequestId': negRiskRequestId,
      'minimumOrderSize': minimumOrderSize,
      'minimumTickSize': minimumTickSize,
      'makerBaseFee': makerBaseFee,
      'takerBaseFee': takerBaseFee,
      'endDateIso': endDateIso,
      'gameStartTime': gameStartTime,
      'secondsDelay': secondsDelay,
      'is5050Outcome': is5050Outcome,
      'tokens': tokens.map((t) => t.toLegacyMap()).toList(),
      'tags': tags,
    };
  }

  @override
  List<Object?> get props => [conditionId, marketSlug];
}

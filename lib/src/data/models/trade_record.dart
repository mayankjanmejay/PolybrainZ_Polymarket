import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../enums/order_side.dart';
import '../../enums/outcome_type.dart';

part 'trade_record.g.dart';

/// A trade record from the Data API.
@JsonSerializable(fieldRename: FieldRename.snake)
class TradeRecord extends Equatable {
  final String proxyWallet;
  final String conditionId;
  final String asset;
  final String side;
  final double size;
  final double price;
  final double usdcSize;
  final int timestamp;
  final String transactionHash;
  final String title;
  final String slug;
  final String? icon;
  final String eventSlug;
  final String outcome;
  final int outcomeIndex;
  final String? name;
  final String? pseudonym;
  final String? profileImage;

  const TradeRecord({
    required this.proxyWallet,
    required this.conditionId,
    required this.asset,
    required this.side,
    required this.size,
    required this.price,
    required this.usdcSize,
    required this.timestamp,
    required this.transactionHash,
    required this.title,
    required this.slug,
    this.icon,
    required this.eventSlug,
    required this.outcome,
    required this.outcomeIndex,
    this.name,
    this.pseudonym,
    this.profileImage,
  });

  factory TradeRecord.fromJson(Map<String, dynamic> json) =>
      _$TradeRecordFromJson(json);
  Map<String, dynamic> toJson() => _$TradeRecordToJson(this);

  DateTime get timestampDate =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  /// Parse side to enum
  OrderSide get sideEnum => OrderSide.fromJson(side);

  /// Parse outcome to enum
  OutcomeType? get outcomeEnum => OutcomeType.tryFromJson(outcome);

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'proxyWallet': proxyWallet,
      'conditionId': conditionId,
      'asset': asset,
      'side': side,
      'size': size,
      'price': price,
      'usdcSize': usdcSize,
      'timestamp': timestamp,
      'timestampDate': timestampDate.toIso8601String(),
      'transactionHash': transactionHash,
      'title': title,
      'slug': slug,
      'icon': icon,
      'eventSlug': eventSlug,
      'outcome': outcome,
      'outcomeIndex': outcomeIndex,
      'name': name,
      'pseudonym': pseudonym,
      'profileImage': profileImage,
    };
  }

  @override
  List<Object?> get props =>
      [proxyWallet, conditionId, timestamp, transactionHash];
}

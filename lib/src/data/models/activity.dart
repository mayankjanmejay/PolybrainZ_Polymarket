import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../enums/activity_type.dart';
import '../../enums/order_side.dart';
import '../../enums/outcome_type.dart';

part 'activity.g.dart';

/// On-chain activity record.
@JsonSerializable(fieldRename: FieldRename.snake)
class Activity extends Equatable {
  final String proxyWallet;
  final int timestamp;
  final String conditionId;
  final String type;
  final double size;
  final double usdcSize;
  final String transactionHash;
  final double? price;
  final String? asset;
  final String? side;
  final int? outcomeIndex;
  final String? title;
  final String? slug;
  final String? icon;
  final String? eventSlug;
  final String? outcome;
  final String? name;
  final String? pseudonym;
  final String? bio;
  final String? profileImage;

  const Activity({
    required this.proxyWallet,
    required this.timestamp,
    required this.conditionId,
    required this.type,
    required this.size,
    required this.usdcSize,
    required this.transactionHash,
    this.price,
    this.asset,
    this.side,
    this.outcomeIndex,
    this.title,
    this.slug,
    this.icon,
    this.eventSlug,
    this.outcome,
    this.name,
    this.pseudonym,
    this.bio,
    this.profileImage,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  /// Parse type to enum
  ActivityType get activityType => ActivityType.fromJson(type);

  /// Parse side to enum (only for trades)
  OrderSide? get sideEnum => side != null ? OrderSide.fromJson(side!) : null;

  /// Parse outcome to enum
  OutcomeType? get outcomeEnum => OutcomeType.tryFromJson(outcome);

  /// Timestamp as DateTime
  DateTime get timestampDate =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'proxyWallet': proxyWallet,
      'timestamp': timestamp,
      'timestampDate': timestampDate.toIso8601String(),
      'conditionId': conditionId,
      'type': type,
      'activityType': activityType.toJson(),
      'size': size,
      'usdcSize': usdcSize,
      'transactionHash': transactionHash,
      'price': price,
      'asset': asset,
      'side': side,
      'outcomeIndex': outcomeIndex,
      'title': title,
      'slug': slug,
      'icon': icon,
      'eventSlug': eventSlug,
      'outcome': outcome,
      'name': name,
      'pseudonym': pseudonym,
      'bio': bio,
      'profileImage': profileImage,
    };
  }

  @override
  List<Object?> get props => [proxyWallet, timestamp, transactionHash];
}

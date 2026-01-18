import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'holder.g.dart';

/// A holder of a specific token.
@JsonSerializable(fieldRename: FieldRename.snake)
class Holder extends Equatable {
  final String proxyWallet;
  final String? bio;
  final String? asset;
  final String? pseudonym;
  final double amount;

  @JsonKey(defaultValue: false)
  final bool displayUsernamePublic;

  final int? outcomeIndex;
  final String? name;
  final String? profileImage;
  final String? profileImageOptimized;

  const Holder({
    required this.proxyWallet,
    this.bio,
    this.asset,
    this.pseudonym,
    required this.amount,
    this.displayUsernamePublic = false,
    this.outcomeIndex,
    this.name,
    this.profileImage,
    this.profileImageOptimized,
  });

  factory Holder.fromJson(Map<String, dynamic> json) => _$HolderFromJson(json);
  Map<String, dynamic> toJson() => _$HolderToJson(this);

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'proxyWallet': proxyWallet,
      'bio': bio,
      'asset': asset,
      'pseudonym': pseudonym,
      'amount': amount,
      'displayUsernamePublic': displayUsernamePublic,
      'outcomeIndex': outcomeIndex,
      'name': name,
      'profileImage': profileImage,
      'profileImageOptimized': profileImageOptimized,
    };
  }

  @override
  List<Object?> get props => [proxyWallet, asset, amount];
}

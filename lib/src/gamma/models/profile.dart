import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

/// A user profile on Polymarket.
@JsonSerializable(fieldRename: FieldRename.snake)
class Profile extends Equatable {
  final DateTime? createdAt;
  final String? proxyWallet;
  final String? profileImage;
  final String? profileImageOptimized;

  @JsonKey(defaultValue: false)
  final bool displayUsernamePublic;

  final String? bio;
  final String? pseudonym;
  final String? name;
  final String? xUsername;

  @JsonKey(defaultValue: false)
  final bool verifiedBadge;

  final String? baseAddress;

  const Profile({
    this.createdAt,
    this.proxyWallet,
    this.profileImage,
    this.profileImageOptimized,
    this.displayUsernamePublic = false,
    this.bio,
    this.pseudonym,
    this.name,
    this.xUsername,
    this.verifiedBadge = false,
    this.baseAddress,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @override
  List<Object?> get props => [proxyWallet, pseudonym];
}

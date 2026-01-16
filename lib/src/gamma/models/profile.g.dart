// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  proxyWallet: json['proxy_wallet'] as String?,
  profileImage: json['profile_image'] as String?,
  profileImageOptimized: json['profile_image_optimized'] as String?,
  displayUsernamePublic: json['display_username_public'] as bool? ?? false,
  bio: json['bio'] as String?,
  pseudonym: json['pseudonym'] as String?,
  name: json['name'] as String?,
  xUsername: json['x_username'] as String?,
  verifiedBadge: json['verified_badge'] as bool? ?? false,
  baseAddress: json['base_address'] as String?,
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'created_at': instance.createdAt?.toIso8601String(),
  'proxy_wallet': instance.proxyWallet,
  'profile_image': instance.profileImage,
  'profile_image_optimized': instance.profileImageOptimized,
  'display_username_public': instance.displayUsernamePublic,
  'bio': instance.bio,
  'pseudonym': instance.pseudonym,
  'name': instance.name,
  'x_username': instance.xUsername,
  'verified_badge': instance.verifiedBadge,
  'base_address': instance.baseAddress,
};

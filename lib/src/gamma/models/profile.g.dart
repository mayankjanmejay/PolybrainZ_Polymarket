// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  proxyWallet: json['proxyWallet'] as String?,
  profileImage: json['profileImage'] as String?,
  profileImageOptimized: json['profileImageOptimized'] as String?,
  displayUsernamePublic: json['displayUsernamePublic'] as bool? ?? false,
  bio: json['bio'] as String?,
  pseudonym: json['pseudonym'] as String?,
  name: json['name'] as String?,
  xUsername: json['xUsername'] as String?,
  verifiedBadge: json['verifiedBadge'] as bool? ?? false,
  baseAddress: json['baseAddress'] as String?,
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'createdAt': instance.createdAt?.toIso8601String(),
  'proxyWallet': instance.proxyWallet,
  'profileImage': instance.profileImage,
  'profileImageOptimized': instance.profileImageOptimized,
  'displayUsernamePublic': instance.displayUsernamePublic,
  'bio': instance.bio,
  'pseudonym': instance.pseudonym,
  'name': instance.name,
  'xUsername': instance.xUsername,
  'verifiedBadge': instance.verifiedBadge,
  'baseAddress': instance.baseAddress,
};

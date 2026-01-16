// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Holder _$HolderFromJson(Map<String, dynamic> json) => Holder(
  proxyWallet: json['proxy_wallet'] as String,
  bio: json['bio'] as String?,
  asset: json['asset'] as String?,
  pseudonym: json['pseudonym'] as String?,
  amount: (json['amount'] as num).toDouble(),
  displayUsernamePublic: json['display_username_public'] as bool? ?? false,
  outcomeIndex: (json['outcome_index'] as num?)?.toInt(),
  name: json['name'] as String?,
  profileImage: json['profile_image'] as String?,
  profileImageOptimized: json['profile_image_optimized'] as String?,
);

Map<String, dynamic> _$HolderToJson(Holder instance) => <String, dynamic>{
  'proxy_wallet': instance.proxyWallet,
  'bio': instance.bio,
  'asset': instance.asset,
  'pseudonym': instance.pseudonym,
  'amount': instance.amount,
  'display_username_public': instance.displayUsernamePublic,
  'outcome_index': instance.outcomeIndex,
  'name': instance.name,
  'profile_image': instance.profileImage,
  'profile_image_optimized': instance.profileImageOptimized,
};

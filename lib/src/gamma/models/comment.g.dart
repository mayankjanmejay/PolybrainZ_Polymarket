// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: json['id'] as String,
  body: json['body'] as String?,
  parentEntityType: json['parentEntityType'] as String?,
  parentEntityId: (json['parentEntityId'] as num?)?.toInt(),
  parentCommentId: json['parentCommentId'] as String?,
  userAddress: json['userAddress'] as String?,
  replyAddress: json['replyAddress'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  profile: json['profile'] == null
      ? null
      : Profile.fromJson(json['profile'] as Map<String, dynamic>),
  reportCount: (json['reportCount'] as num?)?.toInt(),
  reactionCount: (json['reactionCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'body': instance.body,
  'parentEntityType': instance.parentEntityType,
  'parentEntityId': instance.parentEntityId,
  'parentCommentId': instance.parentCommentId,
  'userAddress': instance.userAddress,
  'replyAddress': instance.replyAddress,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'profile': instance.profile,
  'reportCount': instance.reportCount,
  'reactionCount': instance.reactionCount,
};

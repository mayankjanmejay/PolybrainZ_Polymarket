// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: json['id'] as String,
  body: json['body'] as String?,
  parentEntityType: json['parent_entity_type'] as String?,
  parentEntityId: (json['parent_entity_id'] as num?)?.toInt(),
  parentCommentId: json['parent_comment_id'] as String?,
  userAddress: json['user_address'] as String?,
  replyAddress: json['reply_address'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  profile: json['profile'] == null
      ? null
      : Profile.fromJson(json['profile'] as Map<String, dynamic>),
  reportCount: (json['report_count'] as num?)?.toInt(),
  reactionCount: (json['reaction_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'body': instance.body,
  'parent_entity_type': instance.parentEntityType,
  'parent_entity_id': instance.parentEntityId,
  'parent_comment_id': instance.parentCommentId,
  'user_address': instance.userAddress,
  'reply_address': instance.replyAddress,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'profile': instance.profile,
  'report_count': instance.reportCount,
  'reaction_count': instance.reactionCount,
};

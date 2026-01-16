import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'profile.dart';

part 'comment.g.dart';

/// A comment on an event, series, or market.
@JsonSerializable(fieldRename: FieldRename.snake)
class Comment extends Equatable {
  final String id;
  final String? body;
  final String? parentEntityType;
  final int? parentEntityId;
  final String? parentCommentId;
  final String? userAddress;
  final String? replyAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Profile? profile;
  final int? reportCount;
  final int? reactionCount;

  const Comment({
    required this.id,
    this.body,
    this.parentEntityType,
    this.parentEntityId,
    this.parentCommentId,
    this.userAddress,
    this.replyAddress,
    this.createdAt,
    this.updatedAt,
    this.profile,
    this.reportCount,
    this.reactionCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  @override
  List<Object?> get props => [id];
}

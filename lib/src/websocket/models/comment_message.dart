import 'package:equatable/equatable.dart';
import '../../enums/parent_entity_type.dart';
import '../../gamma/models/profile.dart';

/// Comment update from RTDS.
class CommentMessage extends Equatable {
  final String topic;
  final String id;
  final String body;
  final String? parentEntityType;
  final int? parentEntityId;
  final String? userAddress;
  final DateTime? createdAt;
  final Profile? profile;

  const CommentMessage({
    required this.topic,
    required this.id,
    required this.body,
    this.parentEntityType,
    this.parentEntityId,
    this.userAddress,
    this.createdAt,
    this.profile,
  });

  factory CommentMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return CommentMessage(
      topic: json['topic'] as String? ?? 'comments',
      id: data['id'] as String? ?? '',
      body: data['body'] as String? ?? '',
      parentEntityType: data['parent_entity_type'] as String?,
      parentEntityId: data['parent_entity_id'] as int?,
      userAddress: data['user_address'] as String?,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'] as String)
          : null,
      profile: data['profile'] != null
          ? Profile.fromJson(data['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Get parentEntityType as type-safe [ParentEntityType] enum.
  ParentEntityType? get parentEntityTypeEnum {
    if (parentEntityType == null) return null;
    try {
      return ParentEntityType.fromJson(parentEntityType!);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [id, body, parentEntityId];
}

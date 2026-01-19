// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
  id: _parseId(json['id']),
  label: json['label'] as String?,
  slug: json['slug'] as String?,
  forceShow: json['forceShow'] as bool? ?? false,
  display: json['display'] as bool? ?? false,
  eventCount: (json['eventCount'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'slug': instance.slug,
  'forceShow': instance.forceShow,
  'display': instance.display,
  'eventCount': instance.eventCount,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

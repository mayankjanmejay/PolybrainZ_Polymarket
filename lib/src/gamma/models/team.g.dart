// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  league: json['league'] as String?,
  record: json['record'] as String?,
  logo: json['logo'] as String?,
  abbreviation: json['abbreviation'] as String?,
  alias: json['alias'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'league': instance.league,
  'record': instance.record,
  'logo': instance.logo,
  'abbreviation': instance.abbreviation,
  'alias': instance.alias,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

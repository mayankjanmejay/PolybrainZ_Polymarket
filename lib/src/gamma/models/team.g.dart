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
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'league': instance.league,
  'record': instance.record,
  'logo': instance.logo,
  'abbreviation': instance.abbreviation,
  'alias': instance.alias,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

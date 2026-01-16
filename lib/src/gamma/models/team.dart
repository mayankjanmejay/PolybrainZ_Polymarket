import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'team.g.dart';

/// A sports team.
@JsonSerializable(fieldRename: FieldRename.snake)
class Team extends Equatable {
  final int id;
  final String? name;
  final String? league;
  final String? record;
  final String? logo;
  final String? abbreviation;
  final String? alias;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Team({
    required this.id,
    this.name,
    this.league,
    this.record,
    this.logo,
    this.abbreviation,
    this.alias,
    this.createdAt,
    this.updatedAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  @override
  List<Object?> get props => [id, name];
}

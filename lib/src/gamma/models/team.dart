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

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'name': name,
      'league': league,
      'record': record,
      'logo': logo,
      'abbreviation': abbreviation,
      'alias': alias,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name];
}

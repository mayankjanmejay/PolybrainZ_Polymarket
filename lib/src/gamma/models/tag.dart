import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

/// A tag for categorizing events and markets.
@JsonSerializable(fieldRename: FieldRename.snake)
class Tag extends Equatable {
  final int id;
  final String? label;
  final String? slug;

  @JsonKey(defaultValue: false)
  final bool forceShow;

  @JsonKey(defaultValue: false)
  final bool display;

  final int? eventCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Tag({
    required this.id,
    this.label,
    this.slug,
    this.forceShow = false,
    this.display = false,
    this.eventCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);

  @override
  List<Object?> get props => [id, slug];
}

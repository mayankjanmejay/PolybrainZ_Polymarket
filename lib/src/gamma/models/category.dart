import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// A category for organizing events.
@JsonSerializable(fieldRename: FieldRename.snake)
class Category extends Equatable {
  final int? id;
  final String? label;
  final String? slug;

  const Category({
    this.id,
    this.label,
    this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  List<Object?> get props => [id, slug];
}

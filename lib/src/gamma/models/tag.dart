import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

/// Helper to parse id that could be String or int
int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

/// A tag for categorizing events and markets.
@JsonSerializable(fieldRename: FieldRename.snake)
class Tag extends Equatable {
  @JsonKey(fromJson: _parseId)
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

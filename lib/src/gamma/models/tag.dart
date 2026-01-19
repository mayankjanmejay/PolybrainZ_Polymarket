import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../enums/tag_slug.dart';

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

  /// Get the slug as a type-safe [TagSlug].
  ///
  /// Returns `null` if [slug] is null.
  /// Attempts to match a preset first, otherwise creates a custom TagSlug.
  TagSlug? get slugEnum => slug != null ? TagSlug.fromValue(slug!) : null;

  /// Try to get a preset [TagSlug] matching this tag's slug.
  ///
  /// Returns `null` if [slug] is null or no preset matches.
  TagSlug? get slugPreset => slug != null ? TagSlug.tryFromPreset(slug!) : null;

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'label': label,
      'slug': slug,
      'forceShow': forceShow,
      'display': display,
      'eventCount': eventCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, slug];
}

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'event.dart';
import 'tag.dart';
import 'profile.dart';

part 'search_result.g.dart';

/// Search results from Gamma API.
@JsonSerializable(fieldRename: FieldRename.snake)
class SearchResult extends Equatable {
  final List<Event>? events;
  final List<Tag>? tags;
  final List<Profile>? profiles;

  const SearchResult({
    this.events,
    this.tags,
    this.profiles,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$SearchResultToJson(this);

  @override
  List<Object?> get props => [events, tags, profiles];
}

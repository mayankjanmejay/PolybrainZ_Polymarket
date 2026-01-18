import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_entry.g.dart';

/// An entry on the leaderboard.
@JsonSerializable(fieldRename: FieldRename.snake)
class LeaderboardEntry extends Equatable {
  final int rank;
  final String proxyWallet;
  final String? name;
  final String? pseudonym;
  final String? profileImage;
  final double profit;
  final double volume;
  final int tradesCount;
  final double winRate;

  const LeaderboardEntry({
    required this.rank,
    required this.proxyWallet,
    this.name,
    this.pseudonym,
    this.profileImage,
    required this.profit,
    required this.volume,
    required this.tradesCount,
    required this.winRate,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);

  /// Convert to a simplified Map format for easier consumption
  Map<String, dynamic> toLegacyMap() {
    return {
      'rank': rank,
      'proxyWallet': proxyWallet,
      'name': name,
      'pseudonym': pseudonym,
      'profileImage': profileImage,
      'profit': profit,
      'volume': volume,
      'tradesCount': tradesCount,
      'winRate': winRate,
    };
  }

  @override
  List<Object?> get props => [rank, proxyWallet];
}

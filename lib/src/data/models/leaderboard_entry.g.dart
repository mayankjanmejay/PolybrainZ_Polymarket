// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    LeaderboardEntry(
      rank: (json['rank'] as num).toInt(),
      proxyWallet: json['proxy_wallet'] as String,
      name: json['name'] as String?,
      pseudonym: json['pseudonym'] as String?,
      profileImage: json['profile_image'] as String?,
      profit: (json['profit'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      tradesCount: (json['trades_count'] as num).toInt(),
      winRate: (json['win_rate'] as num).toDouble(),
    );

Map<String, dynamic> _$LeaderboardEntryToJson(LeaderboardEntry instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'proxy_wallet': instance.proxyWallet,
      'name': instance.name,
      'pseudonym': instance.pseudonym,
      'profile_image': instance.profileImage,
      'profit': instance.profit,
      'volume': instance.volume,
      'trades_count': instance.tradesCount,
      'win_rate': instance.winRate,
    };

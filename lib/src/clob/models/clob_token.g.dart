// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clob_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClobToken _$ClobTokenFromJson(Map<String, dynamic> json) => ClobToken(
  outcome: json['outcome'] as String,
  price: (json['price'] as num).toDouble(),
  tokenId: json['token_id'] as String,
  winner: json['winner'] as bool? ?? false,
);

Map<String, dynamic> _$ClobTokenToJson(ClobToken instance) => <String, dynamic>{
  'outcome': instance.outcome,
  'price': instance.price,
  'token_id': instance.tokenId,
  'winner': instance.winner,
};

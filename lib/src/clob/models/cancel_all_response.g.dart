// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_all_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelAllResponse _$CancelAllResponseFromJson(Map<String, dynamic> json) =>
    CancelAllResponse(
      cancelledCount: (json['canceled'] as num).toInt(),
      failedCount: (json['failed'] as num).toInt(),
      cancelledIds:
          (json['canceledIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      failures:
          (json['failures'] as List<dynamic>?)
              ?.map((e) => CancelFailure.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$CancelAllResponseToJson(CancelAllResponse instance) =>
    <String, dynamic>{
      'canceled': instance.cancelledCount,
      'failed': instance.failedCount,
      'canceledIds': instance.cancelledIds,
      'failures': instance.failures,
    };

CancelFailure _$CancelFailureFromJson(Map<String, dynamic> json) =>
    CancelFailure(
      orderId: json['order_id'] as String,
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$CancelFailureToJson(CancelFailure instance) =>
    <String, dynamic>{'order_id': instance.orderId, 'reason': instance.reason};

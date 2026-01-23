// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelResult _$CancelResultFromJson(Map<String, dynamic> json) => CancelResult(
  orderId: json['order_id'] as String,
  success: json['success'] as bool,
  error: json['error'] as String?,
);

Map<String, dynamic> _$CancelResultToJson(CancelResult instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'success': instance.success,
      'error': instance.error,
    };

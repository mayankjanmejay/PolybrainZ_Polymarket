// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    OrderResponse(
      success: json['success'] as bool,
      errorMsg: json['error_msg'] as String?,
      orderId: json['order_id'] as String?,
      transactionHashes: (json['transaction_hashes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      status: json['status'] as String?,
      takingAmount: json['taking_amount'] as String?,
      makingAmount: json['making_amount'] as String?,
    );

Map<String, dynamic> _$OrderResponseToJson(OrderResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'error_msg': instance.errorMsg,
      'order_id': instance.orderId,
      'transaction_hashes': instance.transactionHashes,
      'status': instance.status,
      'taking_amount': instance.takingAmount,
      'making_amount': instance.makingAmount,
    };

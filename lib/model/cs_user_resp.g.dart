// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cs_user_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CSUserResp _$CSUserRespFromJson(Map<String, dynamic> json) => CSUserResp(
  message: json['message'] as String?,
  code: (json['code'] as num?)?.toInt(),
);

Map<String, dynamic> _$CSUserRespToJson(CSUserResp instance) =>
    <String, dynamic>{'message': instance.message, 'code': instance.code};

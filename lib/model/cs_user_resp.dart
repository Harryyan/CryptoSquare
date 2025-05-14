import 'package:json_annotation/json_annotation.dart';

part 'cs_user_resp.g.dart';

@JsonSerializable()
class CSUserResp {
  final String? message;
  final int? code;

  const CSUserResp({this.message, this.code});

  factory CSUserResp.fromJson(Map<String, dynamic> json) =>
      _$CSUserRespFromJson(json);

  Map<String, dynamic> toJson() => _$CSUserRespToJson(this);
}

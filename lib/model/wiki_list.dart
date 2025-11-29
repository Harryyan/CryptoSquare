import 'package:json_annotation/json_annotation.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';

part 'wiki_list.g.dart';

@JsonSerializable()
class WikiListResponse extends BaseResponse<List<WikiItem>> {
  const WikiListResponse({String? message, int? code, List<WikiItem>? data})
      : super(message: message, code: code, data: data);

  factory WikiListResponse.fromJson(Map<String, dynamic> json) {
    return WikiListResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => WikiItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson(Object? Function(List<WikiItem>) toJsonT) =>
      <String, dynamic>{
        'message': message,
        'code': code,
        'data': data,
      };
}

@JsonSerializable()
class WikiItem {
  const WikiItem({
    this.id,
    this.name,
    this.intro,
    this.slug,
    this.img,
  });

  factory WikiItem.fromJson(Map<String, dynamic> json) =>
      _$WikiItemFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'intro')
  final String? intro;

  @JsonKey(name: 'slug')
  final String? slug;

  @JsonKey(name: 'img')
  final String? img;

  Map<String, dynamic> toJson() => _$WikiItemToJson(this);
}


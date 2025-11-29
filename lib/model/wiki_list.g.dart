// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WikiListResponse _$WikiListResponseFromJson(Map<String, dynamic> json) =>
    WikiListResponse(
      message: json['message'] as String?,
      code: (json['code'] as num?)?.toInt(),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => WikiItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$WikiListResponseToJson(WikiListResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

WikiItem _$WikiItemFromJson(Map<String, dynamic> json) => WikiItem(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  intro: json['intro'] as String?,
  slug: json['slug'] as String?,
  img: json['img'] as String?,
);

Map<String, dynamic> _$WikiItemToJson(WikiItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'intro': instance.intro,
  'slug': instance.slug,
  'img': instance.img,
};

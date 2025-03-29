// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bitpush_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BitpushNewsItem _$BitpushNewsItemFromJson(Map<String, dynamic> json) =>
    BitpushNewsItem(
      id: (json['id'] as num?)?.toInt(),
      img: json['img'] as String?,
      big_img: json['big_img'] as String?,
      title: json['title'] as String?,
      link: json['link'] as String?,
      tags: json['tags'] as String?,
      time: (json['time'] as num?)?.toInt(),
      content: json['content'] as String?,
    );

Map<String, dynamic> _$BitpushNewsItemToJson(BitpushNewsItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'img': instance.img,
      'big_img': instance.big_img,
      'title': instance.title,
      'link': instance.link,
      'tags': instance.tags,
      'time': instance.time,
      'content': instance.content,
    };

BitpushNewsResponse _$BitpushNewsResponseFromJson(Map<String, dynamic> json) =>
    BitpushNewsResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => BitpushNewsItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$BitpushNewsResponseToJson(
  BitpushNewsResponse instance,
) => <String, dynamic>{'data': instance.data};

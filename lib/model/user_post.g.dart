// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPostResp _$UserPostRespFromJson(Map<String, dynamic> json) => UserPostResp(
  message: json['message'] as String,
  code: (json['code'] as num).toInt(),
  data: UserPostData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserPostRespToJson(UserPostResp instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

UserPostData _$UserPostDataFromJson(Map<String, dynamic> json) => UserPostData(
  total: (json['total'] as num).toInt(),
  data:
      (json['data'] as List<dynamic>)
          .map((e) => UserPostItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  currentPage: json['current_page'] as String,
);

Map<String, dynamic> _$UserPostDataToJson(UserPostData instance) =>
    <String, dynamic>{
      'total': instance.total,
      'data': instance.data,
      'current_page': instance.currentPage,
    };

UserPostItem _$UserPostItemFromJson(Map<String, dynamic> json) => UserPostItem(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  status: (json['status'] as num).toInt(),
  type: json['type'] as String,
  catId: (json['cat_id'] as num).toInt(),
  catName: json['cat_name'] as String,
  catInfo: CatInfo.fromJson(json['cat_info'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserPostItemToJson(UserPostItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'status': instance.status,
      'type': instance.type,
      'cat_id': instance.catId,
      'cat_name': instance.catName,
      'cat_info': instance.catInfo,
    };

CatInfo _$CatInfoFromJson(Map<String, dynamic> json) => CatInfo(
  title: json['title'] as String,
  catSlug: json['cat_slug'] as String,
);

Map<String, dynamic> _$CatInfoToJson(CatInfo instance) => <String, dynamic>{
  'title': instance.title,
  'cat_slug': instance.catSlug,
};
